{ config, pkgs, ... }:

let
sources = import ./nix/sources.nix;
in

{
  imports = [
    "${sources.nixos-hardware}/lenovo/thinkpad"
    "${sources.nixos-hardware}/common/cpu/intel"
    "${sources.nixos-hardware}/common/cpu/intel/kaby-lake"
    "${sources.nixos-hardware}/common/pc/laptop/ssd"
    "${sources.nixos-hardware}/common/pc/laptop/acpi_call.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];

  nix = {
    buildMachines = [ {
      hostName = "utdemir.com";
      sshUser = "build";
      sshKey = "/root/.ssh/id_rsa";
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }] ;
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  services.tlp.extraConfig = ''
    # powersave enables intel's p-state driver
    CPU_SCALING_GOVERNOR_ON_AC=performance
    CPU_SCALING_GOVERNOR_ON_BAT=powersave

    # https://linrunner.de/en/tlp/docs/tlp-faq.html#battery
    # use "tlp fullcharge" to override temporarily
    START_CHARGE_THRESH_BAT0=85
    STOP_CHARGE_THRESH_BAT0=90
    START_CHARGE_THRESH_BAT1=85
    STOP_CHARGE_THRESH_BAT1=90
  '';
  services.throttled.enable = true;
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.libinput = {
    enable = true;
  };

  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.gutenprintBin ];
    browsing = true;
  };
}
