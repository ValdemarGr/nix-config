{
  description = "Valde's nixos configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-telescope = {
      url = "github:nvim-telescope/telescope.nvim/7011eaae0ac1afe036e30c95cf80200b8dc3f21a";
      flake = false;
    };
    vim-fugitive = {
      url = "github:tpope/vim-fugitive/cbe9dfa162c178946afa689dd3f42d4ea8bf89c1";
      flake = false;
    };
    gruvbox-baby = {
      url = "github:valdemargr/gruvbox-baby/f65fe30691db64e8ca32aa6fba0cf07703adca28";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nvim-telescope, vim-fugitive, gruvbox-baby }:
    let
      system = flake-utils.lib.system.x86_64-linux;
      machine = "valde";
    in
    {
      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/machine/home
          home-manager.nixosModules.home-manager
          ({ pkgs, ... }:
            let
              nvim-telescope-plugin = pkgs.vimUtils.buildVimPlugin {
                pname = "telescope.nvim";
                src = nvim-telescope;
                version = "0.1.4";
              };
              vim-fugitive-plugin = pkgs.vimUtils.buildVimPlugin {
                pname = "vim-fugitive";
                src = vim-fugitive;
                version = "3.1";
              };
              gruvbox-baby-plugin = pkgs.vimUtils.buildVimPlugin {
                pname = "gruvbox-baby";
                src = gruvbox-baby;
                version = "0.1";
              };
              hyprland-startup = pkgs.writeShellScript "hyprland-start" ''
                			swww init &
                			waybar &
                			swww img "/home/valde/Downloads/horse.jpg" &
                			dunst
                		'';
            in
            {
              nixpkgs.config.allowUnfree = true;
              users.users.${machine} = {
                isNormalUser = true;
                extraGroups = [ "wheel" "video" "audio" ];
                shell = pkgs.zsh;
              };
              hardware.opengl = {
                enable = true;
                driSupport = true;
                driSupport32Bit = true;
              };
              security.polkit.enable = true;
              programs.sway.enable = true;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${machine} = {
                  home.packages = [
                    pkgs.gh
                    pkgs.nerdfonts
                    #pkgs.powerline-fonts
                    #pkgs.powerline-symbols
                    #pkgs.font-awesome
                  ];
                  fonts.fontconfig.enable = true;
                  #		  wayland.windowManager.sway.enable = true;
                  wayland.windowManager.hyprland.enable = true;
                  wayland.windowManager.hyprland.xwayland.enable = true;
                  wayland.windowManager.hyprland.extraConfig = ''
                    		      $mod = SUPER
                    		      bind = $mod, F, fullscreen, 9
                    		      bind = $mod, RETURN, exec, kitty
                    		      bind = $mod, L, exec, hyprctl keyword input:kb_layout dk
                    		      bind = $mod SHIFT, Q, killactive,
                    		      bind = $mod, D, exec, rofi -show drun -show-icons
                    		      bind = $mod SHIFT, S, exec, slurp | grim -g - - | wl-copy -t image/png

                    		      bind = $mod, right, movefocus, r
                    		      bind = $mod, left, movefocus, l
                    		      bind = $mod, up, movefocus, u
                    		      bind = $mod, down, movefocus, d

                    		      bind = $mod SHIFT, right, movewindow, r
                    		      bind = $mod SHIFT, left, movewindow, l
                    		      bind = $mod SHIFT, up, movewindow, u
                    		      bind = $mod SHIFT, down, movewindow, d

                    		      bind = $mod SHIFT CTRL, right, movecurrentworkspacetomonitor, r
                    		      bind = $mod SHIFT CTRL, left, movecurrentworkspacetomonitor, l
                    		      bind = $mod SHIFT CTRL, up, workspace, m+1
                    		      bind = $mod SHIFT CTRL, down, workspace, m-1

                    		      bind = $mod, 0, workspace, 0
                    		      bind = $mod, 1, workspace, 1
                    		      bind = $mod, 2, workspace, 2
                    		      bind = $mod, 3, workspace, 3
                    		      bind = $mod, 4, workspace, 4
                    		      bind = $mod, 5, workspace, 5
                    		      bind = $mod, 6, workspace, 6
                    		      bind = $mod, 7, workspace, 7
                    		      bind = $mod, 8, workspace, 8
                    		      bind = $mod, 9, workspace, 9

                    		      general {
                    		        gaps_in = 0
                    			gaps_out = 12
                    		      }
                    		      monitor = DP-2,3440x1440@100,0x0,1
                    		      monitor = DP-3,3440x1440@100,3440x0,1
                    		      monitor = DP-1,1920x1080@144,6880x0,1

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
                  programs.kitty.extraConfig = ''
                    # vim:ft=kitty
                    #: This is a template that can be used to create new kitty themes.
                    #: Theme files should start with a metadata block consisting of
                    #: lines beginning with ##. All metadata fields are optional.

                    ## name: The name of the theme (if not present, derived from filename)
                    ## author: The name of the theme author
                    ## license: The license information
                    ## upstream: A URL pointing to the location of this file upstream for auto-updates
                    ## blurb: A description of this theme. This must be the
                    ## last item in the metadata and can continue over multiple lines.

                    #: All the settings below are colors, which you can choose to modify, or use the
                    #: defaults. You can also add non-color based settings if needed but note that
                    #: these will not work with using kitty @ set-colors with this theme. For a
                    #: reference on what these settings do see https://sw.kovidgoyal.net/kitty/conf/

                    #: The basic colors

                    background                      #1D2426
                    foreground                      #AB9C71
                    # selection_foreground            #000000
                    # selection_background            #fffacd


                    #: Cursor colors

                    cursor                          #BE5E1E
                    # cursor_text_color               #111111


                    #: URL underline color when hovering with mouse

                    # url_color                       #0087bd


                    #: kitty window border colors and terminal bell colors

                    # active_border_color             #00ff00
                    # inactive_border_color           #cccccc
                    # bell_border_color               #ff5a00
                    # visual_bell_color               none


                    #: OS Window titlebar colors

                    # wayland_titlebar_color          system
                    # macos_titlebar_color            system


                    #: Tab bar colors

                    # active_tab_foreground           #000
                    # active_tab_background           #eee
                    # inactive_tab_foreground         #444
                    # inactive_tab_background         #999
                    # tab_bar_background              none
                    # tab_bar_margin_color            none


                    #: Colors for marks (marked text in the terminal)

                    # mark1_foreground black
                    # mark1_background #98d3cb
                    # mark2_foreground black
                    # mark2_background #f2dcd3
                    # mark3_foreground black
                    # mark3_background #f274bc


                    #: The basic 16 colors

                    #: black
                    color0 #39474A
                    color8 #4C5F63

                    #: red
                    color1 #986345
                    color9 #B07350

                    #: green
                    color2  #788249
                    # color10 #AF6B42
                    color10 #85914a

                    #: yellow
                    color3  #9a8518
                    #color11 #869151
                    color11 #a18b1a

                    #: blue
                    color4  #567a6e
                    color12 #567a6e

                    #: magenta
                    color5  #b9924a
                    color13 #d69d55

                    #: cyan
                    # color6  #5d796a
                    # color14 #668574
                    color6  #569186
                    color14 #5da396

                    #: white
                    color7  #977D5E
                    color15 #ab9c71

                    #font_family 3270 Nerd Font
                    #font_family BlexMono Nerd Font
                    font_family FiraCode Nerd Font
                    font_size 15.0

                    #: You can set the remaining 240 colors as color16 to color255.

                  '';
                  programs.waybar = {
                    enable = true;
                    settings = {
                      mainBar = {
                        position = "top";
                        layer = "top";
                        height = 12;
                        margin-top = 0;
                        margin-bottom = 0;
                        margin-left = 0;
                        margin-right = 0;
                        modules-left = [ "custom/launcher" "custom/playerctl" "custom/playerlabel" ];
                        modules-center = [
                          "hyprland/workspaces"
                          # "cpu"
                          # "memory"
                          # "disk"
                        ];

                        modules-right = [
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

                        "hyprland/workspaces" = {
                          active-only = false;
                          all-outputs = true;
                          disable-scroll = false;
                          on-scroll-up = "hyprctl dispatch workspace e-1";
                          on-scroll-down = "hyprctl dispatch workspace e+1";
                          on-click = "activate";
                          show-special = "false";
                          sort-by-number = true;
                          persistent_workspaces = {
                            "*" = 10;
                          };
                        };

                        "image" = {
                          exec = "bash ~/.scripts/album_art.sh";
                          size = 18;
                          interval = 10;
                        };

                        "custom/playerctl" = {
                          format = "{icon}";
                          return-type = "json";
                          max-length = 25;
                          exec = ''
                            playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
                          on-click-middle = "playerctl play-pause";
                          on-click = "playerctl previous";
                          on-click-right = "playerctl next";
                          format-icons = {
                            Playing = "<span foreground='#6791eb'>󰓇 </span>";
                            Paused = "<span foreground='#cdd6f4'>󰓇 </span>";
                          };
                          tooltip = false;
                        };

                        "custom/playerlabel" = {
                          format = "<span>{}</span>";
                          return-type = "json";
                          max-length = 25;
                          exec = ''
                            playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
                          on-click-middle = "playerctl play-pause";
                          on-click = "playerctl previous";
                          on-click-right = "playerctl next";
                          format-icons = {
                            Playing = "<span foreground='#6791eb'>󰓇 </span>";
                            Paused = "<span foreground='#cdd6f4'>󰓇 </span>";
                          };
                          tooltip = false;
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

                        "custom/launcher" = {
                          format = "{}";
                          size = 18;
                          # on-click = "notify-send -t 1 'swww' '1' & ~/.config/hypr/scripts/wall";
                          tooltip = false;

                        };
                      };
                    };
                  };
                  programs.rofi.enable = true;
                  services.spotifyd.enable = true;
                  programs.firefox.enable = true;
                  wayland.windowManager.sway.enable = true;
                  programs.git = {
                    enable = true;
                    userName = "Valdemar Grange";
                    userEmail = "randomvald0069@gmail.com";
                  };
                  programs.neovim = {
                    enable = true;
                    defaultEditor = true;
                    plugins = [
                      nvim-telescope-plugin
                      vim-fugitive-plugin
                      gruvbox-baby-plugin
                    ];
                    extraConfig = ''
                      set number relativenumber
                    '';
                  };
                };
              };
              environment.systemPackages = [
                pkgs.gh
                pkgs.google-cloud-sdk
                pkgs.spotify
                pkgs.dunst
                pkgs.swww
                pkgs.grim
                pkgs.slurp
                pkgs.wl-clipboard
                pkgs.discord
              ];
              programs.zsh.enable = true;
              xdg.portal.enable = true;
              xdg.portal.wlr.enable = true;
              sound.enable = true;
              security.rtkit.enable = true;
              services.pipewire = {
                enable = true;
                alsa.enable = true;
                alsa.support32Bit = true;
                pulse.enable = true;
                jack.enable = true;
              };
              #programs.hyprland.enable = true;
              programs.git.enable = true;
              programs.neovim.enable = true;
            })
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      # use mkShell
      devShells.${system}.${machine} = nixpkgs.legacyPackages.${system}.pkgs.mkShell {
        name = "hoy";
        buildInputs = [
          nixpkgs.legacyPackages.${system}.pkgs.curl
        ];
        shellHook = ''
          echo "Ohoy!"
        '';
      };
    };
}
