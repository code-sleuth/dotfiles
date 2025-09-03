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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      ids.gids.nixbld = 350;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
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
          pkgs.git-delta
          pkgs.lazygit
          pkgs.lazydocker
          pkgs.gh
          pkgs.jq
          pkgs.yazi
          
          # Programming languages and tools
          pkgs.go
          pkgs.python313
          pkgs.nodejs
          pkgs.yarn
          pkgs.pnpm
          pkgs.zig
          
          # Build tools
          pkgs.cmake
          pkgs.ninja
          pkgs.gnumake
          pkgs.gcc
          pkgs.binutils
          
          # System utilities
          pkgs.coreutils
          pkgs.gawk
          pkgs.gnused
          pkgs.wget
          pkgs.imagemagick
          pkgs.stow
          
          # Development services
          pkgs.redis
          pkgs.postgresql_16
          pkgs.protobuf
          
          # Cloud and container tools
          pkgs.awscli
          pkgs.docker-compose
          pkgs.kubernetes-helm
          pkgs.terraform
          
          # Security and utilities
          pkgs.pass
          pkgs.pipx
          
          # Entertainment
          pkgs.cmatrix
          pkgs.asciinema
          
          # Fonts
          pkgs.nerd-fonts.hack
          pkgs.nerd-fonts.jetbrains-mono
          
          # GUI applications (can also be installed via homebrew casks if preferred)
          pkgs.alacritty
          pkgs.wezterm 
          pkgs.ungoogled-chromium
          pkgs.wireshark
          pkgs.zed-editor
        ];
      system.primaryUser = "code";
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on macos
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.services.sudo_local.touchIdAuth = true;

      users.users.code.home = "/Users/code";
      home-manager.backupFileExtension = "backup";

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "batman 🦇";
        screencapture.location = "~/Desktop/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.onActivation.cleanup = "zap";
      homebrew.casks = [
        # GUI apps that are better managed through homebrew or unavailable in nix
        "docker-desktop"      # Proprietary Docker Desktop
        "miniconda"           # Conda environment management
        "rstudio"             # RStudio IDE (complex nix setup)
        "stats"               # macOS system monitor (not in nix)
        "google-chrome"       # Proprietary browser
        "gimp@dev"           # GIMP development version
      ];
      homebrew.brews = [
        # Libraries and low-level tools that may be needed for system compatibility
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
        "buildkit"           # Docker buildkit
        "capstone"           # Disassembly framework
        "flock"              # File locking utility
        "pinentry-mac"       # macOS-specific pinentry
        "nvm"                # Node Version Manager (better as homebrew)
        "python-setuptools"  # Python build tools
        
        # Specialized tools not readily available in nix
        "dbmate"             # Database migration tool
        "eksctl"             # AWS EKS CLI
        "geni"               # Network emulator
        "kind"               # Kubernetes in Docker
        "ledger"             # Command-line accounting
        "lima"               # Linux VM manager
        "md5sha1sum"         # macOS checksum utilities
        "mongosh"            # MongoDB shell
        "skaffold"           # Kubernetes dev tool
        "thefuck"            # Command correction tool
        "tlrc"               # tldr client
        "wakatime-cli"       # Time tracking
        "when"               # Calendar utility
        
        # RISC-V development tools
        "riscv64-elf-binutils"
        "riscv64-elf-gcc"
        "riscv64-elf-gdb"
        
        # Low-level system libraries
        "libelf"
        "libmpdclient"
        "libslirp"
        "libssh"
        
        # Custom taps and formulae (specialized tools)
        "felixkratz/formulae/sketchybar"
        "filosottile/musl-cross/musl-cross"
        "go-swagger/go-swagger/go-swagger"
        "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
        "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
        "oven-sh/bun/bun"
        "riscv/riscv/riscv-gnu-toolchain"
        "riscv/riscv/riscv-tools"
        "tursodatabase/tap/turso"
        "withgraphite/tap/graphite"
      ];
      homebrew.taps = [
        "felixkratz/formulae"
        "filosottile/musl-cross"
        "go-swagger/go-swagger"
        "homebrew/services"
        "libsql/sqld"
        "messense/macos-cross-toolchains"
        "nikitabobko/tap"
        "oven-sh/bun"
        "riscv/riscv"
        "tursodatabase/tap"
        "withgraphite/tap"
      ];
    };
  in
  {
    darwinConfigurations."Ibrahims-Thanos" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.code = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Ibrahims-Thanos".pkgs;
  };
}
