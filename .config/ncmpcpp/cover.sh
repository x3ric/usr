#!/bin/bash

# Script intended to be executed from ncmpcpp (execute_on_song_change
# preference) running from urxvt to set album cover as background image

# Copyright (c) 2013  Vyacheslav Levit
# Licensed under The MIT License: http://opensource.org/licenses/MIT

MUSIC_DIR=$HOME/Music
DARKEN=50         # 0 - original image colors, 100 - absolutely black background

TMP=/tmp
COVER=/tmp/cover.jpg
IM_ARGS=(-limit memory 32mb -limit map 64mb)

function reset_background
{
    # is there any better way?
    printf "\e]20;;100x100+1000+1000\a"
}

{
    album="$(mpc --format %album% current)"
    file="$(mpc --format %file% current)"
    album_dir="${file%/*}"
    [[ -z "$album_dir" ]] && exit 1
    album_dir="$MUSIC_DIR/$album_dir"

    covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \; )"
    src="$(echo -n "$covers" | head -n1)"
    darkenimg="$TMP/darken.jpg"
    rm -f "$COVER" "$darkenimg"
    if [[ -n "$src" ]] ; then
        light="$((100 - $DARKEN))"
        convert "${IM_ARGS[@]}" "$src" -fill "gray${light}" +level ${light}%,${light}% \
            +matte "$darkenimg"
        composite "${IM_ARGS[@]}" "$darkenimg" -compose Multiply "$src" "$COVER"
        if [[ -f "$COVER" ]] ; then
            bgcolor=$(convert "${IM_ARGS[@]}" "$COVER" -scale 1x1 -format \
                '%[fx:int(255*r+.5)] %[fx:int(255*g+.5)] %[fx:int(255*b+.5)]' info:-)
            for c in $bgcolor ; do
                bghex=$bghex/$(printf %02x $c)
            done
            bghex=${bghex:1}

            printf "\e]11;rgb:${bghex}\a"
            printf "\e]708;rgb:${bghex}\a"
            printf "\e]20;${COVER};100x100+50+50:op=keep-aspect\a"
        else
            reset_background
        fi
    else
        reset_background
    fi
} &