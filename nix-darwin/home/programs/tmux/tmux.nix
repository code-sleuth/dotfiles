# tmux — managed natively by Home Manager (no TPM).
# Plugins come from the nix store and load deterministically. For fast startup
# only the plugins that affect the initial look/behaviour load synchronously
# (catppuccin, resurrect, continuum); the key-binding-only plugins load in the
# background via `run-shell -b` at the end of extraConfig. tmux-sensible is
# inlined rather than sourced, to skip its ~0.23s of per-option `tmux` forks.
{ pkgs, ... }:
{
  # cal.sh: next-meeting widget for the status bar (reads macOS Calendar via
  # `ical-buddy`). Deployed executable so tmux can run it from a #() segment.
  xdg.configFile."tmux/scripts/cal.sh" = {
    source = ../../../../tmux/scripts/cal.sh;
    executable = true;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 1000000;
    keyMode = "vi";
    terminal = "tmux-256color";
    focusEvents = true;      # let vim/nvim detect terminal focus (FocusGained)
    aggressiveResize = true; # from tmux-sensible

    # Foreground plugins: affect the initial appearance/behaviour, so they
    # must finish before the first prompt is shown.
    plugins = with pkgs.tmuxPlugins; [
      {
        # catppuccin v2: theme + module text options must be set BEFORE the
        # plugin loads; the status-left/right assembly is done after, in
        # extraConfig (Home Manager emits extraConfig last).
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g @catppuccin_window_number_position 'right'
          set -g @catppuccin_window_text ' #W'
          set -g @catppuccin_window_current_text ' #W#{?window_zoomed_flag,(),}'
          set -g @catppuccin_status_connect_separator 'no'
          set -g @catppuccin_directory_text ' #{b:pane_current_path}'
          set -g @catppuccin_date_time_text ' %H:%M'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        # continuum must load after resurrect
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''
      # ---- options without a native Home Manager setting ----
      set -g terminal-overrides ',xterm-256color:RGB'
      set -g detach-on-destroy off   # don't exit tmux when closing a session
      set -g renumber-windows on     # renumber windows when one is closed
      set -g set-clipboard on        # use the system clipboard
      set -g status-position top      # macOS-style: status bar on top
      set -g pane-active-border-style 'fg=magenta,bg=default'
      set -g pane-border-style 'fg=brightblack,bg=default'
      # set -g mouse on

      # Persistent server: keep it alive after the last session closes, so the
      # config + plugins load only once per boot and later `tmux` calls attach
      # to the warm server instantly (the ~0.4s start is paid once).
      set -s exit-empty off

      # ---- tmux-sensible's extras (inlined to avoid sourcing the plugin) ----
      set -g display-time 4000       # show status messages for 4s
      set -g status-interval 5       # refresh status-left/right every 5s
      bind a last-window
      bind C-p previous-window
      bind C-n next-window

      # ---- catppuccin status line (built AFTER the plugin has loaded) ----
      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_directory}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
      # next meeting via cal.sh (ical-buddy) — themed peach segment, refreshed
      # every status-interval. Needs macOS Calendar permission (see notes).
      set -ag status-right "#[fg=#{@thm_crust},bg=#{@thm_peach}] #($HOME/.config/tmux/scripts/cal.sh) "
      # due-tasks count (Reminders/To-Dos) — plain segment, empty when none due
      set -ag status-right "#[bg=default,fg=#{@thm_yellow}] #($HOME/.config/tmux/scripts/cal.sh tasks)"

      # ---- key bindings (previously tmux.reset.conf) ----
      bind ^X lock-server
      bind ^C new-window -c "$HOME"
      bind ^D detach
      bind * list-clients
      bind H previous-window
      bind L next-window
      bind r command-prompt "rename-window %%"
      bind R source-file ~/.config/tmux/tmux.conf
      bind ^A last-window
      bind ^W list-windows
      bind w list-windows
      bind z resize-pane -Z
      bind ^L refresh-client
      bind l refresh-client
      bind | split-window
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind '"' choose-window
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r -T prefix , resize-pane -L 20
      bind -r -T prefix . resize-pane -R 20
      bind -r -T prefix - resize-pane -D 7
      bind -r -T prefix = resize-pane -U 7
      bind : command-prompt
      bind * setw synchronize-panes
      bind P set pane-border-status
      bind c kill-pane
      bind x swap-pane -D
      bind S choose-session
      # prefix+M: popup with the next meeting's details + join link
      bind M display-popup -w 60% -h 50% -T " 󰤙 meetings " -E "$HOME/.config/tmux/scripts/cal.sh _popupbody"
      bind K send-keys "clear"\; send-keys "Enter"
      bind-key -T copy-mode-vi v send-keys -X begin-selection

      # ---- background-loaded plugins (bind keys only — don't block startup) ----
      # Options are set synchronously; the plugin scripts then load async via
      # `run-shell -b`, cutting ~0.7s off server start. Their keys bind a
      # fraction of a second after start — imperceptible in normal use.
      set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
      set -g @fzf-url-history-limit '2000'
      set -g @sessionx-bind-zo-new-window 'ctrl-y'
      set -g @sessionx-auto-accept 'off'
      set -g @sessionx-custom-paths '/Users/code/dotfiles'
      set -g @sessionx-bind 'o'
      set -g @sessionx-x-path '~/dotfiles'
      set -g @sessionx-window-height '85%'
      set -g @sessionx-window-width '75%'
      set -g @sessionx-zoxide-mode 'on'
      set -g @sessionx-custom-paths-subdirectories 'false'
      set -g @sessionx-filter-current 'false'
      set -g @floax-width '80%'
      set -g @floax-height '80%'
      set -g @floax-border-color 'magenta'
      set -g @floax-text-color 'blue'
      set -g @floax-bind 'p'
      set -g @floax-change-path 'true'
      run-shell -b ${pkgs.tmuxPlugins.yank.rtp}
      run-shell -b ${pkgs.tmuxPlugins.tmux-thumbs.rtp}
      run-shell -b ${pkgs.tmuxPlugins.tmux-fzf.rtp}
      run-shell -b ${pkgs.tmuxPlugins.fzf-tmux-url.rtp}
      run-shell -b ${pkgs.tmuxPlugins.tmux-sessionx.rtp}
      run-shell -b ${pkgs.tmuxPlugins.tmux-floax.rtp}
    '';
  };
}
