{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sptlrx
    spotifyd
    spotify-player
    youtube-tui
  ];
}
