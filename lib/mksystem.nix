{ nixpkgs, inputs, name }: 

{
      system = inputs.flake-utils.lib.system.x86_64-linux;;
      modules = [
        ../system/machine/${name}
        inputs.home-manager.nixosModules.home-manager
        ({ pkgs, lib, ... }:
          let
            metals-deps = pkgs.stdenv.mkDerivation {
              name = "metals-deps-${metals-version}";
              buildCommand = ''
                          export COURSIER_CACHE=$(pwd)
                          ${pkgs.coursier}/bin/cs fetch org.scalameta:metals_2.13:${metals-version} \
                      -r bintray:scalacenter/releases \
                      -r sonatype:snapshots > deps
                          mkdir -p $out/share/java
                          cp -n $(< deps) $out/share/java/
                        '';
              outputHashMode = "recursive";
              outputHashAlgo = "sha256";
              outputHash = "sha256-9zigJM0xEJSYgohbjc9ZLBKbPa/WGVSv3KVFE3QUzWE=";
            };
            metals-pkg = pkgs.metals.overrideAttrs (old: {
              version = metals-version;
              extraJavaOpts = old.extraJavaOpts + " -Dmetals.client=nvim-lsp";
              buildInputs = [ metals-deps ];
            });
      vim-plugin-keys = lib.lists.filter
        (key: lib.strings.hasSuffix "-plugin" key)
  (lib.attrNames inputs)
      ;
      vim-plugins = lib.lists.map
        (key: (pkgs.vimUtils.buildVimPlugin {
    pname = key;
    src = inputs."${key}";
    version = "0.1";
  }))
  vim-plugin-keys
      ;
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
                  pkgs.font-awesome
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
                                bind = $mod, N, exec, hyprctl dispatch renameworkspace $(hyprctl activeworkspace | head -n 1 | awk '{ print $3 }') $(rofi -dmenu -lines 0 -p 'Workspace name') && killall -SIGUSR2 waybar
                                bind = $mod, I, exec, hyprctl dispatch renameworkspace $(hyprctl activeworkspace | head -n 1 | awk '{ print $3 }') $(printf '\u'$(cat ${inputs.rofi-unicode-list}/unicode-list.txt | rofi -dmenu -i -markup-rows -p "" -columns 6 -width 100 -location 1 --lines 20 -bw 2 -yoffset -2 | cut -d\' -f2 | tail -c +4 | head -c -2)) && killall -SIGUSR2 waybar

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
                                                  gaps_in = 5
                                            gaps_out = 12
                                                }
                                                monitor = DP-2,3440x1440@100,0x0,1
                                                monitor = DP-3,3440x1440@100,3440x0,1
                                                monitor = DP-1,1920x1080@144,6880x0,1
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
                          active-only = true;
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
                          output = [ "DP-1" "DP-2" ];
                        })
                      ])
                      (lib.mkMerge [
                        base
                        ({
                          output = [
                            "DP-3"
                          ];

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
                  style = ''
                              * {
                            border: none;
                            border-radius: 0;
                            font-size: 18px;
                            min-height: 0;
                            font-family: "FiraCode Nerd Font", "Font Awesome 6 Free";
                          }

                          window#waybar {
                            background: none;/*#211818;*/
                    /*color: #e5e9f0;*/
                          }
                    #clock,
                    #tray,
                    #cpu,
                    #memory,
                    #disk,
                    #workspaces button,
                    #pulseaudio {
                      background-color: #333333;/*transparent;*/
                      color: @text;
                      /* border: 1px solid @darkgray; */
                      padding: 4px 15px;
                      margin-top: 5px;
                      margin-bottom: 5px;
                      margin-left: 1px;
                      margin-right: 1px;
                      border-radius: 15px;
                      transition: all 0.3s ease;
                    background-clip: padding-box;
                      border: 3px solid transparent;
                      animation: popout 0.5s ease;
                      /*border: 3px solid #ffffff;*/
                    }

                    @define-color text       #BECBCB;

                    @keyframes popout {
                      0% {
                        background-color: #ffffff;
                      }
                      100% {
                        background-color: #333333;
                      }
                    }

                    #workspaces button.active {

                      border: 3px solid #7aa2f7;

                      transition: all 0.3s ease-in-out;

                    }
                    /*
                          #workspaces {
                              background: rgba(26, 27, 38, 1);

                      padding: 0 10px;

                      border: 0;
                          }*/
                            '';
                };
                programs.rofi = {
                  enable = true;
                  plugins = [
                    pkgs.rofi-emoji
                  ];
                };
                services.spotifyd.enable = true;
                programs.firefox.enable = true;
                wayland.windowManager.sway.enable = true;
                programs.tmux = {
                  enable = true;
                  clock24 = true;
                  shell = "${pkgs.zsh}/bin/zsh";
                  extraConfig = ''
                    setw -g mode-keys vi

                    # set refresh interval for status bar
                    set -g status-interval 30

                    # center the status bar
                    set -g status-justify left

                    # show session, window, pane in left status bar
                    set -g status-left-length 40
                    set -g status-left '#I:#P #[default]'

                    set-window-option -g xterm-keys on
                    set -sg escape-time 0
                    set -g history-limit 40000

                    # Add truecolor support
                    set -g default-terminal "kitty"
                    set-option -g terminal-overrides ",kitty:Tc"
                    set -g focus-events on
                          '';
                };
                programs.git = {
                  enable = true;
                  userName = "Valdemar Grange";
                  userEmail = "randomvald0069@gmail.com";
                };
                programs.neovim =
                  let
                    a = "a";
                  in
                  {
                    enable = true;
                    defaultEditor = true;
                    plugins = vim-plugins;/*[
                      nvim-telescope-plugin
                      vim-fugitive-plugin
                      gruvbox-baby-plugin
    nvim-metals-plugin
    plenary-plugin
                    ];*/
        extraLuaConfig = ''

          vim.opt_global.shortmess:remove("F")

    metals_config = require('metals').bare_config()
    metals_config.init_options.statusBarProvider = "on"
    metals_config.settings = {
      showImplicitArguments = true,
      enableSemanticHighlighting = false,
      metalsBinaryPath = "${metals-pkg}/bin/metals"
    }

    vim.cmd [[augroup lsp]]
    vim.cmd [[au!]]
    vim.cmd [[au FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]]
    vim.cmd [[augroup end]]

    vim.cmd([[hi! link LspReferenceText CursorColumn]])
    vim.cmd([[hi! link LspReferenceRead CursorColumn]])
    vim.cmd([[hi! link LspReferenceWrite CursorColumn]])
        '';
                    extraConfig = ''
                      set number relativenumber
    syntax on
    let g:gruvbox_termcolors = 256
    set background=dark
    let g:gruvbox_contrast_dark='hard'
    colorscheme gruvbox-baby
    highlight Pmenu ctermbg=black guibg=#222222
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
              pkgs.busybox
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
}