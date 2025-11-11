# Enhanced Home Manager configuration for user "code"
# Inspired by ironicbadger's configuration structure
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "23.05";

  # User-specific packages that shouldn't be available system-wide
  home.packages = with pkgs; [
    # Add any user-specific packages here
  ];

  # Dotfile management through Home Manager
  home.file = {
    ".zshrc" = {
      source = ../../zsh/zshrc;
      enable = true;
    };
    ".zprofile" = {
      source = ../../zsh/zprofile;
      enable = true;
    };
    ".config/skhd" = {
      source = ../../skhd;
      enable = false;
    };
    ".config/nvim" = {
      source = ../../nvim;
      enable = true;
    };
    ".config/nix" = {
      source = ../../nix;
      enable = true;
    };
    ".config/nix-darwin" = {
      source = ../../nix-darwin;
      enable = true;
    };
    ".config/ghostty" = {
      source = ../../ghostty;
      enable = true;
    };
    ".config/aerospace" = {
      source = ../../aerospace;
      enable = true;
    };
    ".config/sketchybar" = {
      source = ../../sketchybar;
      enable = true;
    };
    ".config/git" = {
      source = ../../git;
      enable = true;
    };
    ".config/bat" = {
      source = ../../bat;
      enable = true;
    };
    ".config/atuin" = {
      source = ../../atuin;
      enable = true;
    };
    ".config/ledger" = {
      source = ../../ledger;
      enable = true;
    };
    ".lesskey" = {
      source = ../../less;
      enable = true;
    };
    ".config/neofetch" = {
      source = ../../neofetch;
      enable = true;
    };
    ".config/thefuck" = {
      source = ../../thefuck;
      enable = false;
    };
    ".config/alacritty" = {
      source = ../../alacritty;
      enable = true;
    };
    ".config/zed/settings.json" = {
      source = ../../zed/settings.json;
      enable = true;
    };
    ".config/wezterm" = {
      source = ../../wezterm;
      enable = true;
    };
    ".config/starship.toml" = {
      source = ../../starship/starship.toml;
      enable = true;
    };
    ".config/scripts" = {
      source = ../../scripts;
      enable = true;
    };
    ".config/btop" = {
      source = ../../btop;
      enable = true;
    };
    ".local/share/nushell/.keep" = {
      text = "";
      enable = true;
    };
    ".cache/nushell/.keep" = {
      text = "";
      enable = true;
    };
    ".cache/starship/.keep" = {
      text = "";
      enable = true;
    };
    ".cache/carapace/.keep" = {
      text = "";
      enable = true;
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Session PATH additions
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  # Enable Home Manager programs
  programs.home-manager.enable = true;

  # Copy (not symlink) nushell config to allow writable history
  # macOS uses ~/Library/Application Support/nushell as primary config location
  home.activation.copyNushellConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Library/Application Support/nushell"
    $DRY_RUN_CMD cp -f ${../../nushell}/config.nu "$HOME/Library/Application Support/nushell/config.nu"
    $DRY_RUN_CMD cp -f ${../../nushell}/env.nu "$HOME/Library/Application Support/nushell/env.nu"
    $DRY_RUN_CMD chmod u+w "$HOME/Library/Application Support/nushell"/*.nu
  '';

  # Initialize nushell integrations (starship, zoxide, carapace)
  home.activation.initNushellIntegrations = lib.hm.dag.entryAfter [ "copyNushellConfig" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.cache/starship" "$HOME/.cache/carapace"
    $DRY_RUN_CMD ${pkgs.starship}/bin/starship init nu > "$HOME/.cache/starship/init.nu"
    $DRY_RUN_CMD ${pkgs.zoxide}/bin/zoxide init nushell > "$HOME/.zoxide.nu"
    $DRY_RUN_CMD ${pkgs.carapace}/bin/carapace _carapace nushell > "$HOME/.cache/carapace/init.nu"
  '';

  # Copy (not symlink) tmux config to allow TPM to install plugins
  home.activation.copyTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -rf "$HOME/.config/tmux"
    $DRY_RUN_CMD mkdir -p "$HOME/.config/tmux/plugins"
    $DRY_RUN_CMD cp -r "$HOME/dotfiles/tmux"/* "$HOME/.config/tmux/"
    $DRY_RUN_CMD chmod -R u+w "$HOME/.config/tmux"
  '';
}
