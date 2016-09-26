#!/usr/bin/env bash

set -e

# Place holder for status left/right
place_holder="\#{prefix_highlight}"

# Possible configurations
fg_color_config='@prefix_highlight_fg'
bg_color_config='@prefix_highlight_bg'
separator='@prefix_highlight_separator'
show_separator_before='@prefix_highlight_show_separator_before'
show_separator_after='@prefix_highlight_show_separator_after'
show_copy_config='@prefix_highlight_show_copy_mode'
copy_attr_config='@prefix_highlight_copy_mode_attr'

# Defaults
default_fg='colour231'
default_bg='colour04'
default_copy_attr='fg=default,bg=yellow'

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
    local -r \
        status="$1" \
        prefix="$2" \
        prefix_highlight="$3" \
        show_copy_mode="$4" \
        copy_highlight="$5" \
        show_separator_before="$6" \
        show_separator_after="$7" \
        separator="$8" \

    local -r status_value="$(tmux_option "$status")"

    local prefix_with_optional_separators="$prefix"
    local copy_with_optional_separators="Copy"

    if [[ "on" = "$show_separator_before" ]]; then
        local prefix_with_optional_separators="$separator $prefix_with_optional_separators"
        local copy_with_optional_separators="$separator $copy_with_optional_separators"
    fi

    if [[ "on" = "$show_separator_after" ]]; then
        local prefix_with_optional_separators="$prefix_with_optional_separators $separator"
        local copy_with_optional_separators="$copy_with_optional_separators $separator"
    fi

    if [[ "on" = "$show_copy_mode" ]]; then
        local -r fallback="${copy_highlight}#{?pane_in_mode, $copy_with_optional_separators, }"
    else
        local -r fallback=""
    fi

    local -r highlight_on_prefix="${prefix_highlight}#{?client_prefix, $prefix_with_optional_separators, $fallback}#[default]"
    tmux set-option -gq "$status" "${status_value/$place_holder/$highlight_on_prefix}"
}

main() {
    local -r \
        prefix=$(tmux_option prefix) \
        fg_color=$(tmux_option "$fg_color_config" "$default_fg") \
        bg_color=$(tmux_option "$bg_color_config" "$default_bg") \
        show_copy_mode=$(tmux_option "$show_copy_config" "off") \
        show_separator_before=$(tmux_option "$show_separator_before" "off") \
        show_separator_after=$(tmux_option "$show_separator_after" "off") \
        separator=$(tmux_option "$separator" "|") \
        copy_attr=$(tmux_option "$copy_attr_config" "$default_copy_attr")

    local -r short_prefix=$(
        echo "$prefix" | tr "[:lower:]" "[:upper:]" | sed 's/C-/\^/'
    )

    local -r \
        prefix_highlight="#[fg=$fg_color,bg=$bg_color]" \
        copy_highlight="${copy_attr:+#[default,$copy_attr]}"

    highlight "status-right" \
              "$short_prefix" \
              "$prefix_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$show_separator_before" \
              "$show_separator_after" \
              "$separator"

    highlight "status-left" \
              "$short_prefix" \
              "$prefix_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$show_separator_before" \
              "$show_separator_after" \
              "$separator"
}

main
