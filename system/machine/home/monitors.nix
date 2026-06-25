{
  primary = "DP-3";
  other = [ "DP-2" "DP-1" ];
  monitor-config = ''
    hl.monitor({
      output = "DP-3",
      mode = "3440x1440@150",
      position = "0x0",
      scale = 1,
      bitdepth = 10,
    })
    hl.monitor({
      output = "DP-1",
      mode = "1920x1080@144",
      position = "3440x0",
      scale = 1,
    })
  '';
}
