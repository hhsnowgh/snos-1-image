{ config, pkgs, lib, floor, modulesPath, ... }:
{
  # SNOS MACHINE — the shipped image. Born empty: zero cells, an open door.
  # tty1: boot (the ledger's face). tty2: repl (the doorway). Nothing else.

  # --- the image's own disk (no hardware-configuration.nix here) ---------
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
  boot.growPartition = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [
    "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net" "virtio_gpu"
    "xhci_pci" "usbhid"
  ];
  boot.kernelParams = [ "quiet" ];
  boot.consoleLogLevel = 3;
  system.nixos.distroName = "SNOS";

  systemd.tmpfiles.rules = [
    "d /var/snos 0700 root root -"
    "d /var/snos/gate 0700 root root -"
    "f /var/snos/log 0664 root root -"
    "f /var/snos/lock 0664 root root -"
  ];

  # if the hypervisor shares a directory (UTM: Share Mode VirtIO-FS,
  # default tag "share"), it becomes the gate - drag a .snos file in on
  # the host, import it by name at the prompt. absent a share, the gate
  # is the local folder above and the machine boots identically.
  fileSystems."/var/snos/gate" = {
    device = "share";
    fsType = "virtiofs";
    options = [ "nofail" "x-systemd.device-timeout=3s" ];
  };

  systemd.services.snos-floor = {
    description = "the SNOS floor (tty1: boot, the ledger's face)";
    wantedBy = [ "multi-user.target" ];
    conflicts = [ "getty@tty1.service" ];
    after = [ "systemd-tmpfiles-setup.service" "systemd-user-sessions.service" ];
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      ExecStart = "${floor}/bin/floor boot --dir /var/snos";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
      Restart = "always";
      RestartSec = 1;
    };
  };

  systemd.services.snos-door = {
    description = "the SNOS doorway (tty2: repl, the built-in hatch)";
    wantedBy = [ "multi-user.target" ];
    conflicts = [ "getty@tty2.service" ];
    after = [ "systemd-tmpfiles-setup.service" "systemd-user-sessions.service" ];
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      ExecStart = "${floor}/bin/floor repl --dir /var/snos";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty2";
      TTYReset = true;
      TTYVHangup = true;
      Restart = "always";
      RestartSec = 1;
    };
  };

  services.logind.extraConfig = ''
    NAutoVTs=0
    ReserveVT=0
  '';

  # THE STRIP
  networking.useDHCP = false;
  networking.firewall.enable = false;
  networking.hostName = "snos";
  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.defaultPackages = [ ];
  environment.systemPackages = [ ];
  services.timesyncd.enable = false;
  hardware.enableRedistributableFirmware = false;
  systemd.oomd.enable = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];

  system.stateVersion = "24.11";
}
