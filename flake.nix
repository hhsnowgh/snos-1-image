{
  # SNOS factory: builds the bootable machine image from the level.
  # The level (floor.rs, the format) lives at github:hhsnowgh/snos-1
  # and is pinned by this flake's lock; this repo only assembles.
  description = "SNOS machine image factory";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    snos-1 = {
      url = "github:hhsnowgh/snos-1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, snos-1 }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      floor = pkgs.runCommand "snos-floor"
        { nativeBuildInputs = [ pkgs.rustc pkgs.gcc ]; } ''
        mkdir -p $out/bin
        rustc -O ${snos-1}/floor.rs -o $out/bin/floor
      '';
      raw = import (nixpkgs + "/nixos/lib/make-disk-image.nix") {
        inherit pkgs;
        lib = nixpkgs.lib;
        config = self.nixosConfigurations.snos-machine.config;
        format = "qcow2";
        partitionTableType = "efi";
        diskSize = 8192;
      };
    in {
      packages.${system} = {
        inherit floor;
        image = pkgs.runCommand "snos-machine-image" { } ''
          mkdir -p $out
          ln -s ${raw}/nixos.qcow2 $out/snos-machine.qcow2
        '';
      };

      nixosConfigurations.snos-machine = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit floor; };
        modules = [ ./machine.nix ];
      };
    };
}
