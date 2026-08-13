{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # helm 4.x moved tests from cmd/helm/ to pkg/cmd/; the nixpkgs 4.2.0
      # preCheck still patches the old paths and fails
      kubernetes-helm = prev.kubernetes-helm.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    # Core System Utilities
    coreutils
    gawk
    gnused
    watch
    # flock
    sshs

    # Development Editors & IDEs
    vim

    # Version Control & Collaboration
    lazygit
    diff-so-fancy
    git-crypt

    # Programming Languages & Runtimes
    zig
    yarn
    pnpm
    nil # Nix language server

    # Rust Development Tools
    cargo-audit
    cargo-expand
    cargo-edit
    cargo-cache
    grcov

    # Build Systems & Compilation
    #cmake # nix pkg is at v3.31.7, i want v4
    ninja
    gnumake
    binutils
    act

    # Container & Virtualization
    podman
    # podman-desktop
    podman-compose
    docker-compose
    lima
    qemu

    # Kubernetes & Orchestration
    kubectl
    kubernetes-helm
    kind

    eksctl

    # DevOps & Automation
    opentofu
    terraform
    packer
    # ansible
    buildkit

    # Development Services
    redis
    protobuf

    # Security & Cryptography
    pass
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
    yazi
    stow
    ledger
    wakatime-cli
    when
    uv

    # Web Assembly (WASM)
    wasm-pack
    trunk

    # Database Tools
    dbmate

    # GUI Applications
    alacritty
    wezterm

    # Fun & Entertainment
    cmatrix
    # libusb1
  ];
}
