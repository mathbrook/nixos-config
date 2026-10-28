{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
      sptlrx
      spotifyd
      spotify-player
      youtube-tui
    ])
    ++ [
      inputs.spotifast.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
