{ lib, stdenv, autoPatchelfHook, fetchurl, makeWrapper, libusb1, dpkg, libps3000a, gtk-sharp-2_0, mono }:
with lib;
stdenv.mkDerivation rec {
  pname = "picoscope";
  version = "6.14.17-4r544";

  srcs = [
    (fetchurl{
      url = "http://labs.picotech.com/debian/pool/main/p/picoscope/${pname}_${version}_all.deb";
      sha256 = "09qmdfw829h04gvp45mg6ygdvkzml63l1md2vqa45pksl24a7ghy";
    })
    (fetchurl{
      url = "http://labs.picotech.com/debian/pool/main/libp/libpicoipp/libpicoipp_1.3.0-4r29_amd64.deb";
      sha256 = "0j5di2sjk0rgc7zx2szws98giqgl81d13hnr2fzgir7yvb24cv5s";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libp/libpicohrdl/libpicohrdl_2.0.17-1r1441_amd64.deb";
      sha256 = "183912vkq6mlzp3n5c08d0psn1v2nq2jq0dzj6jzalz5jzpxfmis";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libu/libusbdrdaq/libusbdrdaq_2.0.34-1r2002_amd64.deb";
      sha256 = "1dmvkqnwsx70vdm009b87nnym3is8lvh1yaiazybv7wcnphwf6ia";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libu/libusbpt104/libusbpt104_2.0.17-1r1441_amd64.deb";
      sha256 = "1cfsv6q7nk0pj5mar5si0aradlq1sr12djh93isdv97bhvkwfhjq";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libu/libusbtc08/libusbtc08_2.0.17-1r1441_amd64.deb";
      sha256 = "0azjl7hl0si6ymlr28yk4cvn0csn0gk3b4mj0macwbdd4k4bq4nb";
    })
  ];

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];
  buildInputs = [ libusb1 libps3000a gtk-sharp-2_0 mono];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    for source in ${toString srcs}; do
      dpkg-deb -x $source .
    done
    '';
  installPhase = ''
    mv ./opt/picoscope $out
    rm $out/bin/picoscope
    makeWrapper "${mono}/bin/mono" "$out/bin/picoscope" \
      --add-flags "$out/lib/PicoScope.GTK.exe" \
      --prefix MONO_GAC_PREFIX : ${gtk-sharp-2_0} \
      --prefix MONO_GAC_PREFIX : ${libps3000a} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk-sharp-2_0 gtk-sharp-2_0.gtk libps3000a ]}
  '';

  meta = with stdenv.lib; {
    description = "Oscilloscope application that works with all PicoScope models";
    longDescription = ''
      PicoScope for Linux is a powerful oscilloscope application that works with all PicoScope models. The most important features from PicoScope for Windows are included—scope, spectrum analyzer, advanced triggers, automated measurements, interactive zoom, persistence modes and signal generator control. More features are being added all the time.
      Waveform captures can be saved for off-line analysis, and shared with PicoScope for Linux, PicoScope for macOS and PicoScope for Windows users, or exported in text, CSV and MathWorks MATLAB 4 formats.
      '';
    homepage = "http://www.picotech.com/linux.html";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wirew0rm ];
  };
}
