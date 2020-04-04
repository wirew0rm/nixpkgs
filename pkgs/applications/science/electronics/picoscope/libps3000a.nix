{ stdenv, fetchurl, libusb1, dpkg }:
stdenv.mkDerivation rec {
  pname = "libps3000a";
  version = "2.1.0-6r570";

  src = fetchurl{
    url = "https://labs.picotech.com/debian/pool/main/libp/libps3000a/${pname}_${version}_amd64.deb";
    sha256 = "1h1rs25hfdvzxxrb1kw3a4y8vijk8akviys9kg9dv14zg4gba447";
  };

  nativeBuildInputs = [ dpkg ];
  buildInputs = [ libusb1 ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = "dpkg-deb -x $src .";
  installPhase = "
    mv opt/picoscope $out
  ";

  meta = with stdenv.lib; {
    description = "library for picotech oscilloscope 3000a series";
    homepage = http://www.picotech.com/linux.html;
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = ["Alexander Krimm <alex@wirew0rm.de>"];
  };
}
