# Development workflow
# - Executing nix-build builds the packages
# - Executing nix-shell returns a shell environment containing
#   1. Haskell packages needed
#   2. Hoogle files for packages
#   3. cabal and ghcid installed
{ pkgs ? import <unstable> {}
}:
pkgs.haskellPackages.developPackage {
  root = ./.;
  name = "recipes";
  modifier = drv:
    # add buildtools such as cabal
    pkgs.haskell.lib.addBuildTools drv
      (with pkgs.haskellPackages; [
        cabal-install
        ghcid
        zlib
        pkgs.entr
        # install hoogle files for packages we use.
        #(hoogleLocal {packages = drv.propagatedBuildInputs;})
      ]);
}
