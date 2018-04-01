#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{prefix_highlight}"

# Possible configurations
fg_color_config='@prefix_highlight_fg'
bg_color_config='@prefix_highlight_bg'
output_prefix='@prefix_highlight_output_prefix'
output_suffix='@prefix_highlight_output_suffix'
show_copy_config='@prefix_highlight_show_copy_mode'
copy_attr_config='@prefix_highlight_copy_mode_attr'
prefix_prompt='@prefix_highlight_prefix_prompt'
copy_prompt='@prefix_highlight_copy_prompt'

tmux_option() {
    local -r value=$(tmux show-option -gqv "$1")
    local -r default="$2"

    if [ ! -z "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Defaults
default_fg='colour231'
default_bg='colour04'
default_copy_attr='fg=default,bg=yellow'
default_prefix_prompt=$(tmux_option prefix | tr "[:lower:]" "[:upper:]" | sed 's/C-/\^/')
default_copy_prompt='Copy'

highlight() {
    local -r \
        status="$1" \
        prefix="$2" \
        prefix_highlight="$3" \
        show_copy_mode="$4" \
        copy_highlight="$5" \
        output_prefix="$6" \
        output_suffix="$7" \
        copy="$8"

    local -r status_value="$(tmux_option "$status")"
    local -r prefix_with_optional_affixes="$output_prefix$prefix$output_suffix"
    local -r copy_with_optional_affixes="$output_prefix$copy$output_suffix"

    if [[ "on" = "$show_copy_mode" ]]; then
        local -r fallback="${copy_highlight}#{?pane_in_mode,$copy_with_optional_affixes,}"
    else
        local -r fallback=""
    fi

    local -r highlight_on_prefix="${prefix_highlight}#{?client_prefix,$prefix_with_optional_affixes,$fallback}#[default]"
    tmux set-option -gq "$status" "${status_value/$place_holder/$highlight_on_prefix}"
}

main() {
    local -r \
        fg_color=$(tmux_option "$fg_color_config" "$default_fg") \
        bg_color=$(tmux_option "$bg_color_config" "$default_bg") \
        show_copy_mode=$(tmux_option "$show_copy_config" "off") \
        output_prefix=$(tmux_option "$output_prefix" " ") \
        output_suffix=$(tmux_option "$output_suffix" " ") \
        copy_attr=$(tmux_option "$copy_attr_config" "$default_copy_attr") \
        prefix_prompt=$(tmux_option "$prefix_prompt" "$default_prefix_prompt") \
        copy_prompt=$(tmux_option "$copy_prompt" "$default_copy_prompt")

    local -r \
        prefix_highlight="#[fg=$fg_color,bg=$bg_color]" \
        copy_highlight="${copy_attr:+#[default,$copy_attr]}"

    highlight "status-right" \
              "$prefix_prompt" \
              "$prefix_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$output_prefix" \
              "$output_suffix" \
              "$copy_prompt"

    highlight "status-left" \
              "$prefix_prompt" \
              "$prefix_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$output_prefix" \
              "$output_suffix" \
              "$copy_prompt"
}

main
