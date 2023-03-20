{ 
  enable = true;
  functions = {
    fish_greeting = "";
    wifi = ''
      if test (count $argv) -ge 1
        return (nmcli radio wifi $argv[1])
      end

      if test (nmcli radio wifi) = "enabled"
        nmcli radio wifi off
        echo "WiFi now off"
        return 0
      else
        nmcli radio wifi on
        echo "WiFi now on"
        return 0
      end
    '';
    options = ''
      for option in $argv
        echo $option
      end
    '';
  };
  shellAbbrs = {
    s = "sudo nixos-rebuild switch";
    c = "vim ~/.dotfiles";
    l = "wlogout";
  };
}
