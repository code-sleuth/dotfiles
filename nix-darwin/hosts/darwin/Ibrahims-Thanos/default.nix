{ username, ... }:
{
  # Host-specific configuration for Ibrahims-Thanos

  imports = [
    ./packages.nix
    ./homebrew.nix
  ];

  home-manager.users.${username}.home.file.".config/git-identity".text = ''
    [user]
        email = code.ibra@gmail.com
        signingkey = 90CEC26C2DA90D65A751ECED9E900E9767E815A0
  '';

  # Disable widgets and Stage Manager
  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = false;
      HideDesktop = false;
      StageManagerHideWidgets = false;
      GloballyEnabled = false;
    };
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.LoginwindowText = "
            🦇🦇🦇🦇🦇🦇
              batman
            🦇🦇🦇🦇🦇🦇
            ";
  };
}
