{ stdenv
, mkDerivation
, fetchFromGitLab
, picoscope
, root
, gnuradio
, boost
, log4cpp
, fetchurl
}:

let
  pname = "gr-digitizers";
  version = {
    "3.7" = "4.0.2";
  }.${gnuradio.versionAttr.major};
  src = fetchFromGitLab {
    owner = "al.schwinn";
    repo = pname;
    rev = version;
    sha256 = {
      "3.7" = "1lriiw4kqfiqzc53z39wlx42xq14qp2ik06w48nl2wimad7yrhlb";
    }.${gnuradio.versionAttr.major};
  };
in mkDerivation {
  inherit pname version src;

  patches = [ ./cast.patch ];

  # The include path for the picoscope driver api headers is hardcoded in the CMakeLists.txt
  prePatch = ''
    sed -i -e "s%/usr/include/picoscope%${picoscope}/include%g" CMakeLists.txt
  '';
  buildInputs = [ root picoscope boost log4cpp ];

  cmakeFlags = [ "-DENABLE_GR_LOG=OFF" ];
  disabled = ["3.8"];

  meta = with stdenv.lib; {
    description = "Gnuradio block for picoscope digitizers";
    homepage = "https://gitlab.com/al.schwinn/gr-digitizers";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wirew0rm ];
  };
}

