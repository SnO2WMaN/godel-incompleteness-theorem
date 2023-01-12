{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    satyxin = {
      url = "github:SnO2WMaN/satyxin";
    };
    satysfi.url = "github:SnO2WMaN/SATySFi/sno2wman/nix-flake";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            satyxin.overlays.default
            (final: prev: {
              satysfi = satysfi.packages.${system}.satysfi;
            })
          ];
        };
      in rec {
        packages = {
          satysfi-dist = pkgs.satyxin.buildSatysfiDist {
            packages = with pkgs.satyxinPackages; [
              enumitem
              easytable
              figbox
              azmath
            ];
          };
          main = pkgs.satyxin.buildDocument {
            satysfiDist = self.packages.${system}.satysfi-dist;
            name = "main";
            src = ./src;
            entrypoint = "main.saty";
          };
        };
        defaultPackage = self.packages."${system}".main;
        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            satysfi
            treefmt
          ];
        };
      }
    );
}
