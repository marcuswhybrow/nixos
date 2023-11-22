{ local, remote }: { pkgs, ... }: {
  # https://nixos.wiki/wiki/Samba
  fileSystems."/mnt/marcus-desktop/local" = {
    device = "//192.168.0.23/Local";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},credentials=/etc/nixos/secrets/marcus-laptop-smb,uid=1000,gid=100" ];
  };
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  services.gvfs.enable = true;
}
