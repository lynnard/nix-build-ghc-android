{ pkgs, androidenv }:

with import ./lib.nix { inherit pkgs; };

self: super: {

  mkDerivation = drv: super.mkDerivation (drv // { doHaddock = false; });

  # Suitable LLVM version.
  llvmPackages = pkgs.llvmPackages_35;

  inherit (pkgs.haskell.packages.ghc7102) jailbreak-cabal alex happy;


  # Disable GHC 7.10.x core libraries.
  array = null;
  base = null;
  binary = null;
  bin-package-db = null;
  bytestring = null;
  Cabal = null;
  containers = null;
  deepseq = null;
  directory = null;
  filepath = null;
  ghc-prim = null;
  haskeline = null;
  hoopl = null;
  hpc = null;
  integer-gmp = null;
  pretty = null;
  process = null;
  rts = null;
  template-haskell = null;
  terminfo = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  cmdargs = disableCabalFlag super.cmdargs "quotation";

  # Cabal_1_22_1_1 requires filepath >=1 && <1.4
  cabal-install = dontCheck (super.cabal-install.override { Cabal = null; });

  # Don't use jailbreak built with Cabal 1.22.x because of https://github.com/peti/jailbreak-cabal/issues/9.
  Cabal_1_23_0_0 = overrideCabal super.Cabal_1_22_4_0 (drv: {
    version = "1.23.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "haskell";
      repo = "cabal";
      rev = "fe7b8784ac0a5848974066bdab76ce376ba67277";
      sha256 = "1d70ryz1l49pkr70g8r9ysqyg1rnx84wwzx8hsg6vwnmg0l5am7s";
    };
    jailbreak = false;
    doHaddock = false;
    postUnpack = "sourceRoot+=/Cabal";
  });

  /* idris = */
  /*   let idris' = overrideCabal super.idris (drv: { */
  /*     # "idris" binary cannot find Idris library otherwise while building. */
  /*     # After installing it's completely fine though. Seems like Nix-specific */
  /*     # issue so not reported. */
  /*     preBuild = "export LD_LIBRARY_PATH=$PWD/dist/build:$LD_LIBRARY_PATH"; */
  /*     # https://github.com/idris-lang/Idris-dev/issues/2499 */
  /*     librarySystemDepends = (drv.librarySystemDepends or []) ++ [pkgs.gmp]; */
  /*   }); */
  /*   in idris'.overrideScope (self: super: { */
  /*     # https://github.com/idris-lang/Idris-dev/issues/2500 */
  /*     zlib = self.zlib_0_5_4_2; */
  /*   }); */

  Extra = appendPatch super.Extra (pkgs.fetchpatch {
    url = "https://github.com/seereason/sr-extra/commit/29787ad4c20c962924b823d02a7335da98143603.patch";
    sha256 = "193i1xmq6z0jalwmq0mhqk1khz6zz0i1hs6lgfd7ybd6qyaqnf5f";
  });

  # haddock: No input file(s).
  nats = dontHaddock super.nats;
  bytestring-builder = dontHaddock super.bytestring-builder;

  # We have time 1.5
  time-locale-compat = disableCabalFlag super.time-locale-compat "old-locale";
  aeson = let aeson' = overrideCabal super.aeson_1_0_0_0 (drv: {
      version = "1.0.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "lynnard";
        repo = "aeson";
        rev = "acf53242c403463dd33454919e56116c4e2354dc";
        sha256 = "1qvxcay67b5q14s0vlgzm5m04ad68xiv6h48n5z7yg1fr9wb8cfm";
      };
    });
    in disableCabalFlag aeson' "old-locale";

  # requires filepath >=1.1 && <1.4
  Glob = doJailbreak super.Glob;

  # Setup: At least the following dependencies are missing: base <4.8
  hspec-expectations = overrideCabal super.hspec-expectations (drv: {
    postPatch = "sed -i -e 's|base < 4.8|base|' hspec-expectations.cabal";
  });
  utf8-string = overrideCabal super.utf8-string (drv: {
    postPatch = "sed -i -e 's|base >= 3 && < 4.8|base|' utf8-string.cabal";
  });
  pointfree = doJailbreak super.pointfree;

  # acid-state/safecopy#25 acid-state/safecopy#26
  safecopy = dontCheck (super.safecopy);

  # test suite broken, some instance is declared twice.
  # https://bitbucket.org/FlorianHartwig/attobencode/issue/1
  AttoBencode = dontCheck super.AttoBencode;

  # Test suite fails with some (seemingly harmless) error.
  # https://code.google.com/p/scrapyourboilerplate/issues/detail?id=24
  syb = dontCheck super.syb;

  # Test suite has stricter version bounds
  retry = dontCheck super.retry;

  # test/System/Posix/Types/OrphansSpec.hs:19:13:
  #    Not in scope: type constructor or class ‘Int32’
  base-orphans = dontCheck super.base-orphans;

  # Test suite fails with time >= 1.5
  http-date = dontCheck super.http-date;


  # Upstream was notified about the over-specified constraint on 'base'
  # but refused to do anything about it because he "doesn't want to
  # support a moving target". Go figure.
  barecheck = doJailbreak super.barecheck;

  # https://github.com/kazu-yamamoto/unix-time/issues/30
  unix-time = dontCheck super.unix-time;

  /* present = appendPatch super.present (pkgs.fetchpatch { */
  /*   url = "https://github.com/chrisdone/present/commit/6a61f099bf01e2127d0c68f1abe438cd3eaa15f7.patch"; */
  /*   sha256 = "1vn3xm38v2f4lzyzkadvq322f3s2yf8c88v56wpdpzfxmvlzaqr8"; */
  /* }); */

  /* ghcjs-prim = self.callPackage ({ mkDerivation, fetchgit, primitive }: mkDerivation { */
  /*   pname = "ghcjs-prim"; */
  /*   version = "0.1.0.0"; */
  /*   src = fetchgit { */
  /*     url = git://github.com/ghcjs/ghcjs-prim.git; */
  /*     rev = "dfeaab2aafdfefe46bf12960d069f28d2e5f1454"; # ghc-7.10 branch */
  /*     sha256 = "19kyb26nv1hdpp0kc2gaxkq5drw5ib4za0641py5i4bbf1g58yvy"; */
  /*   }; */
  /*   buildDepends = [ primitive ]; */
  /*   license = pkgs.stdenv.lib.licenses.bsd3; */
  /* }) {}; */

  # diagrams/monoid-extras#19
  monoid-extras = overrideCabal super.monoid-extras (drv: {
    prePatch = "sed -i 's|4\.8|4.9|' monoid-extras.cabal";
  });

  # diagrams/statestack#5
  /* statestack = overrideCabal super.statestack (drv: { */
  /*   prePatch = "sed -i 's|4\.8|4.9|' statestack.cabal"; */
  /* }); */

  # diagrams/diagrams-core#83
  /* diagrams-core = overrideCabal super.diagrams-core (drv: { */
  /*   prePatch = "sed -i 's|4\.8|4.9|' diagrams-core.cabal"; */
  /* }); */

  timezone-series = doJailbreak super.timezone-series;
  timezone-olson = doJailbreak super.timezone-olson;
  libmpd = dontCheck super.libmpd;

  # Workaround for a workaround, see comment for "ghcjs" flag.
  /* jsaddle = let jsaddle' = disableCabalFlag super.jsaddle "ghcjs"; */
  /*           in addBuildDepends jsaddle' [ self.glib self.gtk3 self.webkitgtk3 */
  /*                                         self.webkitgtk3-javascriptcore ]; */

  # https://github.com/cartazio/arithmoi/issues/1
  arithmoi = markBroken super.arithmoi;
  NTRU = dontDistribute super.NTRU;
  arith-encode = dontDistribute super.arith-encode;
  barchart = dontDistribute super.barchart;
  constructible = dontDistribute super.constructible;
  cyclotomic = dontDistribute super.cyclotomic;
  diagrams = dontDistribute super.diagrams;
  diagrams-contrib = dontDistribute super.diagrams-contrib;
  enumeration = dontDistribute super.enumeration;
  ghci-diagrams = dontDistribute super.ghci-diagrams;
  ihaskell-diagrams = dontDistribute super.ihaskell-diagrams;
  nimber = dontDistribute super.nimber;
  pell = dontDistribute super.pell;
  quadratic-irrational = dontDistribute super.quadratic-irrational;

  # https://github.com/lymar/hastache/issues/47
  hastache = dontCheck super.hastache;

  # The compat library is empty in the presence of mtl 2.2.x.
  mtl-compat = dontHaddock super.mtl-compat;

  # https://github.com/bos/bloomfilter/issues/11
  bloomfilter = dontHaddock (appendConfigureFlag super.bloomfilter "--ghc-option=-XFlexibleContexts");

  # https://github.com/ocharles/tasty-rerun/issues/5
  tasty-rerun = dontHaddock (appendConfigureFlag super.tasty-rerun "--ghc-option=-XFlexibleContexts");

  # http://hub.darcs.net/ivanm/graphviz/issue/5
  graphviz = dontCheck (dontJailbreak (appendPatch super.graphviz ./patches/graphviz-fix-ghc710.patch));

  # Broken with GHC 7.10.x.
  aeson_0_7_0_6 = markBroken super.aeson_0_7_0_6;
  Cabal_1_20_0_3 = markBroken super.Cabal_1_20_0_3;
  cabal-install_1_18_1_0 = markBroken super.cabal-install_1_18_1_0;
  containers_0_4_2_1 = markBroken super.containers_0_4_2_1;
  control-monad-free_0_5_3 = markBroken super.control-monad-free_0_5_3;
  haddock-api_2_15_0_2 = markBroken super.haddock-api_2_15_0_2;
  QuickCheck_1_2_0_1 = markBroken super.QuickCheck_1_2_0_1;
  QuickCheck_2_9_1 = markBroken super.QuickCheck_2_9_1;
  seqid-streams_0_1_0 = markBroken super.seqid-streams_0_1_0;
  vector_0_10_9_2 = markBroken super.vector_0_10_9_2;
  hoopl_3_10_2_0 = markBroken super.hoopl_3_10_2_0;

  # https://github.com/HugoDaniel/RFC3339/issues/14
  timerep = dontCheck super.timerep;

  # Upstream has no issue tracker.
  llvm-base-types = markBroken super.llvm-base-types;
  llvm-analysis = dontDistribute super.llvm-analysis;
  llvm-data-interop = dontDistribute super.llvm-data-interop;
  llvm-tools = dontDistribute super.llvm-tools;

  # Upstream has no issue tracker.
  MaybeT = markBroken super.MaybeT;
  grammar-combinators = dontDistribute super.grammar-combinators;

  # Required to fix version 0.91.0.0.
  wx = dontHaddock (appendConfigureFlag super.wx "--ghc-option=-XFlexibleContexts");

  # Upstream has no issue tracker.
  Graphalyze = markBroken super.Graphalyze;
  gbu = dontDistribute super.gbu;
  SourceGraph = dontDistribute super.SourceGraph;

  # Upstream has no issue tracker.
  markBroken = super.protocol-buffers;
  caffegraph = dontDistribute super.caffegraph;

  # Deprecated: https://github.com/mikeizbicki/ConstraintKinds/issues/8
  ConstraintKinds = markBroken super.ConstraintKinds;
  HLearn-approximation = dontDistribute super.HLearn-approximation;
  HLearn-distributions = dontDistribute super.HLearn-distributions;
  HLearn-classification = dontDistribute super.HLearn-classification;

  # Doesn't work with LLVM 3.5.
  llvm-general = markBroken super.llvm-general;

  # Inexplicable haddock failure
  # https://github.com/gregwebs/aeson-applicative/issues/2
  aeson-applicative = dontHaddock super.aeson-applicative;

  # GHC 7.10.1 is affected by https://github.com/srijs/hwsl2/issues/1.
  hwsl2 = dontCheck super.hwsl2;

  # https://github.com/haskell/haddock/issues/427
  haddock = dontCheck super.haddock;

  # The tests in vty-ui do not build, but vty-ui itself builds.
  vty-ui = enableCabalFlag super.vty-ui "no-tests";

  # https://github.com/DanielG/cabal-helper/issues/10
  cabal-helper = dontCheck super.cabal-helper;

  # no integer-gmp
  cryptonite = disableCabalFlag super.cryptonite "integer-gmp";

  # no use of const_str
  zlib = overrideCabal super.zlib (drv: {
    prePatch = ''sed -i 's|#{const_str ZLIB_VERSION}|\"${pkgs.zlib.version}\"|' Codec/Compression/Zlib/Stream.hsc''; 
  });

  # no template haskell
  monad-logger = disableCabalFlag super.monad-logger "template_haskell";

  QuickCheck = disableCabalFlag super.QuickCheck "templateHaskell";

  # do not use getProtocolNumber
  /* network = appendPatch (appendPatch super.network ./patches/network-android.patch) ./patches/network-tcp-for-bionic.patch; */
  # use the older version of network for now
  network = let network' = self.callPackage
    ({ mkDerivation, base, bytestring, HUnit, test-framework
     , test-framework-hunit, unix
     }:
     mkDerivation {
       pname = "network";
       version = "2.6.2.1";
       sha256 = "a3fda15c9bbe2c7274d97f40398c6cf8d1d3a9fe896fbf6531e1bfc849bb1bfa";
       libraryHaskellDepends = [ base bytestring unix ];
       testHaskellDepends = [
         base bytestring HUnit test-framework test-framework-hunit
       ];
       homepage = "https://github.com/haskell/network";
       description = "Low-level networking interface";
       license = pkgs.stdenv.lib.licenses.bsd3;
     }) {};
     in appendPatch (appendPatch network' ./patches/network-android.patch) ./patches/network-tcp-for-bionic.patch;
  /* network = self.callPackage */
  /*   ({ mkDerivation, base, bytestring, doctest, HUnit, test-framework */
  /*    , test-framework-hunit, unix, autoconf */
  /*    }: */
  /*    mkDerivation { */
  /*      pname = "network"; */
  /*      version = "2.6.3.1"; */
  /*      src = pkgs.fetchFromGitHub { */
  /*        owner = "lynnard"; */
  /*        repo = "network"; */
  /*        rev = "2eb5a79d1c607e212b2100107e8ab8d9c8f03c09"; */
  /*        sha256 = "0wnpsfr5palppvrl31cmbd7ldld468sdsy1025w2fkwdfdpafx15"; */
  /*      }; */
  /*      libraryHaskellDepends = [ base bytestring unix ]; */
  /*      testHaskellDepends = [ */
  /*        base bytestring doctest HUnit test-framework test-framework-hunit */
  /*      ]; */
  /*      doCheck = false; */
  /*      homepage = "https://github.com/haskell/network"; */
  /*      description = "Low-level networking interface"; */
  /*      license = pkgs.stdenv.lib.licenses.bsd3; */
  /*      buildTools = [ autoconf ]; */
  /*      preConfigure = "env autoreconf"; */
  /*    }) {}; */

  double-conversion = overrideCabal super.double-conversion (drv: {
    version = "2.0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "bos";
      repo = "double-conversion";
      rev = "f4c29ec8faca989b988788651e0286e94439a1c6";
      sha256 = "1i1q0vq7yxsaik7jcbjr26wgpkf5nx21yx1k1crcnrkdivaskfgh";
    };
  });

  reflection = disableCabalFlag super.reflection "template-haskell";

  # reflex related changes
  bifunctors = overrideCabal super.bifunctors (drv: {
     postPatch = "sed -i -e 's|Data.Bifunctor.TH|--Data.Bifunctor.TH|' bifunctors.cabal"; 
  });
  dependent-sum = self.callPackage
    ({ mkDerivation, base }:
     mkDerivation {
       pname = "dependent-sum";
       version = "0.4";
       sha256 = "07hs9s78wiybwjwkal2yq65hdavq0gg1h2ld7wbph61s2nsfrpm8";
       libraryHaskellDepends = [ base ];
       homepage = "https://github.com/mokus0/dependent-sum";
       description = "Dependent sum type";
       license = "unknown";
     }) {};
  dependent-map = self.callPackage
    ({ mkDerivation, base, containers, dependent-sum, semigroups }:
     mkDerivation {
       pname = "dependent-map";
       version = "0.2.4.0";
       sha256 = "0il2naf6gdkvkhscvqd8kg9v911vdhqp9h10z5546mninnyrdcsx";
       libraryHaskellDepends = [ base containers dependent-sum semigroups ];
       homepage = "https://github.com/mokus0/dependent-map";
       description = "Dependent finite maps (partial dependent products)";
       license = "unknown";
     }) {};

  # ekmett/linear#74
  /* linear = overrideCabal super.linear (drv: { */
  /*   prePatch = "sed -i 's/-Werror//g' linear.cabal"; */
  /* }); */
  linear = disableCabalFlag super.linear "template-haskell";
  active = overrideCabal super.active (drv: {
    version = "0.2.0.11";
    src = pkgs.fetchFromGitHub {
      owner = "lynnard";
      repo = "active";
      rev = "c585b08274ef55b0d8bd1365d50b6a16a91f6282";
      sha256 = "1pg417nh1cybwjc9y5gm39qvckfvw6f55cs21a54g8wink12sha9";
    };
  });
  diagrams-lib = overrideCabal super.diagrams-lib (drv: {
    version = "1.3.1.3";
    src = pkgs.fetchFromGitHub {
      owner = "lynnard";
      repo = "diagrams-lib";
      rev = "7aa513064165633430d4815a31c035c9a4ce3550";
      sha256 = "1aw8bh2y4iwyjxk1xfdx2wsvyln425r0fgzp89ck729898mi99zy";
    };
  });

  # hoppy-runtime
  hoppy-runtime = overrideCabal super.hoppy-runtime (drv: {
    version = "0.3.0";
    sha256 = "1nd9mgzqnak420dcifldq09c7sph7mf8llrsfagphq9aqhw3lij4";
  });

  # MonadRandom
  MonadRandom = self.callPackage
    ({ mkDerivation, base, mtl, random, transformers
     , transformers-compat, fail, primitive
     }:
     mkDerivation {
       pname = "MonadRandom";
       version = "0.5.1";
       sha256 = "11qdfghizww810vdj9ac1f5qr5kdmrk40l6w6qh311bjh290ygwy";
       libraryHaskellDepends = [
         base mtl random transformers transformers-compat fail primitive
       ];
       description = "Random-number generation monad";
       license = "unknown";
     }) {};
}
