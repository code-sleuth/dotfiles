# bat (better cat) — managed natively by Home Manager so the theme cache gets
# built for us. bat only loads custom themes from a cache produced by
# `bat cache --build`; the Home Manager module runs that on activation, writes
# ~/.config/bat/config, and installs the rose-pine theme files. Previously bat
# was a bare system package with a symlinked config and no cache, so
# `--theme=rose-pine` never matched anything and bat silently fell back to its
# default theme (and warned on every colored run). Keep BAT_THEME/BAT_STYLE out
# of the shell rc — those env vars override this module and drift from it.
{ ... }:
{
  programs.bat = {
    enable = true;

    config = {
      theme = "rose-pine";
      style = "full";

      # Pager: quit if the output fits one screen (-F) so short files print
      # inline like `cat` instead of taking over the terminal, and reset the
      # global `LESS=-c` (clear-screen) with `-+c` — that flag repaints the whole
      # screen with `~` filler and leaves it behind on quit. `-R` keeps colors.
      # Scoped to bat only; the global LESS (see zsh/zprofile) is untouched, so
      # git/man keep their `-c`.
      pager = "less -RF -+c";
    };

    # bat derives the theme name from the file name (rose-pine.tmTheme ->
    # "rose-pine"), not from the tmTheme's internal <name> ("Rosé Pine").
    themes = {
      rose-pine = {
        src = ../../../../bat/themes;
        file = "rose-pine.tmTheme";
      };
      rose-pine-moon = {
        src = ../../../../bat/themes;
        file = "rose-pine-moon.tmTheme";
      };
      rose-pine-dawn = {
        src = ../../../../bat/themes;
        file = "rose-pine-dawn.tmTheme";
      };
    };
  };
}
