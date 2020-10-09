{ stdenv, fetchFromGitLab, cmake, pkgconfig, boost, gnuradio, log4cpp
, makeWrapper, cppunit, doxygen, git, root, picoscope
, pythonSupport ? true, python, swig
}:

assert pythonSupport -> python != null && swig != null;

stdenv.mkDerivation rec {
  pname = "gr-digitizers";
  version = "4.0.2";

  src = fetchFromGitLab {
    owner = "al.schwinn";
    repo = pname;
    rev = version;
    sha256 = "1lriiw4kqfiqzc53z39wlx42xq14qp2ik06w48nl2wimad7yrhlb";
  };

  # The include path for the picoscope driver api headers is hardcoded in the CMakeLists.txt
  prePatch = ''
    sed -i -e "s%/usr/include/picoscope%${picoscope}/include%g" CMakeLists.txt
  '';
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    cmake boost root picoscope gnuradio makeWrapper cppunit log4cpp doxygen git
  ] ++ stdenv.lib.optionals pythonSupport [ python swig ];

  postInstall = ''
    for prog in "$out"/bin/*; do
        wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  meta = with stdenv.lib; {
    description = "Gnuradio block for picoscope digitizers";
    homepage = "https://gitlab.com/al.schwinn/gr-digitizers";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wirew0rm ];
  };
}
