{
  primary = "DP-3";
  other = [ "DP-2" "DP-1" ];
  monitor-config = ''
      monitorv2 {
        output = DP-3
        mode = 3440x1440@160
        position = 0x0
        scale = 1
        bitdepth = 10
        cm = hdr
        sdrbrightness = 1.1
        sdrsaturation = 1.1
        supports_wide_color = true
        supports_hdr = true
        sdr_min_luminance = 0.03
        sdr_max_luminance = 200
        min_luminance = 0
        max_luminance = 1000
        max_avg_luminance = 200
      }
    	monitor = DP-1,1920x1080@144,3440x0,1
        	'';
}
