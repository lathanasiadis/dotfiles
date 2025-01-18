#!/bin/sh

run() {
    if ! pgrep -f "$1" ;
    then
        "$@"&
    fi
}

setxkbmap -layout us,gr -option 'grp:win_space_toggle' -option 'compose:ralt'

run flameshot
run picom --backend xrender
run redshift -l 37.98:23.73
