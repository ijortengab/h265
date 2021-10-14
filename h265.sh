#!/bin/bash

ctrl_c() {
    printf "\r\033[K%s\n" '    Aborted.'
    if [ -e "$tempfile" ];then
        rm "$tempfile"
        echo '    Delete file:' "$tempfile"
    fi
    # Send trigger for break 'while true'
    touch h265.stop
    exit
}
isTemp() {
    local output
    output=$(echo "$1" | grep -i -E '\.h265_converting\.mp4$')
    if [ -n "$output" ];then
        return 0
    fi
    return 1
}
ish264() {
    local output
    # Stream #0:0(und): Video: h264 (avc1 / 0x31637661),
    output=$(ffmpeg -i "$1" 2>&1 | grep -i -E '^\s+Stream.*Video.*h264')
    if [ -n "$output" ];then
        return 0
    fi
    return 1
}
ish265() {
    local output
    # Stream #0:0(eng): Video: hevc (hvc1 / 0x31637668),
    output=$(ffmpeg -i "$1" 2>&1 | grep -i -E '^\s+Stream.*Video.*hevc')
    if [ -n "$output" ];then
        return 0
    fi
    return 1
}
_convertNow() {
    ffmpeg \
        -i "$1" \
        -c:v libx265 \
        -c:a copy "$2" 2>&1 | tee -a "$3" > /dev/null
}
convertNow() {
    local path
    local full_path basename extension filename
    full_path=$(realpath "$1")
    basename=$(basename -- "$full_path")
    extension="${basename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    filename="${basename%.*}"
    tempfile=${filename}.h265_converting.${extension}
    if [ ! -e "$tempfile" ];then
        mkdir -p h265_log
        trap ctrl_c INT
        duration=$(getDuration "$1")
        echo -n '    'Duration: "$duration". Progress:
        echo ' tail -f "'"h265_log/${filename}.log"'"'
        _convertNow "$1" "$tempfile" "h265_log/${filename}.log" &
        pid=$!
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
          i=$(( (i+1) %4 ))
          printf "\r    Converting...${spin:$i:1}"
          sleep .1
        done
        printf "\r\033[K%s\n" '    Converted.'
        touch -r "$1" "$tempfile"
        if [ -e "$1" ];then
            mkdir -p h264_existing
            mv "$1" h264_existing/"$1"
            echo '    'Move original file to directory: h264_existing.
        fi
        if [ -e "$tempfile" ];then
            mkdir -p h265_converted
            mv "$tempfile" h265_converted/"$1"
            echo '    'Move converted file to directory: h265_converted.
        fi
    fi
}
getDuration() {
    ffmpeg -i "$1" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
}
while true; do
    find * -maxdepth 0 -iname '*.mp4' | head -1 | while IFS= read -r path; do
        if isTemp "$path";then
            echo File "$path" is temporary file.
            mkdir -p mp4_unknown
            mv "$path" -t mp4_unknown
            echo '    'Move file to directory: mp4_unknown.
        elif ish264 "$path";then
            echo File "$path" is h264 encoding.
            convertNow "$path"
        elif ish265 "$path";then
            echo File "$path" is h265 encoding.
            mkdir -p h265_existing
            mv "$path" -t h265_existing
            echo '    'Move file to directory: h265_existing.
        else
            echo File "$path" is unknown encoding.
            mkdir -p mp4_unknown
            mv "$path" -t mp4_unknown
            echo '    'Move file to directory: mp4_unknown.
        fi
    done
    count=$(find * -maxdepth 0 -iname '*.mp4' | wc -l)
    if [[ $count == 0 ]];then
        break
    fi
    if [ -e 'h265.stop' ];then
        rm 'h265.stop'
        break
    fi
done
