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
          pkgs.vim
          pkgs.direnv
          pkgs.sshs
          pkgs.glow
          pkgs.nushell
          pkgs.carapace
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
        screencapture.location = "~/Downloads/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.casks = [
        "aerospace"
        "alacritty"
        "betterdisplay"
        "docker-desktop"
        "font-hack-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "gimp@dev"
        "miniconda"
        "rstudio"
        "stats"
        "ungoogled-chromium"
        "wezterm"
        "zed"
        "wireshark"
        "google-chrome"
      ];
      homebrew.brews = [
        "imagemagick"
        "python@3.13"
        "asciinema"
        "atuin"
        "awscli"
        "bat"
        "binutils"
        "buildkit"
        "libpng"
        "glib"
        "pixman"
        "capstone"
        "carapace"
        "cmake"
        "cmatrix"
        "gmp"
        "coreutils"
        "dbmate"
        "diff-so-fancy"
        "docker-compose"
        "eksctl"
        "expat"
        "eza"
        "fd"
        "flock"
        "fzf"
        "mpfr"
        "gawk"
        "isl"
        "libmpc"
        "gcc"
        "geni"
        "gh"
        "git-delta"
        "gnu-sed"
        "gnutls"
        "libusb"
        "go"
        "pkgconf"
        "helm"
        "jpeg"
        "jpeg-turbo"
        "jq"
        "kind"
        "lazydocker"
        "lazygit"
        "ledger"
        "libelf"
        "libmpdclient"
        "libslirp"
        "libssh"
        "lima"
        "make"
        "md5sha1sum"
        "mongosh"
        "neovim"
        "ninja"
        "nushell"
        "nvm"
        "tree"
        "pass"
        "pinentry-mac"
        "pipx"
        "pnpm"
        "postgresql@16"
        "protobuf"
        "python-setuptools"
        "r"
        "redis"
        "ripgrep"
        "riscv64-elf-binutils"
        "riscv64-elf-gcc"
        "riscv64-elf-gdb"
        "skaffold"
        "starship"
        "terraform"
        "texinfo"
        "thefuck"
        "tlrc"
        "tmux"
        "wakatime-cli"
        "wget"
        "when"
        "yarn"
        "yazi"
        "zig"
        "zlib"
        "zoxide"
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
        "stow"
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
