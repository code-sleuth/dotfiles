# Per-program Home Manager modules, split out of code.nix to keep it lean.
# Add a program by creating a file/folder here and importing it below.
{ ... }:
{
  imports = [
    ./tmux/tmux.nix
    ./helix/helix.nix
  ];
}
