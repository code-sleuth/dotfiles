{ ... }:
{
  # Host-specific configuration for Ibrahims-Thanos

  imports = [
    ./packages.nix
    ./homebrew.nix
  ];

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
