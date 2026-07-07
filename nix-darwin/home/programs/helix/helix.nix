# helix — managed natively by Home Manager, pulled from nixpkgs-unstable for a
# recent release while the rest of the system tracks stable 24.11 (unstable is
# already an input, so this reuses cache.nixos.org — no source compile).
# Starter config: rose_pine theme (a built-in helix theme; no runtime file
# needed), relative line numbers, format-on-save, and language servers for the
# toolchains already in this config.
{ pkgs, unstablePkgs, ... }:
{
  # gopls isn't in common-packages; bring it in so the Go LSP resolves. nixd is
  # already system-wide, and rust-analyzer comes from rustup (see common-packages).
  home.packages = [ unstablePkgs.gopls ];

  programs.helix = {
    enable = true;
    package = unstablePkgs.helix;
    # Leave EDITOR/VISUAL alone — code.nix pins those to zed.
    defaultEditor = false;

    # -> ~/.config/helix/config.toml
    settings = {
      theme = "rose_pine";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true; # tint the mode indicator per mode
        true-color = true;
        bufferline = "multiple"; # show the bufferline only with >1 buffer
        indent-guides.render = true;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        file-picker.hidden = false; # show hidden files in the picker

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        statusline = {
          left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
          center = [ ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-type" ];
        };

        soft-wrap.enable = true;
      };
    };

    # -> ~/.config/helix/languages.toml — format-on-save + language servers.
    languages = {
      language-server = {
        nixd.command = "nixd";
        gopls.command = "gopls";
        rust-analyzer.config.check.command = "clippy";
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixpkgs-fmt";
          language-servers = [ "nixd" ];
        }
        {
          name = "go";
          auto-format = true;
          language-servers = [ "gopls" ];
        }
        {
          name = "rust";
          auto-format = true;
        }
      ];
    };
  };
}
