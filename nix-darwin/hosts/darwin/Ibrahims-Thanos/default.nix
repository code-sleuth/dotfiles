{ ... }:
{
  # Host-specific configuration for Ibrahims-Thanos
  
  # Disable widgets and Stage Manager
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