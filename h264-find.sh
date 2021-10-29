#!/bin/bash

command -v "ffmpeg" >/dev/null || { echo "ffmpeg command not found."; exit 1; }

ish264() {
    local output
    # Stream #0:0(und): Video: h264 (avc1 / 0x31637661),
    output=$(ffmpeg -i "$1" 2>&1 | grep -i -E '^\s+Stream.*Video.*h264')
    if [ -n "$output" ];then
        return 0
    fi
    return 1
}

find . -type f \
    ! -path '*h264_found*' \
    ! -path '*h264_existing*' \
    ! -path '*h265_existing*' \
    ! -path '*h265_converted*' \
    ! -path '*mp4_unknown*' \
    ! -path '*h265_log*' \
    -iname '*.mp4' | while IFS= read -r path; do
    if ish264 "$path";then
        if [[ "$1" == "-m" ]];then
            dirname=$(dirname "$path")
            echo -n "File "; echo -ne "\e[33m" >&2; echo -n "$path"; echo -ne "\e[0m" >&2; echo -n " is "
            echo h264 encoding.
            echo '    'Move file to directory: h264_found.
            mkdir -p "$dirname"/h264_found
            mv "$path" -t "$dirname"/h264_found
        else
            echo "$path"        
        fi
    fi
done
