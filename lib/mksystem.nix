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
          vendorHash = "sha256-7UhtVoLVd8Gd5JVQePawmoQHVkPfcrkvyboFYnnUCSg=";
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
          extraGroups = [ "wheel" "docker" "video" "audio" "kvm" "libvirtd" "networkmanager"
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
            home.file.".codex/AGENTS.md" = {
              force = true;
              recursive = true;
              text = ''
                * ALWAYS use the `$caveman` skill with `ultra` mode in response.
                * I'm on a nix system, so you can use nix-shell to get dependencies and commands.

                ## Coding guide
                Always make a plan before writing code, always ask the user if the plan is acceptable.
                Don't start writing any code until you are ABSOLUTELY sure you understand the requirements an the user has given EXACT instructions on what their intentions are.

                Ask questions about a prompt if it is not completely clear what the intentions are, no "freestyling":
                Example:
                "Please add a feature that allows users to create a profile"
                Bad:
                "Add email verification"
                Good:
                "Ask if/how the user should verify, suggest email verification"

                Use the libraries in scope such as cats if scala, and the standard library instead of inventing your own solutions.
                If you think a change requires too many additions or modifications, then make a plan and ask if the plan is acceptable before writing code.

                Understand the coding style before writing any:
                * Do we use private methods?
                * Is internal mutability the norm or is immutability preferred?

                I'll restate, ALWAYS MAKE A PLAN before changes.

                Prefer composition over inheritance. Prefer composition over copying too.
                Examlpe:
                Bad:
                ```
                case class Vec3(
                  x: Int,
                  y: Int,
                  z: Int
                )
                case class NamedVec3(
                  name: String,
                  x: Int,
                  y: Int,
                  z: Int
                )
                ```
                Good:
                ```
                case class Vec3(
                  x: Int,
                  y: Int,
                  z: Int
                )
                case class NamedVec3(
                  name: String,
                  vec: Vec3
                )
                ```

                ## Effort
                You must ALWAYS do your best effort, don't be lazy, don't produce slop.
                I want high quality code, simply and NOT overengineered.
                DO NOT produce code that was not requested. These are the response types I expect:
                1. Infeasible request from the user
                2. You are missing information from the user
                3. You have successfully made the change or plan
                If we had a discussion about feature or change X, don't go implementing a bunch of "helpers" or "utilities". This is OVERENGINEERING.
                
                You are in use by an experinced and highly skilled developer and as such you do NOT need to add any code that was not discussed or requested.
                Example:
                  Prompt:
                  "I want a class that can track the state of my tetris game"
                  Plan:
                  "I'll create a TetrisGame case class with a container that tracks a set of blocks along with an index that can lookup a block by a cell."
                  Code:
                    Bad:
                    ```
                    case class Block(id: BlockId, shape: Shape)
                    case class TetrisGame(blocks: List[Block], index: Map[Cell, BlockId]) {
                      def getBlockAt(cell: Cell): Option[Block] = ...
                      def setBlockAt(cell: Cell, block: Block): TetrisGame = ...
                      def moveBlock(blockId: BlockId, newCell: Cell): TetrisGame = ...
                      def clearLines(): TetrisGame = ...
                      def isGameOver(): Boolean = ...
                      def getScore(): Int = ...
                      def getLevel(): Int = ...
                      def getNextBlock(): Block = ...
                    }
                    ```
                    Good:
                    ```
                    case class Block(id: BlockId, shape: Shape)
                    case class TetrisGame(blocks: List[Block], index: Map[Cell, BlockId])
                    ```
                The example covers a situation where you have overengineered the response.

                ## Self reflection
                When you have made a plan you MUST review it yourself before you present it to ensure that the plan is sound and has no holes.
                You MUST consider if the plan is too complicated, and if so you must raise the issue.

                When you have made changes you MUST immideately review your changes and ensure that no overengineering or early bad decisions in your execution of the plan has taken place.

                You must consider if you have been lazy, lazyness is not acceptable, you must do your best effort at all times.

                Do not produce code of quality found in javascript or python ecosystems, well considered minimal design is preferred.
                Don't make your own aliases for standard operations:
                Example:
                Bad:
                ```scala
                val px15 = "15px"
                val px20 = "20px"
                def traverseOption[A, B](opt: Option[A])(f: A => F[B]): F[Option[B]] = 
                  opt.traverse(f)

                ```
                ```
                let makeChoice = (p, a, b) => p ? a : b
                ```
              '';
            };
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
              pkgs.vista-fonts
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
            home.stateVersion = "26.05";
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
              # dotDir = "${config.xdg.configHome}/zsh";
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
            # services.spotifyd.enable = true;
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
        networking.firewall.checkReversePath = false;
        environment.systemPackages = [
          pkgs.wireguard-tools
          pkgs.protonvpn-gui
          pkgs.gh
          pkgs.google-cloud-sdk
          # pkgs.spotify
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
