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
    # Core utilities
    vim
    direnv
    sshs
    glow
    ffmpeg

    # Shell and terminal tools
    nushell
    carapace
    starship
    atuin
    zoxide
    tmux
    bat
    eza
    fd
    fzf
    ripgrep
    tree
    btop

    # Development tools
    neovim
    diff-so-fancy
    lazygit
    lazydocker
    gh
    jq
    yazi
    just

    # Programming languages and tools
    rustup

    # Rust development tools
    cargo-audit
    cargo-watch
    cargo-expand
    cargo-edit
    cargo-cache
    grcov

    yarn
    pnpm
    zig
    nixd # Nix language server
    nil # Nix language server

    # Build tools
    cmake
    ninja
    gnumake
    binutils
    act

    # System utilities
    coreutils
    gawk
    gnused
    wget
    imagemagick
    stow
    mkalias

    # Development services
    redis
    protobuf

    # Cloud and container tools
    awscli
    docker-compose

    # Security and utilities
    pass
    pipx

    # Entertainment
    cmatrix
    asciinema

    # Fonts
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono

    # GUI applications (can also be installed via homebrew casks)
    alacritty
    wezterm
    raycast
    zed-editor

    # Container tools
    podman
    podman-desktop
    podman-compose

    # Kubernetes tools
    kubectl
    kubernetes-helm
    kind

    # Build automation
    ansible

    # utils
    watch
    qemu
    ipmitool
    nmap
    git-crypt # encrypt git files
  ];
}
