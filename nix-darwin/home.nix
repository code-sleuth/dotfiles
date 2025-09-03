# home.nix
# home-manager switch

{ config, pkgs, ... }:

{
  home.username = "code";
  home.homeDirectory = "/Users/code";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = false;  # disable home manager
  # programs.zsh = {
  #   enable = true;
  #   initExtra = ''
  #     # Add any additional configurations here
  #     export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
  #     if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  #       . '/nix/var/nix/profiles/default/etc/profile.d/nix-darwin.sh'
  #     fi
  #   '';
  # };
}
