{ config, pkgs, ... }:
{
  # Desktop environment and Wayland configuration for Home Manager
  home.packages = with pkgs; [
    # Wayland/Hyprland packages
    waybar
    rofi  # Application launcher (now supports both X11 and Wayland)
    dunst
    hyprpaper
    hypridle
    hyprlock
    hyprpicker
    kanshi
    
    # Monitor configuration GUI tools
    wdisplays      # GUI for Wayland display configuration
    nwg-displays   # Alternative GUI tool for wlroots compositors
    
    # Wayland utilities
    wl-clipboard
    wlr-randr
    wayland-utils
    
    # Screenshot tools for Wayland
    grim          # Screenshot utility
    slurp         # Region selector
    grimblast     # Convenient wrapper around grim and slurp
    swappy        # Annotation tool for screenshots
    
    # File manager
    xfce.thunar              # Lightweight file manager
    xfce.thunar-volman       # Automatic management of removable drives
    xfce.thunar-archive-plugin  # Archive support
    
    # Eye candy and productivity
    swaybg              # Alternative wallpaper daemon (can do multiple monitors differently)
    swayidle            # Idle management daemon
    swaylock-effects    # Lock screen with cool effects
    wlogout             # Logout menu with icons
    wev                 # Wayland event viewer (debug key bindings)
    
    # Notifications enhancement
    libnotify           # Send notifications from terminal
    
    # Color picker and screen tools
    wf-recorder         # Screen recorder for Wayland
    
    # Clipboard manager
    cliphist            # Clipboard history manager
    
    # System monitoring
    btop                # Better top (modern system monitor)
    nvtopPackages.full  # GPU monitoring (nvidia/amd/intel)
    
    # Terminal tools
    fastfetch           # Modern neofetch alternative (faster, prettier)
    cava                # Audio visualizer
    tty-clock           # Terminal clock
    cmatrix             # Matrix effect in terminal
    
    # Productivity
    ulauncher           # Alternative app launcher with plugins
    clipman             # Another clipboard manager option
    
    # File previews in terminal
    ranger              # Terminal file manager with preview
    ueberzugpp          # Image preview in terminal
    
    # Fonts for icons and better looks
    font-awesome        # Icon font
    nerd-fonts.jetbrains-mono  # JetBrains Mono Nerd Font (used in terminal and UI)
    nerd-fonts.symbols-only    # Just the icon glyphs

    # Cursor theme
    catppuccin-cursors.mochaDark  # Catppuccin cursor theme matching Mocha color scheme
    
    # Other utilities
    xdg-utils
    feh
    acpi
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    # Signal + exporter
	signal-desktop
	sigtop    
    # Applications
    brave # Browser
    obsidian # Note taking
    discord
    slack
    vscode-fhs
    foxglove-studio    
    # Image editors
    gimp          # Full-featured image editor (like Photoshop)
    krita         # Digital painting and drawing
    # pinta       # Simple paint program (like MS Paint) - uncomment if you prefer something simpler

    # AI slop
    claude-code

  ];
  
  # Import Hyprland config
  imports = [ ./hyprland/hyprland.nix ];
}
