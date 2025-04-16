{ inputs, outputs, ... }: {
  ##################################################################################################################
  #
  # All matty's Home Manager Configuration
  #
  ##################################################################################################################
home = {
  imports = [];
    user = "matty";
    homeDirectory = "/home/matty";
  stateVersion = "24.11";
};
  programs.home-manager.enable = true;

}
