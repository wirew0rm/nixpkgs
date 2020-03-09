{ mkDerivation, stdenv, fetchFromGitHub, writeText, makeWrapper
# Dependencies documented @ https://gnuradio.org/doc/doxygen/build_guide.html
# => core dependencies
, cmake, pkgconfig, git, boost, fftw, gmp, gsm, codec2, log4cpp, mpir
, wrapGAppsHook, pango, cairo
# => thrift for ctrlport
, thrift
# => python wrappers
, python, swig, numpy, scipy, matplotlib
# => grc - the gnu radio companion
, Mako, pyyaml, pygobject3, gtk3, gobject-introspection, pycairo
# => gr-wavelet: collection of wavelet blocks
, gsl
# => gr-qtgui: the Qt-based GUI
, qtbase, qwt, pyqt5
# => gr-audio: audio subsystems (system/OS dependent)
, alsaLib   # linux   'audio-alsa'
, CoreAudio # darwin  'audio-osx'
# => gr-zeromq
, zeromq, cppzmq, pyzmq
# => uhd: the Ettus USRP Hardware Driver Interface
, uhd
# => gr-video-sdl: PAL and NTSC display
, SDL
# Other
, orc, pyopengl, libX11
}:

# TODO:
# - build volk separately
# - separate packages for submodules, grc?

mkDerivation rec {
  pname = "gnuradio";
  version = "3.8.1.0-rc1";

  src = fetchFromGitHub {
    owner = "gnuradio";
    repo = "gnuradio";
    rev = "v${version}";
    sha256 = "073xxppmflyi905qsiwvmjaplvc7fhml0h7kksn94v9c2c9sxk73";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake pkgconfig git makeWrapper orc wrapGAppsHook gobject-introspection
  ];

  buildInputs = [
    boost fftw python swig qtbase mpir gmp thrift pango cairo libX11
    qwt SDL uhd gsl zeromq cppzmq log4cpp gtk3 gobject-introspection
  ] ++ stdenv.lib.optionals stdenv.isLinux  [ alsaLib   ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ CoreAudio ];

  propagatedBuildInputs = [
    Mako numpy scipy matplotlib pyopengl pyzmq pyqt5 pygobject3 pyyaml pycairo
  ];

  NIX_LDFLAGS = "-lpthread";

  enableParallelBuilding = true;

  # Enables composition with nix-shell
  grcSetupHook = writeText "grcSetupHook.sh" ''
    addGRCBlocksPath() {
      addToSearchPath GRC_BLOCKS_PATH $1/share/gnuradio/grc/blocks
    }
    addEnvHooks "$targetOffset" addGRCBlocksPath
  '';

  setupHook = [ grcSetupHook ];

  # c++11 hack may not be necessary anymore
  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-unused-variable ${stdenv.lib.optionalString (!stdenv.isDarwin) "-std=c++11"}"
  '';

  # Framework path needed for qwt6_qt4 but not qwt5
  cmakeFlags =
    stdenv.lib.optionals stdenv.isDarwin [ "-DCMAKE_FRAMEWORK_PATH=${qwt}/lib" ];

  # - Ensure we get an interactive backend for matplotlib. If not the gr_plot_*
  #   programs will not display anything. Yes, $MATPLOTLIBRC must point to the
  #   *dirname* where matplotlibrc is located, not the file itself.
  # - GNU Radio core is C++ but the user interface (GUI and API) is Python, so
  #   we must wrap the stuff in bin/.
  # Notes:
  # - may want to change interpreter path on Python examples instead of wrapping
  # - see https://github.com/NixOS/nixpkgs/issues/22688 regarding use of --prefix / python.withPackages
  # - see https://github.com/NixOS/nixpkgs/issues/24693 regarding use of DYLD_FRAMEWORK_PATH on Darwin
  preFixup = ''
    printf "backend : Qt4Agg\n" > "$out/share/gnuradio/matplotlibrc"
    qtWrapperArgs+=(--prefix PYTHONPATH : $PYTHONPATH:$(toPythonPath "$out"))
    qtWrapperArgs+=(--set MATPLOTLIBRC "$out/share/gnuradio")
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    qtWrapperArgs+=(--set DYLD_FRAMEWORK_PATH /System/Library/Frameworks")
  '';

  meta = with stdenv.lib; {
    description = "Software Defined Radio (SDR) software";
    longDescription = ''
      GNU Radio is a free & open-source software development toolkit that
      provides signal processing blocks to implement software radios. It can be
      used with readily-available low-cost external RF hardware to create
      software-defined radios, or without hardware in a simulation-like
      environment. It is widely used in hobbyist, academic and commercial
      environments to support both wireless communications research and
      real-world radio systems.
    '';
    homepage = https://www.gnuradio.org;
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ bjornfor fpletz "Alexander Krimm <alex@wirew0rm.de>"];
  };
}
