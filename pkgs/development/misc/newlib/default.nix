{ stdenv, fetchurl, buildPackages }:

let version = "3.0.0";
in stdenv.mkDerivation {
  name = "newlib-${version}";
  src = fetchurl {
    url = "ftp://sourceware.org/pub/newlib/newlib-${version}.tar.gz";
    sha256 = "0chka3szh50krcz2dcxcsr1v1i000jylwnsrp2pgrrblxqsn6mn8";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  # newlib expects CC to build for build platform, not host platform
  preConfigure = ''
    export CC=cc
  '';

  # apply overlay for xtensa processors
  prePatch = stdenv.lib.optional
    ( stdenv.targetPlatform.parsed.cpu == stdenv.lib.systems.parse.cpuTypes.xtensa )
    "install -t ./newlib/libc/sys/xtensa/include/xtensa/config ${stdenv.targetPlatform.platform.xtensaOverlay}/newlib/newlib/libc/sys/xtensa/include/xtensa/config/core-isa.h -D;";

  configurePlatforms = [ "build" "target" ];
  configureFlags = [
    "--host=${stdenv.buildPlatform.config}"

    "--disable-newlib-supplied-syscalls"
    "--disable-nls"
    "--enable-newlib-io-long-long"
    "--enable-newlib-register-fini"
    "--enable-newlib-retargetable-locking"
  ];

  dontDisableStatic = true;

  passthru = {
    incdir = "/${stdenv.targetPlatform.config}/include";
    libdir = "/${stdenv.targetPlatform.config}/lib";
  };
}
