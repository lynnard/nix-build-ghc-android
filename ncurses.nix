{ stdenv, fetchurl, androidndk, ndkWrapper }: 

stdenv.mkDerivation rec {
  name = "ncurses-5.9";

  src = fetchurl {
    url = "mirror://gnu/ncurses/${name}.tar.gz";
    sha256 = "0fsn7xis81za62afan0vvm38bvgzg5wfmv1m86flqcj0nj7jjilh";
  };

  # gcc-5.patch should be removed after 5.9
  # patches = [ ./clang.patch ./gcc-5.patch ];

  configureFlags = [ "--host=arm"
                     "--with-build-cc=${ndkWrapper}/bin/arm-linux-androideabi-gcc"
		     "--with-build-cpp=${ndkWrapper}/bin/arm-linux-androideabi-cpp"
                     "--enable-static"
                     "--disable-shared"
                     "--without-manpages"
                     "--without-debug"
		     "--without-termlib"
		     "--without-ticlib"
		     "--without-cxx" ];

  buildInputs = []; 

  preConfigure = ''
    configureFlagsArray+=("--includedir=$out/include")
    export NDK=${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
    export NDK_TARGET=arm-linux-androideabi
    #export CC=${ndkWrapper}/bin/$NDK_TARGET-gcc
    #export CPP=${ndkWrapper}/bin/$NDK_TARGET-cpp
    #export CXX=${ndkWrapper}/bin/$NDK_TARGET-g++
    export LD=${ndkWrapper}/bin/$NDK_TARGET-ld
    #export RANLIB=${ndkWrapper}/bin/$NDK_TARGET-gcc-ranlib
    #export NM=${ndkWrapper}/bin/$NDK_TARGET-gcc-nm
    export PKG_CONFIG_LIBDIR="$out/lib/pkgconfig"
    mkdir -p "$PKG_CONFIG_LIBDIR"
  '';

  selfNativeBuildInput = true;

  enableParallelBuilding = true;

  doCheck = false;




  #passthru = {
  #  ldflags = "-lncurses";
  #  inherit unicode abiVersion;
  #};
}
    #/home/wavewave/repo/workspace/ghctest/arm-linux-androideabi-gcc
#    export CFLAGS=--sysroot=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/platforms/android-21/arch-arm