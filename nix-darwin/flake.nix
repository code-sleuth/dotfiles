{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      system = "aarch64-darwin";

      # Helper functions for activation scripts
      mkCliScript = name: app: path: ''
        echo "setting up ${name} CLI..." >&2
        mkdir -p /usr/local/bin
        rm -f /usr/local/bin/${name}
        if [ -f ${app}${path} ]; then
          ln -sf ${app}${path} /usr/local/bin/${name}
        else
          echo "Warning: ${name} CLI not found at expected location"
        fi
      '';

      mkFontCopy = font: ''
        if [ -d ${font}/share/fonts ]; then
          find ${font}/share/fonts -type f \( -name "*.ttf" -o -name "*.otf" \) | while read -r font_file; do
            font_name=$(basename "$font_file")
            echo "copying font $font_name" >&2
            cp "$font_file" "/Users/code/Library/Fonts/Nix Fonts/$font_name"
          done
        fi
      '';

      configuration =
        { pkgs, config, ... }:
        {
          ids.gids.nixbld = 350;
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            # Core utilities
            pkgs.vim
            pkgs.direnv
            pkgs.sshs
            pkgs.glow
            pkgs.ffmpeg

            # Shell and terminal tools
            pkgs.nushell
            pkgs.carapace
            pkgs.starship
            pkgs.atuin
            pkgs.zoxide
            pkgs.tmux
            pkgs.bat
            pkgs.eza
            pkgs.fd
            pkgs.fzf
            pkgs.ripgrep
            pkgs.tree

            # Development tools
            pkgs.neovim
            # pkgs.git-delta
            pkgs.diff-so-fancy
            pkgs.lazygit
            pkgs.lazydocker
            pkgs.gh
            pkgs.jq
            pkgs.yazi

            # Programming languages and tools
            # pkgs.python313
            pkgs.rustup

            # Rust development tools
            pkgs.cargo-audit
            pkgs.cargo-watch
            pkgs.cargo-expand
            pkgs.cargo-edit
            pkgs.cargo-cache
            pkgs.grcov

            pkgs.yarn
            pkgs.pnpm
            pkgs.zig
            pkgs.nixd # Nix language server
            pkgs.nil # Nix language server

            # Build tools
            pkgs.cmake
            pkgs.ninja
            pkgs.gnumake
            # pkgs.gcc # conflicts with macos gcc from `xcode-select --install`
            pkgs.binutils

            # System utilities
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnused
            pkgs.wget
            pkgs.imagemagick
            pkgs.stow
            pkgs.mkalias

            # Development services
            pkgs.redis
            # pkgs.postgresql_16
            pkgs.protobuf

            # Cloud and container tools
            pkgs.awscli
            pkgs.docker-compose
            # pkgs.kubernetes-helm
            # pkgs.terraform

            # Security and utilities
            pkgs.pass
            pkgs.pipx

            # Entertainment
            pkgs.cmatrix
            pkgs.asciinema

            # Fonts
            pkgs.nerd-fonts.hack
            pkgs.nerd-fonts.jetbrains-mono

            # GUI applications (can also be installed via homebrew casks)
            pkgs.alacritty
            pkgs.wezterm
            pkgs.raycast
            # pkgs.ungoogled-chromium
            # pkgs.wireshark
            pkgs.zed-editor

            # podman
            pkgs.podman
            pkgs.podman-desktop
            pkgs.podman-compose

            #k8s
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.kind
          ];
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
              rm -rf /Users/code/Library/Fonts/Nix\ Fonts
              mkdir -p /Users/code/Library/Fonts/Nix\ Fonts

              ${mkFontCopy pkgs.nerd-fonts.jetbrains-mono}
              ${mkFontCopy pkgs.nerd-fonts.hack}
            '';

            zed.text = mkCliScript "zed" pkgs.zed-editor "/Applications/Zed.app/Contents/MacOS/cli";

            raycast.text =
              mkCliScript "raycast" pkgs.raycast
                "/Applications/Raycast.app/Contents/MacOS/Raycast";
          };

          system.primaryUser = "code";
          nix.settings = {
            experimental-features = "nix-command flakes";
            trusted-users = [
              "root"
              "code"
            ];
          };
          programs.zsh.enable = true; # default shell on macos
          system.stateVersion = 6;
          security.pam.services.sudo_local.touchIdAuth = true;

          users.users.code.home = "/Users/code";
          home-manager.backupFileExtension = "backup";

          system.defaults = {
            dock.autohide = true;
            dock.mru-spaces = false;
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.LoginwindowText = "
            🦇🦇🦇🦇🦇🦇
              batman
            🦇🦇🦇🦇🦇🦇
            ";
            screencapture.location = "~/Desktop/screenshots";
            screensaver.askForPasswordDelay = 10;
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
          };

          # Homebrew needs to be installed on its own!
          homebrew.enable = true;
          homebrew.onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
          homebrew.casks = [
            # GUI apps that are better managed through homebrew or unavailable in nix
            "aerospace" # Tiling window manager for macOS
            "docker-desktop" # Docker Desktop
            "miniconda" # Conda environment management
            "rstudio" # RStudio IDE (complex nix setup)
            "stats" # macOS system monitor (not in nix)
            "google-chrome" # chrome
            "ghostty"
          ];
          homebrew.brews = [
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
            "mongosh" # MongoDB shell
            "skaffold" # Kubernetes dev tool
            "thefuck" # Command correction tool
            "tlrc" # tldr client
            "wakatime-cli" # Time tracking
            "when" # Calendar utility
            "starship" # Prompt

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
            "go"
            # "libpq"
            # "libiconv"

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
          homebrew.taps = [
            "felixkratz/formulae"
            "filosottile/musl-cross"
            # "go-swagger/go-swagger"
            "homebrew/services"
            "libsql/sqld"
            "messense/macos-cross-toolchains"
            "nikitabobko/tap"
            "oven-sh/bun"
            "riscv/riscv"
            "tursodatabase/tap"
          ];
        };
    in
    {
      darwinConfigurations."Ibrahims-Thanos" = nix-darwin.lib.darwinSystem {
        system = system;
        pkgs = import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
          };
        };
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.code = import ./home.nix;
          }
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Ibrahims-Thanos".pkgs;
    };
}
