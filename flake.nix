{
  description = "WPS Office flake featuring bwrap and usefull options";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages = {
      "${system}" = {
        wpsoffice-sandboxed = pkgs.callPackage ./package.nix {};
        default = self.packages."${system}".wpsoffice-sandboxed;
      };
      fonts = {
        default = import ./fonts.nix {inherit pkgs;};
      };
    };
  };
}
