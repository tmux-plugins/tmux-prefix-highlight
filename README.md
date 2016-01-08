# Tmux prefix highlight

Plugin that highlights when you press tmux prefix key. Inspired by 
[this](http://stackoverflow.com/questions/12003726/give-a-hint-when-press-prefix-key-in-tmux)
thread on stackoverflow.

Many thanks to [@obxhdx](https://github.com/obxhdx) for showing me this trick.

Prefix off:
![prefix_off](screenshots/prefix_off.png)

Prefix on:
![prefix_on](screenshots/prefix_on.png)

### Usage

Just add `#{prefix_highlight}` to your left/right status bar.

```tmux.confi
set -g status-right '#{prefix_highlight} | %a %Y-%m-%d %H:%M'
```

### Installation with Tmux Plugin Manager (recommended)

Add plugin to the list of TPM plugins:

```tmux.conf
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
```

Press prefix + I to install it.

### Manual Installation

Clone the repo:

```bash
$ git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git ~/clone/path
```

Add this line to your .tmux.conf:

```tmux.conf
run-shell ~/clone/path/prefix_highlight.tmux
```

Reload TMUX environment with:

```bash
$ tmux source-file ~/.tmux.conf
```

### Configurations

```tmux.conf
set -g @prefix_highlight_fg 'white'
set -g @prefix_highlight_bg 'blue'
```

### License

[MIT](LICENSE)
