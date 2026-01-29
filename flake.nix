{
  description = "minimal-hslua-wasm-example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    ghc-wasm-meta.url = "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org";
  };

  outputs = { self, nixpkgs, flake-utils, ghc-wasm-meta }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages;

        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

        # DON'T FORGET TO PUT YOUR PACKAGE NAME HERE, REMOVING `throw`
        packageName = "minimal-example";

        wasmToolchain = ghc-wasm-meta.packages.${system}.default;
        # Alternatively, if you want a specific "bundle" exposed by ghc-wasm-meta:
        # wasmToolchain = ghc-wasm-meta.packages.${system}.all_9_14;
      in {
        packages.${packageName} = haskellPackages.callCabal2nix packageName self { };

        packages.default = self.packages.${system}.${packageName};
        defaultPackage = self.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            wasmToolchain

            haskellPackages.haskell-language-server # you must build it with your ghc to work
            haskellPackages.hlint
            haskellPackages.cabal-install
            haskellPackages.cabal-plan
            haskellPackages.weeder
            haskellPackages.hpc
            haskellPackages.ghcid
            haskellPackages.stylish-haskell
            haskellPackages.eventlog2html
            haskellPackages.profiterole
            haskellPackages.profiteur
            zlib.dev
            git
            bashInteractive
            epubcheck # for validate-epub
            nodejs # for validate-epub
            ripgrep
            libxml2 # for xmllint
            jq
          ];
          inputsFrom = map (__getAttr "env") (__attrValues self.packages.${system});
        };

        devShell = self.devShells.${system}.default;
      });
}
