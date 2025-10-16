{
  description = "WPS Office flake featuring bwrap and usefull options";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # Define supported systems
    supportedSystems = ["x86_64-linux"];

    # Generate packages for one system
    pkgsForSystem = system: let
      pkgs = import nixpkgs {
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) ["wpsoffice-cn"];
        inherit system;
      };
    in {
      wpsoffice = pkgs.callPackage ./package.nix {};
      fonts = import ./fonts.nix {inherit pkgs;};
      default = self.packages."${system}".wpsoffice;
    };
  in {
    # Generate packages for all systems
    packages = nixpkgs.lib.genAttrs supportedSystems (system: pkgsForSystem system);

    # Generate apps for all systems
    apps = nixpkgs.lib.genAttrs supportedSystems (system: {
      wpsoffice = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/wps";
      };
    });
  };
}
