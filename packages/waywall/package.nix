{ pkgs, ... }:

let
  version = "0.2025.12.30";
  src = pkgs.fetchFromGitHub {
    owner = "tesselslate";
    repo = "waywall";
    rev = version;
    sha256 = "sha256-idtlOXT3RGjAOMgZ+e5vwZnxd33snc4sIjq0G6TU7HU=";
  };
in
pkgs.stdenv.mkDerivation {

  inherit src version;
  pname = "waywall";

  nativeBuildInputs = with pkgs; [
    makeWrapper
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = with pkgs; [
    libGL
    libspng
    libxkbcommon
    luajit
    wayland
    wayland-protocols
    xorg.libxcb
    xwayland
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 waywall/waywall -t $out/bin
    wrapProgram $out/bin/waywall \
        --prefix PATH: ${pkgs.lib.makeBinPath [ pkgs.xwayland ]}
    runHook postInstall
  '';

  meta = {
    description = "waywall is a Wayland compositor that provides various convenient features (key rebinding, Ninjabrain Bot support, etc) for Minecraft speedrunning.";
    mainProgram = "waywall";
    license = pkgs.lib.licenses.gpl3Only;
  };

}
