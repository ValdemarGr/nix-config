{
  primary = "DP-3";
  other = [ "DP-2" "DP-1" ];
  monitor-config = ''
    	monitor = DP-2,3440x1440@100,0x0,1
    	monitor = DP-3,3440x1440@160,3440x0,1
    	monitor = DP-1,1920x1080@144,6880x0,1
        	'';
}
