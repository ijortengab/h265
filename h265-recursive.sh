#!/bin/bash

command -v "h265.sh" >/dev/null || { echo "h265.sh command not found."; exit 1; }

pwd="$PWD"

find * -type d \
    ! -path '*h264_existing*' \
    ! -path '*h265_existing*' \
    ! -path '*h265_converted*' \
    ! -path '*mp4_unknown*' \
    ! -path '*h265_log*' \
    | while IFS= read -r path; do
    path="${pwd}/${path}";
    echo -ne "\e[35m" >&2; echo -n "cd '$path'"; echo -ne "\e[0m" >&2; echo
    cd "$path"; h265.sh
done
