{ pkgs
, masterPkgs
, ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # Override fish to skip tests that fail on macOS
  nixpkgs.overlays = [
    (final: prev: {
      fish = prev.fish.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
      direnv = prev.direnv.overrideAttrs (oldAttrs: {
        env = (oldAttrs.env or { }) // { CGO_ENABLED = "1"; };
      });
      bun = prev.bun.overrideAttrs (oldAttrs: rec {
        version = "1.3.14";
        src = prev.fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
          hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
        };
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    # Shell & Terminal Environment
    nushell
    carapace
    starship
    atuin
    zoxide

    # Text Processing & Search
    # bat is managed by home-manager (programs.bat) so it can build the theme cache
    eza
    fd
    fzf
    ripgrep
    tree
    jq

    # Editors & Language Servers
    neovim
    nixd # Nix language server
    nixpkgs-fmt

    rustup
    go
    gotools
    golines
    golangci-lint
    bun
    masterPkgs.herdr

    # Core System Utilities
    wget
    direnv

    # Version Control & Collaboration
    gh

    # Productivity & Utilities
    just
    mkalias

    # GUI Applications
    aerospace
    raycast

    # Fonts
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];
}
