{ lib, stdenv, autoPatchelfHook, fetchurl, makeWrapper, libusb1, dpkg, libps3000a, gtk-sharp-2_0, mono }:
with lib;
stdenv.mkDerivation rec {
  pname = "picoscope";
  version = "6.14.17-4r544";

  src = fetchurl{
    url = "http://labs.picotech.com/debian/pool/main/p/picoscope/${pname}_${version}_all.deb";
    sha256 = "09qmdfw829h04gvp45mg6ygdvkzml63l1md2vqa45pksl24a7ghy";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];
  buildInputs = [ libusb1 libps3000a gtk-sharp-2_0 mono];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = "dpkg-deb -x $src .";
  installPhase = ''
    mv opt/picoscope $out
    rm $out/bin/picoscope
    makeWrapper "${mono}/bin/mono" "$out/bin/picoscope" \
      --add-flags "$out/lib/PicoScope.GTK.exe" \
      --prefix MONO_GAC_PREFIX : ${gtk-sharp-2_0} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk-sharp-2_0 gtk-sharp-2_0.gtk ]}
  '';

  meta = with stdenv.lib; {
    description = "Oscilloscope application that works with all PicoScope models";
    longDescription = ''
      PicoScope for Linux is a powerful oscilloscope application that works with all PicoScope models. The most important features from PicoScope for Windows are included—scope, spectrum analyzer, advanced triggers, automated measurements, interactive zoom, persistence modes and signal generator control. More features are being added all the time.
      Waveform captures can be saved for off-line analysis, and shared with PicoScope for Linux, PicoScope for macOS and PicoScope for Windows users, or exported in text, CSV and MathWorks MATLAB 4 formats.
      '';
    homepage = http://www.picotech.com/linux.html;
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = ["Alexander Krimm <alex@wirew0rm.de>"];
  };
}
