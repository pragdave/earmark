#!/usr/bin/env zsh

# Copy me into any mix project directory as `.tmux.zsh` and `cd2project <that dir>` Will Just Work ™
export session_home_dir="$(dirname $0)"
export session_name="$(basename ${session_home_dir})"

source $Lab42MyZsh/tools/tmux.zsh

function init_new_session {

    new_command_in_window mainvim 'vip git .'

    new_command_in_window vilib "vip lib lib/{.,$session_name}"

    new_window 'mix test'

    new_command_in_window vitest "vip spec test/{.,$session_name}"
    new_command_in_window console 'iex -S mix'
    new_window etc
}

attach_or_create
