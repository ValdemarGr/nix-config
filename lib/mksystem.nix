{ nixpkgs, inputs, name }:

let
  machine = "valde";
  monitors = import ../system/machine/${name}/monitors.nix;
in
nixpkgs.lib.nixosSystem {
  system = inputs.flake-utils.lib.system.x86_64-linux;
  specialArgs = {
    inherit inputs;
  };
  modules = [
    ../system/machine/${name}
    # ./nord.nix
    inputs.home-manager.nixosModules.home-manager
    ({ pkgs, lib, config, ... }@deps:
      let
        wallpaper = ../wallpaper/wp.webp;
        gke-auth-module = pkgs.buildGoModule {
          name = "gke-auth-module";
          vendorHash = "sha256-Wi0LmibTBaUNkgBrHt86pY8lG/ieAOoQKP32pb7V83A=";
          src = "${inputs.gke-auth-module}";
        };
        set-gke-commands = pkgs.writeShellScriptBin "fix-gke-auth-commands" ''
          kubectl config get-users | xargs -I {} kubectl config set-credentials {} --exec-command=${gke-auth-module}/bin/gke-auth-plugin
        '';
        get-unicode-list = pkgs.writeShellScriptBin "rofi-get-unicode-list" ''
          cat ${inputs.rofi-unicode-list}/unicode-list.txt
        '';
        hypr-config = builtins.readFile ./hyprland.conf;
        # start-analyser = pkgs.writeShellScriptBin "start-analyser" ''
        #   rm /tmp/poefifo
        #   mkfifo /tmp/poefifo
        #   cat poefifo | ${pkgs.jdk21}/bin/java -jar /home/valde/git/detector/target/detector.jar
        # '';
        send-refresh = pkgs.writeShellScriptBin "send-refresh" ''
          cat /tmp/poeslurp | grim -g - - > /tmp/poess.png
          echo '{"type":"refresh"}' >> /tmp/poefifo
        '';
        send-adjust = pkgs.writeShellScriptBin "send-adjust" ''
          slurp > /tmp/poeslurp
        '';
        hyprland-startup = pkgs.writeShellScript "hyprland-start" ''
          sleep 1.5 && swww img "${wallpaper}" --transition-type none &
          waybar &
          dunst
        '';
        rofi-focus = pkgs.writeShellScriptBin "rofi-focus" ''
        for i in {1..20}
        do
          sleep 0.1
          W=$(hyprctl clients | grep " *class: Rofi$")
          if [ -n "$W" ]; then
            hyprctl dispatch focuswindow Rofi
            break
          fi
        done
        '';
        hypr-rofi = pkgs.writeShellScriptBin "hypr-rofi" ''
        ${rofi-focus}/bin/rofi-focus &
        rofi -show drun -show-icons
        '';
        hypr-rofi-workspace-name = pkgs.writeShellScriptBin "hypr-rofi-workspace-name" ''
        ${rofi-focus}/bin/rofi-focus &
        hyprctl dispatch renameworkspace $(hyprctl activeworkspace | head -n 1 | awk '{ print $3 }') $(rofi -dmenu -lines 0 -p 'Workspace name') && killall -SIGUSR2 waybar
        '';
        hypr-rofi-workspace-icon = pkgs.writeShellScriptBin "hypr-rofi-workspace-icon" ''
        ${rofi-focus}/bin/rofi-focus &
        hyprctl dispatch renameworkspace $(hyprctl activeworkspace | head -n 1 | awk '{ print $3 }') $(printf '\u'$(rofi-get-unicode-list | rofi -dmenu -i -markup-rows -p "" -columns 6 -width 100 -location 1 --lines 20 -bw 2 -yoffset -2 | cut -d\' -f2 | tail -c +4 | head -c -2)) && killall -SIGUSR2 waybar
        '';
        poedc = pkgs.writeShellScriptBin "poedc" ''
        iptables -I INPUT -p tcp --sport 6112 --tcp-flags PSH,ACK PSH,ACK -j REJECT --reject-with tcp-reset
        sleep 2
        iptables -D INPUT -p tcp --sport 6112 --tcp-flags PSH,ACK PSH,ACK -j REJECT --reject-with tcp-reset
        '';
        nclient = pkgs.writeShellScriptBin "nclient" ''
          nvim --server $SOCK --remote-expr "v:lua.vim.cmd(\"set splitright | vs | e $1 | setlocal bufhidden=wipe | startinsert\")"
          # $CHECK_OPEN="nvr --servername $SOCK --remote-expr \"bufexists(fnamemodify('/tmp/thefile', ':p'))\""
          NVR_EXECUTABLE=${pkgs.neovim-remote}/bin/nvr
          while [[ "$($NVR_EXECUTABLE --servername $SOCK --remote-expr "bufloaded('$1')" | tr -d '\n')" == "1" ]]; do
            sleep 0.1
          done
        '';
        n = pkgs.writeShellScriptBin "n" ''
          set -eu
          export SOCK="$HOME/nvim.$(date +%s).sock"
          export VISUAL=${nclient}/bin/nclient
          export EDITOR=$VISUAL

          exec nvim --listen "$SOCK" "$@"
        '';
      in
      {
        nixpkgs.overlays = [ inputs.fenix.overlays.default ];
        nixpkgs.config.allowUnfree = true;
        services.xserver.enable = true;
        # services.custom.nordvpn.enable = true;
        # services.displayManager.sddm.enable = true;
        # services.desktopManager.plasma6.enable = true;
        # services.displayManager.defaultSession = "plasma";
        services.displayManager.sddm.wayland.enable = true;
        security.sudo = {
          enable = true;
          extraRules = [{
            groups = [ "wheel" ];
            commands = [
              {
                command = "${poedc}/bin/poedc";
                options = [ "NOPASSWD" ];
              }
            ];
          }];
        };
        users.users.${machine} = {
          isNormalUser = true;
          extraGroups = [ "wheel" "docker" "video" "audio" "kvm" "libvirtd" 
          # "nordvpn"
          ];
          shell = pkgs.zsh;
        };
        #hardware.graphics = {
        #  enable = true;
        #  #driSupport = true;
        #  #driSupport32Bit = true;
        #};
        security.polkit.enable = true;
        programs.dconf.enable = true;
        # programs.gamescope = {
        #   enable = true;
        #   capSysNice = true;
        # };
        programs.steam = {
          enable = true;
          # gamescopeSession.enable = true;
          extraCompatPackages = [ pkgs.proton-ge-bin ];
          # extraPackages = with pkgs; [
          #   gamescope
          #   xorg.libXcursor
          #   xorg.libXi
          #   xorg.libXinerama
          #   xorg.libXScrnSaver
          #   libpng
          #   libpulseaudio
          #   libvorbis
          #   stdenv.cc.cc.lib
          #   libkrb5
          #   keyutils
          # ];
        };
        programs.nix-ld.enable = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.settings = {
          substituters = ["https://nix-gaming.cachix.org"];
          trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
        };
        nix.extraOptions = ''
        !include /home/${machine}/nix.conf
        '';
        #boot.kernelModules = [ "v4l2loopback" ];
        #boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        #boot.extraModprobeConfig = ''
        #  options v4l2loopback devices=1 exclusive_caps=1 video_nr=5 card_label="Virt"
        #'';
        boot.tmp.cleanOnBoot = true;
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
        fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${machine} = {
            home.packages = [
              #gke-auth-module
              set-gke-commands
              pkgs.spicedb-zed
              pkgs.gh
              pkgs.yarn
              pkgs.python311
              pkgs.nodejs_20
              pkgs.gnat
              pkgs.gnumake
              pkgs.watchman
              pkgs.ripgrep
              pkgs.webcord
              # pkgs.armcord
              pkgs.font-awesome
              pkgs.neovim-remote
              pkgs.lato
              pkgs.noto-fonts
              pkgs.r2modman
              pkgs.vesktop
              pkgs.dejavu_fonts
              pkgs.fontconfig
              pkgs.corefonts
              pkgs.vistafonts
              n
              # (pkgs.fenix.complete.withComponents [
              #   "cargo"
              #   "clippy"
              #   "rust-src"
              #   "rustc"
              #   "rustfmt"
              # ])
              # pkgs.rust-analyzer-nightly
            ];
            programs.element-desktop = {
              enable = true;
              settings = {
                show_labs_settings = true;
              };
            };
            imports = [
              ((import ../user/valde/nvim) inputs)
            ];
            programs.obs-studio = {
              enable = true;
              plugins = with pkgs.obs-studio-plugins; [
                wlrobs
                obs-pipewire-audio-capture
              ];
            };
            fonts.fontconfig.enable = true;
            wayland.windowManager.hyprland.enable = true;
            wayland.windowManager.hyprland.xwayland.enable = true;
            wayland.windowManager.hyprland.extraConfig = hypr-config + ''
              bind = $mod, D, exec, ${hypr-rofi}/bin/hypr-rofi
              bind = $mod, N, exec, ${hypr-rofi-workspace-name}/bin/hypr-rofi-workspace-name
              bind = $mod, I, exec, ${hypr-rofi-workspace-icon}/bin/hypr-rofi-workspace-icon
              ${monitors.monitor-config}
              monitor = ,addreserved,-12,0,0,0
              bind = ,F1, exec, sudo ${poedc}/bin/poedc
              exec-once=bash ${hyprland-startup}
              bind = $mod, A, exec, ${send-adjust}/bin/send-adjust
              bind = $mod, R, exec, ${send-refresh}/bin/send-refresh
            '';
            home = {
              pointerCursor = {
                gtk.enable = true;
                package = pkgs.bibata-cursors;
                name = "Bibata-Modern-Amber";
                size = 32;
              };
            };
            home.stateVersion = "24.11";
            home.username = "${machine}";
            home.homeDirectory = "/home/${machine}";
            gtk = {
              enable = true;
              theme = {
                package = pkgs.flat-remix-gtk;
                name = "Flat-Remix-GTK-Grey-Darkest";
              };
              iconTheme = {
                package = pkgs.libsForQt5.breeze-icons;
                name = "breeze-dark";
              };
              font = {
                name = "Sans";
                size = 11;
              };
            };
            programs.home-manager.enable = true;
            xdg.enable = true;
            services.easyeffects.enable = true;
            programs.bash.enable = true;
            programs.fzf = {
              enable = true;
              enableZshIntegration = true;
            };
            programs.btop.enable = true;
            programs.zsh = {
              enable = true;
              oh-my-zsh = {
                enable = true;
                theme = "agnoster";
                plugins = [ "git" "vi-mode" "bazel" ];
              };
              completionInit = ''
                export CLOUD_SDK_HOME="${pkgs.google-cloud-sdk}"
                source "$CLOUD_SDK_HOME/google-cloud-sdk/completion.zsh.inc"
              '';
              initContent  = ''
              source <(${pkgs.fzf}/bin/fzf --zsh)
              '';
            };
            programs.kitty.enable = true;
            programs.kitty.shellIntegration.enableZshIntegration = true;
            programs.kitty.extraConfig = builtins.readFile ./kitty.conf;
            programs.waybar = {
              enable = true;
              settings =
                let
                  base = {
                    position = "top";
                    layer = "top";
                    height = 42;
                    margin-top = 0;
                    margin-bottom = 0;
                    margin-left = 0;
                    margin-right = 0;
                    modules-center = [
                      "hyprland/workspaces"
                    ];
                    "hyprland/workspaces" = {
                      active-only = false;
                      all-outputs = false;
                      disable-scroll = false;
                      on-scroll-up = "hyprctl dispatch workspace e-1";
                      on-scroll-down = "hyprctl dispatch workspace e+1";
                      on-click = "activate";
                      show-special = "false";
                      sort-by-number = true;
                      format = "{id}: {name}";
                    };
                  };
                in
                [
                  (lib.mkMerge [
                    base
                    ({
                      output = monitors.other;
                    })
                  ])
                  (lib.mkMerge [
                    base
                    ({
                      output = [ monitors.primary ];

                      modules-right = [
                        "cpu"
                        "memory"
                        "disk"
                        "tray"
                        "pulseaudio"
                        "clock"
                      ];

                      clock = {
                        format = "󱑍 {:%H:%M}";
                        tooltip = false;
                        tooltip-format = ''
                          <big>{:%Y %B}</big>
                          <tt><small>{calendar}</small></tt>'';
                        format-alt = " {:%d/%m}";
                      };

                      memory = {
                        format = "󰍛 {}%";
                        format-alt = "󰍛 {used}/{total} GiB";
                        interval = 30;
                      };

                      cpu = {
                        format = "󰻠 {usage}%";
                        format-alt = "󰻠 {avg_frequency} GHz";
                        interval = 10;
                      };

                      disk = {
                        format = "󰋊 {}%";
                        format-alt = "󰋊 {used}/{total} GiB";
                        interval = 30;
                        path = "/";
                      };

                      tray = {
                        icon-size = 18;
                        spacing = 10;
                        tooltip = false;
                      };

                      pulseaudio = {
                        format = "{icon} {volume}%";
                        format-muted = "";
                        format-icons = { default = [ "" "" "" ]; };
                        on-click = "bash ~/.config/hypr/scripts/volume mute";
                        on-scroll-up = "bash ~/.config/hypr/scripts/volume up";
                        on-scroll-down = "bash ~/.config/hypr/scripts/volume down";
                        scroll-step = 5;
                        on-click-right = "pavucontrol";
                        tooltip = false;
                      };
                    })
                  ])
                ];
              style = builtins.readFile ./waybar.css;
            };
            programs.rofi = {
              enable = true;
              plugins = [
                pkgs.rofi-emoji
              ];
            };
            services.spotifyd.enable = true;
            programs.firefox.enable = true;
            programs.tmux = {
              enable = true;
              clock24 = true;
              shell = "${pkgs.zsh}/bin/zsh";
              extraConfig = builtins.readFile ./tmux.conf;
            };
            programs.git = {
              enable = true;
              userName = "Valdemar Grange";
              userEmail = "randomvald0069@gmail.com";
            };
            services.swww.enable = true;
          };
        };
        # networking.firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 8080 8081 8082 443 47989 ] ;
        #   allowedUDPPorts = [ 8080 8081 8082 1194 47989 ] ;
        # };
        services.sunshine = {
          autoStart = false;
          enable = true;
          capSysAdmin = true;
          openFirewall = true;
        };
        environment.systemPackages = [
          pkgs.gh
          pkgs.google-cloud-sdk
          pkgs.spotify
          pkgs.dunst
          pkgs.grim
          pkgs.slurp
          pkgs.jdk21
          pkgs.bazel-buildtools
          pkgs.docker-compose
          pkgs.wl-clipboard
          pkgs.discord
          pkgs.deepfilternet
          pkgs.busybox
          pkgs.kubectl
          get-unicode-list
          hypr-rofi
          hypr-rofi-workspace-name
          hypr-rofi-workspace-icon
          # pkgs.easyeffects
          #pkgs.xwaylandvideobridge
          # (pkgs.fenix.complete.withComponents [
          #   "cargo"
          #   "clippy"
          #   "rust-src"
          #   "rustc"
          #   "rustfmt"
          # ])
          # pkgs.rust-analyzer-nightly
          pkgs.vaapi-intel-hybrid
          pkgs.libva-vdpau-driver
        ];
        programs.zsh.enable = true;
        virtualisation.docker.enable = true;
        xdg.portal.config.common.default = "*";
        xdg.portal.enable = true;
        xdg.portal.wlr.enable = true;
        #sound.enable = true;
        security.rtkit.enable = true;
        services.ratbagd.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };
        programs.git.enable = true;
        programs.neovim.enable = true;
      })
  ];
}
