{
  inputs,
  config,
  lib,
  hostname,
  system,
  username,
  pkgs,
  unstablePkgs,
  ...
}:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  users.users.${username}.home = "/Users/${username}";

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
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # System activation scripts
  system.activationScripts = {
    applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
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

    zed.text = ''
      echo "setting up zed CLI..." >&2
      mkdir -p /usr/local/bin
      rm -f /usr/local/bin/zed
      if [ -f ${pkgs.zed-editor}/Applications/Zed.app/Contents/MacOS/cli ]; then
        ln -sf ${pkgs.zed-editor}/Applications/Zed.app/Contents/MacOS/cli /usr/local/bin/zed
      else
        echo "Warning: zed CLI not found at expected location"
      fi
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
    };

    casks = [
      # GUI apps that are better managed through homebrew or unavailable in nix
      "aerospace" # Tiling window manager for macOS
      "docker-desktop" # Docker Desktop
      "miniconda" # Conda environment management
      # "rstudio" # RStudio IDE (complex nix setup)
      "stats" # macOS system monitor (not in nix)
      "google-chrome" # chrome
      "ghostty"
      "zen" # Zen Browser
      "slack" # Team communication
      "discord" # Chat and voice communication
      "qobuz" # Music streaming
      "spotify" # Music streaming
      "notion" # Note-taking and productivity
      "notion-calendar" # Calendar app
      "obsidian" # Knowledge management
    ];

    brews = [
      # Libraries and low-level tools needed for system compatibility
      "libpng"
      "glib"
      "pixman"
      "gmp"
      "expat"
      "mpfr"
      "isl"
      "libmpc"
      "gnutls"
      "libusb"
      "pkgconf"
      "jpeg"
      "jpeg-turbo"
      "zlib"
      "texinfo"

      # Tools that may need homebrew versions for compatibility
      "buildkit" # Docker buildkit
      "capstone" # Disassembly framework
      "flock" # File locking utility
      "pinentry-mac" # macOS-specific pinentry
      "nvm" # Node Version Manager
      "python-setuptools" # Python build tools

      # Specialized tools not readily available in nix
      "dbmate" # Database migration tool
      "eksctl" # AWS EKS CLI
      "geni" # Network emulator
      "ledger" # Command-line accounting
      "lima" # Linux VM manager
      "md5sha1sum" # macOS checksum utilities
      # "mongosh" # MongoDB shell
      "skaffold" # Kubernetes dev tool
      "thefuck" # Command correction tool
      "tlrc" # tldr client
      "wakatime-cli" # Time tracking
      "when" # Calendar utility

      # RISC-V development tools
      "riscv64-elf-binutils"
      "riscv64-elf-gcc"
      "riscv64-elf-gdb"

      # Low-level system libraries
      "libelf"
      "libmpdclient"
      "libslirp"
      "libssh"
      "llvm"
      "gcc"
      "wasm-pack"
      "trunk" # WASM builder & bundler crate

      # Programming Languages
      # "go"

      # DevOps tools
      "opentofu"
      "terraform"

      # Custom taps and formulae
      "felixkratz/formulae/sketchybar"
      "filosottile/musl-cross/musl-cross"
      "go-swagger/go-swagger/go-swagger"
      "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
      "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
      "oven-sh/bun/bun"
      "riscv/riscv/riscv-gnu-toolchain"
      "riscv/riscv/riscv-tools"
      "tursodatabase/tap/turso"
    ];

    taps = [
      "felixkratz/formulae"
      "filosottile/musl-cross"
      "homebrew/services"
      "libsql/sqld"
      "messense/macos-cross-toolchains"
      "nikitabobko/tap"
      "oven-sh/bun"
      "riscv/riscv"
      "tursodatabase/tap"
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
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv"; # or clmv
    loginwindow.LoginwindowText = "
            🦇🦇🦇🦇🦇🦇
              batman
            🦇🦇🦇🦇🦇🦇
            ";
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

    # Disable Caps Lock for all keyboards
    "com.apple.keyboard.fnState" = {
      "3" = 0; # Disable Caps Lock for USB keyboards
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
