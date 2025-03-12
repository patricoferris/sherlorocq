{
  description = "Build an opam project not in the repo, using sane defaults";
  inputs.opam-nix.url = "github:tweag/opam-nix";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.sherlorocq.url = "github:patricoferris/sherlocode#coq";
  outputs =
    {
      self,
      opam-nix,
      sherlorocq,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages =
        let
          inherit (opam-nix.lib.${system}) buildOpamProject;
          scope = buildOpamProject { } "sherlorocq" sherlorocq {
            ocaml-system = "*";
          };
        in
        scope;
      defaultPackage = self.legacyPackages.${system}.sherlorocq;
    });
}
