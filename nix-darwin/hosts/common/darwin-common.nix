{ config
, lib
, system
, username
, pkgs
, ...
}:
{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
    uid = 501;
  };

  # Valid login shells (zsh is default; nushell still selectable via `chsh`)
  environment.shells = [
    pkgs.zsh
    pkgs.nushell
  ];

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        username
      ];
    };
  };

  system.stateVersion = 6;
  system.primaryUser = username;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault system;
    overlays = [
      (final: prev: {
        nushell = prev.nushell.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];
  };

  # Use TouchID for sudo authentication. `reattach` re-attaches sudo to the
  # GUI (Aqua) login session so TouchID also works inside tmux/screen, whose
  # server is detached from that session.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # System activation scripts
  system.activationScripts = {
    applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
        };
      in
      pkgs.lib.mkForce ''
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

    fonts.text = ''
      echo "setting up fonts..." >&2
      rm -rf /Users/${username}/Library/Fonts/Nix\ Fonts
      mkdir -p /Users/${username}/Library/Fonts/Nix\ Fonts

      # Copy fonts from system packages
      for font_package in ${pkgs.nerd-fonts.jetbrains-mono} ${pkgs.nerd-fonts.hack}; do
        if [ -d "$font_package/share/fonts" ]; then
          find "$font_package/share/fonts" -type f \( -name "*.ttf" -o -name "*.otf" \) | while read -r font_file; do
            font_name=$(basename "$font_file")
            echo "copying font $font_name" >&2
            cp "$font_file" "/Users/${username}/Library/Fonts/Nix Fonts/$font_name"
          done
        fi
      done
    '';

    raycast.text = ''
      echo "setting up raycast CLI..." >&2
      mkdir -p /usr/local/bin
      rm -f /usr/local/bin/raycast
      if [ -f ${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast ]; then
        ln -sf ${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast /usr/local/bin/raycast
      else
        echo "Warning: raycast CLI not found at expected location"
      fi
    '';
  };

  # Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      # --verbose: i want to see progress
      # --force-cleanup: cleanup="zap" makes nix-darwin run `brew bundle --cleanup`,
      #   which Homebrew 4.7+/5.x refuses to do without --force/--force-cleanup/$HOMEBREW_ASK.
      #   nix-darwin doesn't add it itself, so we pass it here to keep activation non-interactive.
      extraFlags = [
        "--verbose"
        "--force-cleanup"
      ];
    };

    casks = [
      # GUI apps that are better managed through homebrew or unavailable in nix
      "docker-desktop" # Docker Desktop
      "ghostty"
      "zed" # Code editor
      "zen" # Zen Browser
    ];

    brews = [
      # nixpkgs awscli (py3.14+libffi) aborts on macOS 27; use the brew build
      "awscli"
      "ical-buddy" # reads macOS Calendar for the tmux meeting widget (not in nixpkgs)
    ];
  };

  # macOS system defaults
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv"; # or clmv
    screencapture.location = "~/Desktop/screenshots";
    screensaver.askForPasswordDelay = 10;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    dock = {
      autohide = true;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      tilesize = 36;
      minimize-to-application = true;
      mineffect = "scale";
      # enable-window-tool = false;
    };
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.HIToolbox" = {
      AppleKeyboardUIMode = 3; # Enable full keyboard access
    };

    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    # "com.apple.Safari" = {
    #   # Privacy: don’t send search queries to Apple
    #   UniversalSearchEnabled = false;
    #   SuppressSearchSuggestions = true;
    # };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
  };
}
