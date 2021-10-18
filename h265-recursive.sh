#!/bin/bash

command -v "h265.sh" >/dev/null || { echo "h265.sh command not found."; exit 1; }

find . -type d \
    ! -path '*h264_existing*' \
    ! -path '*h265_existing*' \
    ! -path '*h265_converted*' \
    ! -path '*mp4_unknown*' \
    ! -path '*h265_log*' \
    -exec sh -c 'echo "$0"; cd "$0"; h265.sh' {} \;
