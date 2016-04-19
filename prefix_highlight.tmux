#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{prefix_highlight}"

# Possible configurations
fg_color_config='@prefix_highlight_fg'
bg_color_config='@prefix_highlight_bg'
show_copy_config='@prefix_highlight_show_copy_mode'
copy_attr_config='@prefix_highlight_copy_mode_attr'

# Defaults
default_fg='colour231'
default_bg='colour04'
default_copy_attr='fg=default,bg=yellow'

# internal variables
prefix_attr_var='@_prefix_highlight_attr_prefix'
copy_attr_var='@_prefix_highlight_attr_copy'

tmux_option() {
    local -r value=$(tmux show-option -gqv "$1")
    local -r default="$2"

    if [ ! -z "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

highlight() {
    local -r status="$1" prefix="$2" show_copy_mode="$3"
    local -r status_value=$(tmux_option "$status")
    if [[ "on" = "$show_copy_mode" ]]; then
        local -r fallback="#{?pane_in_mode,#{$copy_attr_var}Copy,}"
    else
        local -r fallback=""
    fi
    local -r highlight_on_prefix="#{?client_prefix,#{$prefix_attr_var} $prefix ,$fallback}#[default]"

    tmux set-option -gq "$status" "${status_value/$place_holder/$highlight_on_prefix}"
}

main() {
    local -r \
        prefix=$(tmux_option prefix) \
        fg_color=$(tmux_option "$fg_color_config" "$default_fg") \
        bg_color=$(tmux_option "$bg_color_config" "$default_bg") \
        show_copy_mode=$(tmux_option "$show_copy_config") \
        copy_attr=$(tmux_option "$copy_attr_config" "$default_copy_attr")

    local -r short_prefix=$(
        echo "$prefix" | tr "[:lower:]" "[:upper:]" | sed 's/C-/\^/'
    )

    # set internal variables
    tmux set-option -gq "$prefix_attr_var" "#[fg=$fg_color,bg=$bg_color]" \; \
        set-option -gq "$copy_attr_var" "${copy_attr:+#[default,$copy_attr]}"

    highlight "status-right" "$short_prefix" "$show_copy_mode"
    highlight "status-left" "$short_prefix" "$show_copy_mode"
}

main
