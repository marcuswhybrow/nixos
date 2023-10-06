{
  pkgs,

}: pkgs.callPackage ../../pkgs/tmux.nix {
  conf = ''
    set -g default-command "''${SHELL}"

    set -g prefix C-space
    unbind C-b
    bind C-space send-prefix

    # Pane splitting
    bind C-h split-window -h -b  # left
    bind C-j split-window -v     # down
    bind C-k split-window -v -b  # up
    bind C-l split-window -h     # right
    unbind '"'                   # old vertical
    unbind '%'                   # old horizontal

    # Pane switching
    bind h select-pane -L        # left
    bind j select-pane -D        # down
    bind k select-pane -U        # up
    bind l select-pane -R        # right

    # Mouse control
    set -g mouse on

    # Windows
    set-option -g allow-rename off

    # Minimal statusbar
    # https://github.com/niksingh710/minimal-tmux-status/
    set-option -g status-position "bottom"
    set-option -g status-style bg=default,fg=default
    set-option -g status-justify centre
    set-option -g status-left '#[bg=default,fg=default]#{?client_prefix,,  tmux  }#[bg=default,fg=black,bold]#{?client_prefix,  tmux  ,}'
    set-option -g status-right '#S  '
    set-option -g window-status-format ' #I:#W '
    set-option -g window-status-current-format '#[bg=default,fg=black,bold] #I:#W#{?window_zoomed_flag, + , }'

  '';

}
