{
  description = "bites";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages;

        builder = pkgs.haskellPackages.callCabal2nix "recipes-exe" ./. { };
      in {

        packages.default = self.packages.${system}.website;
        defaultPackage = self.packages.${system}.default;

        packages.website = pkgs.stdenv.mkDerivation rec {
          name = "cookbook";
          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

          src = ./.;

          # use the haskell package to build the website
          buildInputs = [ builder ];
          allowSubstitutes = false;
          buildPhase = ''
            mkdir public
            ${builder}/bin/recipes-exe build
          '';
          installPhase = ''
            mkdir -p $out/
            cp -R public/* $out/
          '';
          dontStrip = true;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            haskellPackages.haskell-language-server # you must build it with your ghc to work
            ghcid
            cabal-install
          ];
          inputsFrom =
            map (__getAttr "env") (__attrValues self.packages.${system});
        };
        devShell = self.devShells.${system}.default;
      });
}
