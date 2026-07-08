{ pkgs, config, ... }:
{
  # Hyprland configuration for Home Manager

  # Copy wallpaper
  home.file.".config/hypr/wallpaper.jpg" = {
    source = ../../alma.jpg;
    force = true;
  };

  # Hyprland config
  home.file.".config/hypr/hyprland.conf" = {
    source = ./hyprland.conf;
    force = true;
  };

  # Screenshot script
  home.file.".config/hypr/scripts/screenshot.sh" = {
    text = ''
      #!/usr/bin/env bash
      
      # Screenshot directory
      DIR="$HOME/Pictures/Screenshots"
      mkdir -p "$DIR"
      
      # Filename with timestamp
      FILE="$DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
      
      # Show menu with rofi
      choice=$(echo -e "󰹑 Select Area\n󰍹 Full Screen\n󰍹 Current Window\n Edit Last" | rofi -dmenu -i -p "Screenshot" -theme-str 'window {width: 250px;} listview {lines: 4;}')
      
      case "$choice" in
        *"Select Area")
          grimblast --notify copysave area "$FILE"
          ;;
        *"Full Screen")
          grimblast --notify copysave screen "$FILE"
          ;;
        *"Current Window")
          grimblast --notify copysave active "$FILE"
          ;;
        *"Edit Last")
          LAST=$(ls -t "$DIR"/*.png 2>/dev/null | head -1)
          if [ -n "$LAST" ]; then
            swappy -f "$LAST"
          else
            notify-send "Screenshot" "No screenshots found"
          fi
          ;;
      esac
    '';
    executable = true;
  };

  # Screen recording script
  home.file.".config/hypr/scripts/record.sh" = {
    text = ''
      #!/usr/bin/env bash
      
      # Recording directory
      DIR="$HOME/Videos/Recordings"
      mkdir -p "$DIR"
      
      # PID file
      PIDFILE="/tmp/wf-recorder.pid"
      
      if [ -f "$PIDFILE" ]; then
        # Stop recording
        kill $(cat "$PIDFILE")
        rm "$PIDFILE"
        notify-send "Screen Recording" "Recording stopped"
      else
        # Start recording
        FILE="$DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
        wf-recorder -f "$FILE" &
        echo $! > "$PIDFILE"
        notify-send "Screen Recording" "Recording started"
      fi
    '';
    executable = true;
  };

  # Rofi config for better theming
  home.file.".config/rofi/config.rasi" = {
    text = ''
      configuration {
        modi: "drun,run,window,ssh";
        show-icons: true;
        terminal: "kitty";
        drun-display-format: "{icon} {name}";
        display-drun: "   Apps";
        display-run: "   Run";
        display-window: " 﩯  Window";
        display-ssh: "   SSH";
        sidebar-mode: true;
      }
      
      @theme "~/.config/rofi/theme.rasi"
    '';
  };

  # Custom rofi theme (Catppuccin-inspired)
  home.file.".config/rofi/theme.rasi" = {
    text = ''
      * {
        bg-col:  #1e1e2e;
        bg-col-light: #313244;
        border-col: #89b4fa;
        selected-col: #45475a;
        blue: #89b4fa;
        fg-col: #cdd6f4;
        fg-col2: #f38ba8;
        grey: #6c7086;
        width: 600;
        font: "JetBrainsMono Nerd Font 12";
      }

      element-text, element-icon, mode-switcher {
        background-color: inherit;
        text-color: inherit;
      }

      window {
        height: 500px;
        border: 3px;
        border-color: @border-col;
        background-color: @bg-col;
        border-radius: 15px;
      }

      mainbox {
        background-color: @bg-col;
      }

      inputbar {
        children: [prompt,entry];
        background-color: @bg-col;
        border-radius: 10px;
        padding: 8px;
        margin: 20px;
      }

      prompt {
        background-color: @blue;
        padding: 8px 12px;
        text-color: @bg-col;
        border-radius: 8px;
        margin: 0px 10px 0px 0px;
      }

      textbox-prompt-colon {
        expand: false;
        str: ":";
      }

      entry {
        padding: 8px;
        text-color: @fg-col;
        background-color: @bg-col;
      }

      listview {
        border: 0px 0px 0px;
        padding: 6px 0px 0px;
        margin: 10px 20px 10px 20px;
        columns: 1;
        lines: 8;
        background-color: @bg-col;
      }

      element {
        padding: 8px;
        background-color: @bg-col;
        text-color: @fg-col;
        border-radius: 8px;
      }

      element-icon {
        size: 25px;
      }

      element selected {
        background-color: @selected-col;
        text-color: @fg-col2;
      }

      mode-switcher {
        spacing: 0;
      }

      button {
        padding: 10px;
        background-color: @bg-col-light;
        text-color: @grey;
        vertical-align: 0.5; 
        horizontal-align: 0.5;
      }

      button selected {
        background-color: @bg-col;
        text-color: @blue;
      }

      message {
        background-color: @bg-col-light;
        margin: 2px;
        padding: 2px;
        border-radius: 5px;
      }

      textbox {
        padding: 6px;
        margin: 20px 0px 0px 20px;
        text-color: @blue;
        background-color: @bg-col-light;
      }
    '';
  };

  # Clipboard history setup (needs to run on startup)
  home.file.".config/hypr/scripts/clipboard-init.sh" = {
    text = ''
      #!/usr/bin/env bash
      wl-paste --watch cliphist store
    '';
    executable = true;
  };

  # Lid switch handler to move workspaces to external monitor
  home.file.".config/hypr/scripts/lid-handler.sh" = {
    text = ''
      #!/usr/bin/env bash
      
      handle() {
        case $1 in
          monitorremoved*|monitoradded*)
            # Wait a moment for monitor changes to settle
            sleep 1
            
            # Get active monitors
            MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
            LAPTOP_ACTIVE=$(echo "$MONITORS" | grep -c "eDP-1")
            EXTERNAL_MONITOR=$(echo "$MONITORS" | grep -v "eDP-1" | head -1)
            
            # If laptop monitor is not active but external monitor is
            if [ "$LAPTOP_ACTIVE" -eq 0 ] && [ -n "$EXTERNAL_MONITOR" ]; then
              # Move all workspaces to external monitor
              for workspace in {1..10}; do
                hyprctl dispatch moveworkspacetomonitor $workspace $EXTERNAL_MONITOR 2>/dev/null
              done
            fi
            ;;
        esac
      }
      
      # Listen to Hyprland socket for events
      socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
        handle "$line"
      done
    '';
    executable = true;
  };



  # Kanshi config for automatic monitor management
  home.file.".config/kanshi/config" = {
    source = ./kanshi.conf;
    force = true;
  };

  # Hyprpaper config for wallpaper
  home.file.".config/hypr/hyprpaper.conf" = {
    text = ''
      preload = ${config.home.homeDirectory}/.config/hypr/wallpaper.jpg
      wallpaper = eDP-1,${config.home.homeDirectory}/.config/hypr/wallpaper.jpg
      wallpaper = DP-3,${config.home.homeDirectory}/.config/hypr/wallpaper.jpg
      splash = false
    '';
    force = true;
  };

  # Hypridle config for screen locking
  home.file.".config/hypr/hypridle.conf" = {
    text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = hyprlock
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = 300
        on-timeout = hyprlock
      }

      listener {
        timeout = 330
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }
    '';
    force = true;
  };

  # Hyprlock config
  home.file.".config/hypr/hyprlock.conf" = {
    text = ''
      background {
        monitor =
        path = ~/.config/hypr/wallpaper.jpg
        blur_passes = 3
        blur_size = 8
      }

      input-field {
        monitor =
        size = 200, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        outer_color = rgb(151515)
        inner_color = rgb(200, 200, 200)
        font_color = rgb(10, 10, 10)
        fade_on_empty = true
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        position = 0, -20
        halign = center
        valign = center
      }

      label {
        monitor =
        text = Hi there, $USER
        color = rgba(200, 200, 200, 1.0)
        font_size = 25
        font_family = Noto Sans
        position = 0, 80
        halign = center
        valign = center
      }
    '';
    force = true;
  };

  # Waybar config
  home.file.".config/waybar/config" = {
    text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 34,
        "spacing": 8,
        "margin-top": 6,
        "margin-left": 10,
        "margin-right": 10,
        "modules-left": ["hyprland/workspaces", "hyprland/submap", "hyprland/window"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "backlight", "network", "cpu", "memory", "battery", "tray"],

        "hyprland/workspaces": {
          "format": "{icon}",
          "on-click": "activate",
          "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬",
            "urgent": "󰀨",
            "active": "󰝥",
            "default": "󰧞"
          },
          "sort-by-number": true
        },

        "hyprland/window": {
          "format": "󰖯  {}",
          "max-length": 60,
          "separate-outputs": true
        },

        "clock": {
          "format": "󰥔  {:%a %b %d  󰥔  %H:%M}",
          "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
          "calendar": {
            "mode": "month",
            "on-scroll": 1,
            "format": {
              "months": "<span color='#ffead3'><b>{}</b></span>",
              "days": "<span color='#ecc6d9'>{}</span>",
              "weeks": "<span color='#99ffdd'><b>W{}</b></span>",
              "weekdays": "<span color='#ffcc66'><b>{}</b></span>",
              "today": "<span color='#ff6699'><b><u>{}</u></b></span>"
            }
          }
        },

        "cpu": {
          "format": "󰻠  {usage}%",
          "tooltip": true,
          "interval": 2
        },

        "memory": {
          "format": "󰍛  {}%",
          "tooltip": true,
          "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G"
        },

        "backlight": {
          "format": "{icon}  {percent}%",
          "format-icons": ["󰃞", "󰃟", "󰃠"],
          "on-scroll-up": "brightnessctl set +5%",
          "on-scroll-down": "brightnessctl set 5%-"
        },

        "battery": {
          "states": {
            "good": 80,
            "warning": 30,
            "critical": 15
          },
          "format": "{icon}  {capacity}%",
          "format-charging": "󰂄  {capacity}%",
          "format-plugged": "󰚥  {capacity}%",
          "format-alt": "{icon}  {time}",
          "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        },

        "network": {
          "format-wifi": "󰖩  {essid}",
          "format-ethernet": "󰈀  {ipaddr}",
          "tooltip-format": "{ifname} via {gwaddr}",
          "format-linked": "󰈂  {ifname} (No IP)",
          "format-disconnected": "󰖪  Disconnected",
          "format-alt": "{ifname}: {ipaddr}/{cidr}",
          "on-click-right": "nm-connection-editor"
        },

        "pulseaudio": {
          "format": "{icon}  {volume}%",
          "format-bluetooth": "󰂯  {volume}%",
          "format-bluetooth-muted": "󰂲",
          "format-muted": "󰖁",
          "format-icons": {
            "headphone": "󰋋",
            "hands-free": "󰋎",
            "headset": "󰋎",
            "phone": "󰄜",
            "portable": "󰄜",
            "car": "󰄋",
            "default": ["󰕿", "󰖀", "󰕾"]
          },
          "on-click": "pavucontrol",
          "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
          "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        },

        "tray": {
          "icon-size": 18,
          "spacing": 10
        }
      }
    '';
    force = true;
  };

  # Waybar style
  home.file.".config/waybar/style.css" = {
    text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font", monospace;
        font-size: 13px;
        font-weight: 600;
        min-height: 0;
      }

      window#waybar {
        background-color: transparent;
      }

      tooltip {
        background: rgba(30, 30, 46, 0.95);
        border: 2px solid rgba(137, 180, 250, 0.8);
        border-radius: 10px;
        padding: 10px;
      }

      tooltip label {
        color: #cdd6f4;
      }

      #workspaces {
        background: rgba(30, 30, 46, 0.8);
        border-radius: 15px;
        padding: 0px 5px;
        margin: 0px 5px;
      }

      #workspaces button {
        padding: 0px 8px;
        margin: 2px 3px;
        background-color: transparent;
        color: #89b4fa;
        border-radius: 10px;
        transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
        background: linear-gradient(135deg, #89b4fa 0%, #cba6f7 100%);
        color: #1e1e2e;
        border-radius: 10px;
      }

      #workspaces button:hover {
        background-color: rgba(137, 180, 250, 0.2);
        color: #cdd6f4;
      }

      #workspaces button.urgent {
        background-color: #f38ba8;
        color: #1e1e2e;
      }

      #window,
      #submap,
      #clock,
      #battery,
      #cpu,
      #memory,
      #backlight,
      #network,
      #pulseaudio,
      #tray {
        background: rgba(30, 30, 46, 0.8);
        padding: 4px 14px;
        margin: 0px 5px;
        border-radius: 15px;
        color: #cdd6f4;
      }

      #window {
        color: #89dceb;
        font-weight: 500;
      }

      #clock {
        background: linear-gradient(135deg, rgba(137, 180, 250, 0.9) 0%, rgba(203, 166, 247, 0.9) 100%);
        color: #1e1e2e;
        font-weight: bold;
        padding: 4px 18px;
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.charging {
        color: #a6e3a1;
      }

      #battery.warning:not(.charging) {
        color: #fab387;
      }

      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background-color: #fab387;
        }
      }

      #cpu {
        color: #f9e2af;
      }

      #memory {
        color: #cba6f7;
      }

      #backlight {
        color: #f9e2af;
      }

      #network {
        color: #94e2d5;
      }

      #network.disconnected {
        color: #f38ba8;
      }

      #pulseaudio {
        color: #89b4fa;
      }

      #pulseaudio.muted {
        color: #f38ba8;
      }

      #tray {
        padding: 4px 10px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #f38ba8;
      }

      #submap {
        background: #f38ba8;
        color: #1e1e2e;
        font-weight: bold;
      }
    '';
    force = true;
  };

  # Keep libinput gestures config
  home.file.".config/libinput-gestures/libinput-gestures.conf" = {
    source = ./libinput-gestures.conf;
    force = true;
  };
}
