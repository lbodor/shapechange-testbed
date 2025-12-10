{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    make-shell.url = "github:nicknovitski/make-shell";

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/shapechange.nix
        ./nix/ea-lite.nix
        ./nix/shells.nix
        ./nix/wine.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    };

  nixConfig.bash-prompt-prefix = "(nix-shell) ";
}
