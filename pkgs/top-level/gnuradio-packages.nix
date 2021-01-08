# callPackage here has gnuradio's `mkDerivation` and `mkDerivationWith` in scope
{ pkgs
, gnuradio # unwrapped gnuradio
}:

with pkgs.lib;

makeScope pkgs.newScope ( self:

let
  callPackage = self.callPackage;

  # Modeled after qt's
  mkDerivationWith = import ../development/gnuradio-modules/mkDerivation.nix {
    inherit (pkgs) stdenv;
    unwrapped = gnuradio;
  };
  mkDerivation = mkDerivationWith pkgs.stdenv.mkDerivation;

in {

  inherit callPackage mkDerivationWith mkDerivation;

  ### Packages

  inherit gnuradio;

  osmosdr = callPackage ../development/gnuradio-modules/osmosdr/default.nix { };

  ais = callPackage ../development/gnuradio-modules/ais/default.nix { };

  gsm = callPackage ../development/gnuradio-modules/gsm/default.nix { };

  nacl = callPackage ../development/gnuradio-modules/nacl/default.nix { };

  rds = callPackage ../development/gnuradio-modules/rds/default.nix { };

  limesdr = callPackage ../development/gnuradio-modules/limesdr/default.nix { };

  digitizers = callPackage ../development/gnuradio-modules/digitizers/default.nix { };

  flowgraph = callPackage ../development/gnuradio-modules/flowgraph/default.nix { };

})
