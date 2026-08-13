{ username, ... }:
{
  nix.enable = false;

  home-manager.users.${username}.home.file.".config/git-identity".text = ''
    [user]
        email = dev.mbaziira@gmail.com
        signingkey = dev.mbaziira@gmail.com
  '';

  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = false;
      HideDesktop = false;
      StageManagerHideWidgets = false;
      GloballyEnabled = false;
    };
  };
}
