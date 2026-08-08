{ ... }:
{
  homebrew = {
    casks = [
      # "aerospace" — moved to nixpkgs (pkgs.aerospace); nikitabobko/tap was untrusted
      "stats" # macOS system monitor (not in nix)
      "google-chrome" # chrome
      "slack" # Team communication
      "discord" # Chat and voice communication
      "qobuz" # Music streaming
      "spotify" # Music streaming
      "notion" # Note-taking and productivity
      "notion-calendar" # Calendar app
      "obsidian" # Knowledge management
      # "plex" # media server
      # "jellyfin" # media server
      # "plex-media-server" # media server
      "flutter"
      # "claude-code"
      # "expressvpn"
      "tailscale-app"
      # "netbirdio/tap/netbird-ui"
      "obs"
      "zoom"
      "ngrok"
      "cmux"
      "drawio"
      # "supacode"
      # "f/textream/textream"
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
      "cocoapods"

      # Tools that may need homebrew versions for compatibility
      "nvm" # Node Version Manager
      "opencode"
      # "netbirdio/tap/netbird"
      "git-lfs"

      # Specialized tools not readily available in nix
      "geni" # Network emulator

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
      "cmake"
      "libusb"

      # Custom taps and formulae
      # "felixkratz/formulae/sketchybar"
      # Untrusted third-party taps — uninstalled & commented out (supply-chain). Re-enable knowingly.
      # "filosottile/musl-cross/musl-cross"
      # "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
      # "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
      # "riscv/riscv/riscv-gnu-toolchain"   # untrusted tap — uninstalled; OS project will wire up a trusted toolchain
      # "riscv/riscv/riscv-tools"           # untrusted tap — uninstalled (spike/pk; xv6 runs on qemu anyway)
      # turso: removed (untrusted tap). Run via Docker if needed.
    ];

    # Tap history, kept for the supply-chain record:
    # "felixkratz/formulae"
    # "filosottile/musl-cross"          # untrusted tap — removed
    # "messense/macos-cross-toolchains" # untrusted tap — removed
    # "nikitabobko/tap"  # untrusted tap — removed (aerospace moved to nixpkgs)
    # "riscv/riscv"   # untrusted tap — removed (OS toolchain TBD)
  };
}
