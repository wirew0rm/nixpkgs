{ zlib, lib, stdenv, autoPatchelfHook, fetchurl, makeWrapper, libusb1, dpkg, gtk-sharp, mono }:
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
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libp/libps3000a/libps3000a_2.1.40-6r2131_amd64.deb";
      sha256 = "187bgpdvpmsxh9j9j4i2dg9rjrmn8qcmvskzfdb8w4r8r8jqgm3i";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libp/libps4000a/libps4000a_2.1.40-2r2131_amd64.deb";
      sha256 = "1pwrm4fk91n7sfz42a7w5w9pv881099ilggsmv86bbq4941kifkx";
    })
    (fetchurl{
      url = "https://labs.picotech.com/debian/pool/main/libp/libps6000/libps6000_2.1.40-6r2131_amd64.deb";
      sha256 = "1j7bxpyscf4fxd8pkmqgzwg78phxyd02kal39g0cw2vjsn94svms";
    })
  ];

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];
  buildInputs = [ libusb1 gtk-sharp mono];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    for source in ${toString srcs}; do
      dpkg-deb -x $source .
    done
    '';

  installPhase = ''
    ls -R
    mv ./opt/picoscope/include/**/*.h ./opt/picoscope/include/ --backup=t
    mv ./opt/picoscope/share/doc/libps3000a/usbtest picoscope_usbtest
    rm ./opt/picoscope/share/doc/**/usbtest
    mv ./opt/picoscope $out
    rm $out/bin/picoscope
    makeWrapper "${mono}/bin/mono" "$out/bin/picoscope" \
      --add-flags "$out/lib/PicoScope.GTK.exe" \
      --prefix MONO_GAC_PREFIX : "$out:${gtk-sharp}:${gtk-sharp.gtk}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ "$out" gtk-sharp gtk-sharp.gtk ]}
  '';

  # change autoPatchelfFile function of autoPatchelfHook to always add $out/lib to the rpath.
  # needed because a) only executables affected by runtimeDependencies and b) no substitutuion of $out
  preFixup= ''
    autoPatchelfFile() {
        local dep rpath="$out/lib" toPatch="$1"

        local interpreter
        interpreter="$(< "$NIX_CC/nix-support/dynamic-linker")"
        if isExecutable "$toPatch"; then
            runPatchelf --set-interpreter "$interpreter" "$toPatch"
            # shellcheck disable=SC2154
            # (runtimeDependencies is referenced but not assigned.)
            if [ -n "$runtimeDependencies" ]; then
                for dep in $runtimeDependencies; do
                    rpath="$rpath''${rpath:+:}$dep/lib"
                done
            fi
        fi

        echo "searching for dependencies of $toPatch" >&2

        # We're going to find all dependencies based on ldd output, so we need to
        # clear the RPATH first.
        runPatchelf --remove-rpath "$toPatch"

        # If the file is not a dynamic executable, ldd/sed will fail,
        # in which case we return, since there is nothing left to do.
        local missing
        missing="$(
            ldd "$toPatch" 2> /dev/null | \
                sed -n -e 's/^[\t ]*\([^ ]\+\) => not found.*/\1/p'
        )" || return 0

        # This ensures that we get the output of all missing dependencies instead
        # of failing at the first one, because it's more useful when working on a
        # new package where you don't yet know its dependencies.

        for dep in $missing; do
            echo -n "  $dep -> " >&2
            if findDependency "$dep" "$(getSoArch "$toPatch")"; then
                rpath="$rpath''${rpath:+:}''${foundDependency%/*}"
                echo "found: $foundDependency" >&2
            else
                echo "not found!" >&2
                autoPatchelfFailedDeps["$dep"]="$toPatch"
            fi
        done

        if [ -n "$rpath" ]; then
            echo "setting RPATH to: $rpath" >&2
            runPatchelf --set-rpath "$rpath" "$toPatch"
        fi
    }
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
