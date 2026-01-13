{ pkgs, ... }:
let
  version = "1.5.1";
  src = pkgs.fetchurl {
    url = "https://github.com/Ninjabrain1/Ninjabrain-Bot/releases/download/${version}/Ninjabrain-Bot-${version}.jar";
    hash = "sha256-Rxu9A2EiTr69fLBUImRv+RLC2LmosawIDyDPIaRcrdw=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit version src;
  pname = "ninjabrain-bot";

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/ninjabrain-bot/ninjabrain-bot.jar
    makeWrapper ${pkgs.lib.getExe pkgs.zulu21} $out/bin/ninbot \
        --add-flags "-Dawt.useSystemAAFontSettings=on -jar $out/share/ninjabrain-bot/ninjabrain-bot.jar" \
        --prefix LD_LIBRARY_PATH : ${
          pkgs.lib.makeLibraryPath [
            pkgs.xorg.libX11
            pkgs.xorg.libXinerama
            pkgs.xorg.libXt
            pkgs.libxkbcommon
          ]
        }

    runHook postInstall
  '';

  meta = {
    description = "Calculator for minecraft speedrunning";
    mainProgram = "ninbot";
  };
}
