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
    inputs.home-manager.nixosModules.home-manager
    (deps@{ pkgs, lib, ... }:
      let
        wallpaper = ../wallpaper/wp.webp;
        gke-auth-module = pkgs.buildGoModule {
          name = "gke-auth-module";
          vendorHash = "sha256-wp5+Ab6fchuVQ47SuMH40WmlGbbN2EUCj7LkcJ0q5hs=";
          src = "${inputs.gke-auth-module}";
        };
        set-gke-commands = pkgs.writeShellScriptBin "fix-gke-auth-commands" ''
          kubectl config get-users | xargs -I {} kubectl config set-credentials {} --exec-command=${gke-auth-module}/bin/gke-auth-plugin
        '';
        get-unicode-list = pkgs.writeShellScriptBin "rofi-get-unicode-list" ''
          cat ${inputs.rofi-unicode-list}/unicode-list.txt
        '';
        hypr-config = builtins.readFile ./hyprland.conf;
        hyprland-startup = pkgs.writeShellScript "hyprland-start" ''
          swww init && sleep 1.5 && swww img "${wallpaper}" --transition-type none &
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
      in
      {
        #nixpkgs.overlays = [
        #  (import ../overlays/swww.nix deps)
        #];
        nixpkgs.config.allowUnfree = true;
        users.users.${machine} = {
          isNormalUser = true;
          extraGroups = [ "wheel" "docker" "video" "audio" "kvm" "libvirtd" ];
          shell = pkgs.zsh;
        };
        hardware.opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
        };
        security.polkit.enable = true;
        programs.dconf.enable = true;
        programs.steam.enable = true;
        programs.nix-ld.enable = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.extraOptions = ''
        !include /home/${machine}/nix.conf
        '';
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
              pkgs.nodejs_18
              pkgs.gnat
              pkgs.gnumake
              pkgs.watchman
              pkgs.ripgrep
              pkgs.nerdfonts
              pkgs.webcord
              pkgs.armcord
              pkgs.font-awesome
              pkgs.lato
              pkgs.noto-fonts
              pkgs.r2modman
            ];
            imports = [
              ((import ../user/valde/nvim) inputs)
            ];
            fonts.fontconfig.enable = true;
            wayland.windowManager.hyprland.enable = true;
            wayland.windowManager.hyprland.xwayland.enable = true;
            wayland.windowManager.hyprland.extraConfig = hypr-config + ''
              bind = $mod, D, exec, ${hypr-rofi}/bin/hypr-rofi
              bind = $mod, N, exec, ${hypr-rofi-workspace-name}/bin/hypr-rofi-workspace-name
              bind = $mod, I, exec, ${hypr-rofi-workspace-icon}/bin/hypr-rofi-workspace-icon
              ${monitors.monitor-config}
              monitor = ,addreserved,-12,0,0,0
              exec-once=bash ${hyprland-startup}
            '';
            home = {
              pointerCursor = {
                gtk.enable = true;
                package = pkgs.bibata-cursors;
                name = "Bibata-Modern-Amber";
                size = 32;
              };
            };
            home.stateVersion = "23.05";
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
          };
        };
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 8080 8081 8082 ] ;
          allowedUDPPorts = [ 8080 8081 8082 ] ;
        };
        environment.systemPackages = [
          pkgs.gh
          pkgs.google-cloud-sdk
          pkgs.spotify
          pkgs.dunst
          pkgs.swww
          pkgs.grim
          pkgs.slurp
          pkgs.jdk11
          pkgs.bazel-buildtools
          pkgs.docker-compose
          pkgs.wl-clipboard
          pkgs.discord
          pkgs.busybox
          pkgs.kubectl
          get-unicode-list
          hypr-rofi
          hypr-rofi-workspace-name
          hypr-rofi-workspace-icon
        ];
        programs.zsh.enable = true;
        virtualisation.docker.enable = true;
        xdg.portal.config.common.default = "*";
        xdg.portal.enable = true;
        xdg.portal.wlr.enable = true;
        sound.enable = true;
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
