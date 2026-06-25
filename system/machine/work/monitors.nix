{
  primary = "DP-1";
  other = [ "DP-2" "HDMI-A-2" ];
  monitor-config = ''
    hl.monitor({
      output = "DP-1",
      mode = "3440x1440@59.99900",
      position = "2560x0",
      scale = 1,
    })
    hl.monitor({
      output = "DP-2",
      mode = "2560x1440@59.99900",
      position = "0x0",
      scale = 1,
    })
    hl.monitor({
      output = "HDMI-A-2",
      mode = "2560x1440@59.99900",
      position = "6000x0",
      scale = 1,
    })
  '';
}
