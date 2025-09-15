{
  inputs,
  pkgs,
  unstablePkgs,
  ...
}:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core System Utilities
    coreutils
    gawk
    gnused
    wget
    watch
    flock
    direnv
    sshs

    # Shell & Terminal Environment
    nushell
    carapace
    starship
    atuin
    zoxide
    tmux

    # Text Processing & Search
    bat
    eza
    fd
    fzf
    ripgrep
    tree
    jq

    # Development Editors & IDEs
    vim
    neovim
    zed-editor
    # Create a wrapper to make zed CLI available in system PATH
    (pkgs.writeShellScriptBin "zed" ''
      exec ${pkgs.zed-editor}/Applications/Zed.app/Contents/MacOS/cli "$@"
    '')

    # Version Control & Collaboration
    lazygit
    gh
    diff-so-fancy
    git-crypt

    # Programming Languages & Runtimes
    rustup
    rust-analyzer
    go
    zig
    bun
    yarn
    pnpm
    nixd # Nix language server
    nil # Nix language server

    # Rust Development Tools
    cargo-audit
    cargo-watch
    cargo-expand
    cargo-edit
    cargo-cache
    grcov

    # Build Systems & Compilation
    cmake
    ninja
    gnumake
    binutils
    act

    # Container & Virtualization
    podman
    podman-desktop
    podman-compose
    docker-compose
    lima
    qemu

    # Kubernetes & Orchestration
    kubectl
    kubernetes-helm
    kind

    # Cloud & Infrastructure
    awscli
    eksctl

    # DevOps & Automation
    opentofu
    terraform
    ansible
    buildkit

    # Development Services
    redis
    protobuf
    jellyfin

    # Security & Cryptography
    pass
    gnupg
    pinentry_mac
    openssl

    # System Monitoring & Analysis
    btop
    nmap
    ipmitool
    capstone

    # Media & Content Processing
    ffmpeg
    imagemagick
    asciinema

    # Documentation & Reference
    glow
    tlrc

    # Productivity & Utilities
    just
    yazi
    stow
    mkalias
    ledger
    wakatime-cli
    when
    pipx

    # Web Assembly (WASM)
    wasm-pack
    trunk

    # Database Tools
    dbmate

    # GUI Applications
    alacritty
    wezterm
    raycast

    # Fonts
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono

    # Fun & Entertainment
    cmatrix
  ];
}
