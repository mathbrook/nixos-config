{
  pkgs,
  config,
  ...
}: {
  # i3 配置，基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup

  # wallpaper, binary file
  home.file.".config/i3/wallpaper.jpg".source = ../../alma.jpg;
  home.file.".config/i3/config".source = ./config;
  home.file.".config/picom/picom.conf".source = ./picom.conf;
  # home.file.".config/i3/i3blocks.conf".source = ./i3blocks.conf;
  # home.file.".config/i3/keybindings".source = ./keybindings;
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   # copy the scripts directory recursively
  #   recursive = true;
  #   executable = true;  # make all scripts executable
  # };


  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 192;
  };

}