{ stdenv, fetchFromGitHub, cmake, pkgconfig, boost, orc
  # required python Packages: Mako, six
  , pythonPackages
}:

stdenv.mkDerivation rec {
  pname = "volk";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "gnuradio";
    repo = "volk";
    rev = "v${version}";
    sha256 = "1f3r76yxjw22fl3zvv99wa7dw1sm4wgizn40p17cr8jzva6ypc05";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ boost orc ];

  propagatedBuildInputs = with pythonPackages; [ Mako six ];

  NIX_LDFLAGS = "-lpthread";

  meta = with stdenv.lib; {
    description = "Vector-Optimized Library of Kernels";
    longDescription = ''
      VOLK is the Vector-Optimized Library of Kernels. It is a free library, currently offered under the GPLv3, that contains kernels of hand-written SIMD code for different mathematical operations. Since each SIMD architecture can be very different and no compiler has yet come along to handle vectorization properly or highly efficiently, VOLK approaches the problem differently.

For each architecture or platform that a developer wishes to vectorize for, a new proto-kernel is added to VOLK. At runtime, VOLK will select the correct proto-kernel. In this way, the users of VOLK call a kernel for performing the operation that is platform/architecture agnostic. This allows us to write portable SIMD code that is optimized for a variety of platforms.

VOLK was introduced as a part of GNU Radio in late 2010 based on code released in the public domain. In 2015 it was released as an independent library for use by a wider audience.
    '';
    homepage = http://libvolk.org;
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ wirew0rm ];
  };
}
