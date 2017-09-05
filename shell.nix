{ pkgs ? (import ( (import <nixpkgs>{}).fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f91f3a4c5a7672ead2d9a414acb1415a8bfb8260";
    sha256 = "1iandzsvs399j9wqvbsmm2yhnspi8hjsr4zxqqzizfg5wb0l57vr";
  }){})
, extraGhcPkgs ? (p: [])
}:

with pkgs;

let ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };
    hsenv = haskell.packages.ghc7102.ghcWithPackages
      (p: with p;
        [ cabal-install
          hprotoc                  # host protocol buffer code generator
          protocol-buffers         # host protocol buffer library
          aeson
        ]);
    haskell-packages = import ./nixpkgs/top-level/haskell-packages.nix { inherit pkgs callPackage stdenv; };
    ghc-android-env = haskell-packages.packages.ghc-android.ghcWithPackages
      (p: with p;
        [ aeson
          free
          protocol-buffers         # target protocol buffer library
          protocol-buffers-descriptor
          text-binary
          network-simple
          # useful dependencies that might be used a lot
          # but themselves don't change that much
          monad-loops
          lens
          diagrams-lib
          MonadRandom
          data-default
          colour
          linear
          hoppy-runtime
          StateVar
          time
          contravariant
        ]
        ++ extraGhcPkgs { inherit pkgs androidenv; ghcAndroidPkgs = p;  }
        );
    protobuf-android = import ./protobuf.nix {inherit protobuf androidndk ndkWrapper;};
in stdenv.mkDerivation {
     name = "android-env-shell";
     buildInputs =
       [ git gitRepo gnupg python2 curl procps openssl gnumake nettools
         androidenv.platformTools androidenv.androidsdk_5_1_1_extras
         androidenv.androidndk
         jdk schedtool utillinux m4 gperf
         perl libxml2 zip unzip bison flex lzop
         hsenv ghc-android-env ndkWrapper
         protobuf zlib
         pkgconfig
         which file
         protobuf-android
       ];
     shellHook = ''
        export USE_CCACHE=1
        export JAVA_HOME=${jdk.home}
        export ANDROID_JAVA_HOME=${jdk.home}
        export ANDROID_HOME=${androidenv.androidsdk_5_1_1_extras}/libexec/android-sdk-linux
        export ANDROID_NDK_HOME=${androidenv.androidndk}/libexec/${androidenv.androidndk.name}
        export ANDROID_NDK_ROOT=${androidenv.androidndk}/libexec/${androidenv.androidndk.name}
        export PROTOBUF=${protobuf-android}
        export PKG_CONFIG_PATH=$PROTOBUF/lib/pkgconfig:$PKG_CONFIG_PATH
        export ANDROID_SDK_ROOT=$ANDROID_HOME
        export NDK_ROOT=$ANDROID_NDK_ROOT
     '';
   }




