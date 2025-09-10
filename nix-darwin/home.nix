# home.nix
# home-manager switch

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
    ".zshrc".source = "~/dotfiles/zsh/zshrc";
    ".zprofile".source = "~/dotfiles/zsh/zprofile";
    ".config/wezterm".source = "~/dotfiles/wezterm";
    ".config/skhd".source = "~/dotfiles/skhd";
    ".config/starship".source = "~/dotfiles/starship";
    ".config/zellij".source = "~/dotfiles/zellij";
    ".config/nvim".source = "~/dotfiles/nvim";
    ".config/nix".source = "~/dotfiles/nix";
    ".config/nix-darwin".source = "~/dotfiles/nix-darwin";
    ".config/tmux".source = "~/dotfiles/tmux";
    ".config/ghostty".source = "~/dotfiles/ghostty";
    ".config/aerospace".source = "~/dotfiles/aerospace";
    ".config/sketchybar".source = "~/dotfiles/sketchybar";
    ".config/nushell".source = "~/dotfiles/nushell";
    ".config/git".source = " ~/dotfiles/git";
    ".config/bat".source = "~/dotfiles/bat";
    ".config/atuin".source = "~/dotfiles/atuin";
    ".config/ledger".source = "~/dotfiles/ledger";
    ".lesskey".source = "~/dotfiles/less";
    ".config/neofetch".source = "~/dotfiles/neofetch";
    ".config/raycast".source = "~/dotfiles/raycast";
    ".config/thefuck".source = "~/dotfiles/thefuck";
  };

  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Add any additional configurations here
      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-darwin.sh'
      fi
    '';
  };
}
