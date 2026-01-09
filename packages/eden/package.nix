{ pkgs, ... }:

let
  version = "v0.0.4-rc3";
  src = pkgs.fetchgit {
    url = "https://git.eden-emu.dev/eden-emu/eden.git";
    rev = version;
    sha256 = "sha256-w5H6r9R3HuMTRw49GpMiIS9ELPmBQnZkQZ8buXkZkCA=";
  };
  qtDependencies = with pkgs.qt6Packages; [
    qt5compat
    qtbase
    qtmultimedia
    qttools
    qtwayland
  ];
  xbyak = pkgs.fetchFromGitHub {
    owner = "herumi";
    repo = "xbyak";
    rev = "v7.22";
    sha256 = "sha256-ZmdOjO5MbY+z+hJEVgpQzoYGo5GAFgwAPiv4vs/YMUA=";
  };
  sirit = pkgs.fetchFromGitHub {
    owner = "eden-emulator";
    repo = "sirit";
    rev = "v1.0.2";
    sha256 = "sha256-0wjpQm8tWHeEebSiRGs7b8LYcA2d4MEbHuffP2eSNGU=";
  };
  mcl = pkgs.applyPatches {
    name = "mcl";
    src = pkgs.fetchFromGitHub {
      owner = "azahar-emu";
      repo = "mcl";
      rev = "0.1.14"; # specified is 0.1.12, does not seem to be a valid tag (???)
      sha256 = "sha256-7lHOjlUvCQsct/pijn0M0OOG5LpExmXwB6kH+ostA2I=";
    };
    patches = [
      ./patches/mcl-assert-macro.patch
    ];
  };
  quazip-qt6 = pkgs.fetchFromGitHub {
    owner = "crueter-archive";
    repo = "quazip-qt6";
    rev = "v1.5-qt6";
    sha256 = "sha256-Jp+v7uwoPxvarzOclgSnoGcwAPXKnm23yrZKtjJCHro=";
  };
  frozen = pkgs.fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "frozen";
    rev = "61dce5ae18ca59931e27675c468e64118aba8744";
    sha256 = "sha256-zIczBSRDWjX9hcmYWYkbWY3NAAQwQtKhMTeHlYp4BKk=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit version src;

  pname = "eden";

  SCCACHE_DIR = "/var/cache/sccache";

  nativeBuildInputs = with pkgs; [
    cmake
    clang
    ninja
    gnumake
    pkg-config
    git
    python3
    jq
    patch
    sccache
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs =
    with pkgs;
    [
      openssl
      boost
      fmt
      nlohmann_json
      lz4
      zlib
      zstd
      enet
      libopus
      mbedtls
      libusb1
      cubeb
      SDL2
      ffmpeg-headless

      # Note from Deps.md in the upstream:
      # Certain other dependencies will be fetched by CPM regardless.
      # System packages can be used for these libraries,
      # but many are either not packaged by most distributions OR have issues when used by the system:
      simpleini
      stb
      renderdoc
      nasm
      opencl-headers
      httplib
      cpp-jwt
      unordered_dense
      tzdata
      frozen

      # Vulkan
      glslang # @grok is this vulkan?
      vulkan-headers
      vulkan-loader
      vulkan-memory-allocator
      vulkan-utility-libraries
      spirv-headers
      spirv-tools

      # Optionals
      gamemode
      discord-rpc
    ]
    ++ qtDependencies;

  cmakeFlags = [
    "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
    "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache"
    "-DCPM_SOURCE_CACHE=/var/cache/cpm"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCPM_DOWNLOAD_ALL=OFF"
    "-DCPM_xbyak_SOURCE=${xbyak}"
    "-DCPM_sirit_SOURCE=${sirit}"
    "-DCPM_mcl_SOURCE=${mcl}"
    "-DCPM_QuaZip-Qt6_SOURCE=${quazip-qt6}"
    "-DCPM_frozen_SOURCE=${frozen}"
    "-DYUZU_TZDB_PATH=${pkgs.tzdata}/share/"
  ];

  preConfigure = ''
    rm -rf .patch/mcl
  '';
  buildDir = "Release";

  installPhase = ''
    mkdir -p $out/bin
    ls
    cp -r Release/eden* $out/bin/
  '';

  patches = [
    ./patches/disable-eden-mcl-patching.patch
  ];

}
