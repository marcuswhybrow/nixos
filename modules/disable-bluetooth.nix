{
  # https://discourse.nixos.org/t/how-to-disable-bluetooth/9483

  hardware.bluetooth.enable = false;
  boot.blacklistedKernelModules = [
    "bluetooth"
    "btusb"
  ];
}
