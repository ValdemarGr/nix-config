{
  primary = "DP-3";
  other = [ "DP-2" "DP-1" ];
  monitor-config = ''
      monitorv2 {
        output = DP-3
        mode = 3440x1440@60
        position = 0x0
        scale = 1
        bitdepth = 10
      }
    	monitor = DP-1,1920x1080@144,3440x0,1
        	'';
}
