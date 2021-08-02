{ pkgs ? import <unstable> {}
}:

pkgs.stdenv.mkDerivation rec {
  name = "recipes";

#  nativeBuildInputs = [
#    pkgs.pkg-config
#  ];

  buildInputs = [
    pkgs.zlib
    pkgs.haskell-language-server
    # pkgs.haskell.compiler.${ghc}
    pkgs.cabal-install
    pkgs.haskellPackages.ghcid
    pkgs.haskellPackages.cabal-plan
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH
    export LANG=en_US.UTF-8
  '';
}
