{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    spotify
    sptlrx
    spotifyd
    spotify-player
    youtube-tui
  ];
}
