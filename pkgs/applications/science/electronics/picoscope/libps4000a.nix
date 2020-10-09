{ stdenv, autoPatchelfHook, fetchurl, libusb1, zlib, dpkg }:
stdenv.mkDerivation rec {
  pname = "libps4000a";
  version = "2.1.40-2r2131";

  src = fetchurl{
    url = "https://labs.picotech.com/debian/pool/main/libp/${pname}/${pname}_${version}_amd64.deb";
    sha256 = "1j7bxpyscf4fxd8pkmqgzwg78phxyd02kal39g0cw2vjsn94svms";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = [ zlib libusb1 stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = "dpkg-deb -x $src .";
  installPhase = "
    mv opt/picoscope $out
  ";

  meta = with stdenv.lib; {
    description = "library for picotech oscilloscope 4000a series";
    homepage = http://www.picotech.com/linux.html;
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wirew0rm ];
  };
}
