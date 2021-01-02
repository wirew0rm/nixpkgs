{ stdenv
, mkDerivation
, fetchgit
, gnuradio
, airspy
, hackrf
, libbladeRF
, rtl-sdr
, soapysdr-with-plugins
}:

let
  version = {
    "3.7" = "0.1.5";
    "3.8" = "0.2.2";
  }.${gnuradio.versionAttr.major};
  src = fetchgit {
    url = "git://git.osmocom.org/gr-osmosdr";
    rev = "v${version}";
    sha256 = {
      "3.7" = "0bf9bnc1c3c4yqqqgmg3nhygj6rcfmyk6pybi27f7461d2cw1drv";
      "3.8" = "HT6xlN6cJAnvF+s1g2I1uENhBJJizdADlLXeSD0rEqs=";
    }.${gnuradio.versionAttr.major};
  };
in mkDerivation {
  pname = "gr-osmosdr";
  inherit version src;

  buildInputs = [
    airspy
    hackrf
    libbladeRF
    rtl-sdr
    soapysdr-with-plugins
  ];
  nativeBuildInputs = stdenv.lib.optionals
    (
      (gnuradio.hasFeature "python-support" gnuradio.features) &&
      (gnuradio.versionAttr.major == "3.7")
    )
    [ gnuradio.python.pkgs.cheetah ]
  ;

  meta = with stdenv.lib; {
    description = "Gnuradio block for OsmoSDR and rtl-sdr";
    homepage = "https://sdr.osmocom.org/trac/wiki/GrOsmoSDR";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ bjornfor ];
  };
}
