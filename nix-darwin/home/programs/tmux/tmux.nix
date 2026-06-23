# tmux — managed natively by Home Manager (no TPM).
# Plugins are pulled from the nix store, so they're always present after a
# rebuild, load deterministically, and skip TPM's ~260ms shell-out on every
# start/reload. tmux-sensible loads first via `sensibleOnTop`.
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 1000000;
    keyMode = "vi";
    terminal = "tmux-256color";
    sensibleOnTop = true;   # load tmux-sensible defaults at the top
    focusEvents = true;     # let vim/nvim detect terminal focus (FocusGained)

    plugins = with pkgs.tmuxPlugins; [
      yank
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        # continuum must load after resurrect
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      tmux-thumbs
      tmux-fzf
      {
        plugin = fzf-tmux-url;
        extraConfig = ''
          set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
          set -g @fzf-url-history-limit '2000'
        '';
      }
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
        plugin = tmux-sessionx;
        extraConfig = ''
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
        '';
      }
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color 'magenta'
          set -g @floax-text-color 'blue'
          set -g @floax-bind 'p'
          set -g @floax-change-path 'true'
        '';
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

      # ---- catppuccin status line (built AFTER the plugin has loaded) ----
      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_directory}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"

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
      bind K send-keys "clear"\; send-keys "Enter"
      bind-key -T copy-mode-vi v send-keys -X begin-selection
    '';
  };
}
