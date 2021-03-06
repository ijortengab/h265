#!/bin/bash

if [ -e 'h265.lock' ];then
    echo 'This directory may be being processed by someone else.'
    echo 'Check process by yourself, then remove lock file manually.'
    echo -ne "\e[35m" >&2; echo -n "rm '$PWD/h265.lock'"; echo -ne "\e[0m" >&2; echo
    exit
fi

command -v "ffmpeg" >/dev/null || { echo "ffmpeg command not found."; exit 1; }

if [ -e 'h265.stop' ];then
    rm 'h265.stop'
    echo -n "Delete file: "; echo -ne "\e[33m" >&2; echo -n "h265.stop"; echo -ne "\e[0m" >&2; echo
fi

ctrl_c() {
    printf "\r\033[K" >&2
    printf "%s\n" '    Aborted.'
    if [ -e "$tempfile" ];then
        rm "$tempfile"
        echo -n "    Delete file: "; echo -ne "\e[33m" >&2; echo -n "$tempfile"; echo -ne "\e[0m" >&2; echo
    fi
    # Send trigger for break 'while true'
    touch h265.stop
    # Autokill tail.
    pidtail=$(getPid tail "tail -f $templog")
    if [ -n "$pidtail" ];then
        kill $pidtail
    fi
    rm "$templog"
    exit
}
getPid() {
    if [[ $(uname) == "Linux" ]];then
        pid=$(ps aux | grep "$2" | grep -v grep | awk '{print $2}')
        echo $pid
    elif [[ $(uname | cut -c1-6) == "CYGWIN" ]];then
        local pid command ifs
        ifs=$IFS
        ps -s | grep "$1" | awk '{print $1}' | while IFS= read -r pid; do\
            command=$(cat /proc/${pid}/cmdline | tr '\0' ' ')
            command=$(echo "$command" | sed 's/\ $//')
            if [[ "$command" == "$2" ]];then
                echo $pid
                break
            fi
        done
        IFS=$ifs
    fi
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
    local full_path basename extension filename
    local pid spin i pidtail before after percentage size
    local duration logfile templog start end runtime hours minutes seconds
    full_path=$(realpath "$1")
    basename=$(basename -- "$full_path")
    extension="${basename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    filename="${basename%.*}"
    tempfile=${filename}.h265_converting.${extension}
    if [ ! -e "$tempfile" ];then
        mkdir -p h265_log
        duration=$(getDuration "$1")
        echo -n "    Duration: ${duration}. Progress : "
        touch "h265_log/${filename}.log"
        logfile=$(realpath "h265_log/${filename}.log")
        templog=$(mktemp)
        ln -s -f "$logfile" "$templog"
        echo -ne "\e[35m" >&2; echo -n "tail -f $templog"; echo -ne "\e[0m" >&2; echo
        start=`date +%s`
        trap ctrl_c INT
        _convertNow "$1" "$tempfile" "h265_log/${filename}.log" &
        pid=$!
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
          i=$(( (i+1) %4 ))
          printf "\r    Converting...${spin:$i:1}" >&2
          sleep .1
        done
        end=`date +%s`
        runtime=$((end-start))
        hours=$((runtime / 3600)); minutes=$(( (runtime % 3600) / 60 )); seconds=$(( (runtime % 3600) % 60 ));
        before=$(wc -c "$1" | awk '{print $1}')
        after=$(wc -c "$tempfile" | awk '{print $1}')
        percentage=$(( $((after*100)) / $((before)) ))
        printf "\r\033[K" >&2
        printf "%s%s. %s: %02d:%02d:%02d. Filesize: %s.\n" '    ' 'Converted' 'Runtime' $hours $minutes $seconds "${percentage}%"
        touch -r "$1" "$tempfile"
        if [ -e "$1" ];then
            size=$(du --apparent-size --block-size=1 -h "$1" | awk '{ print $1}')
            mkdir -p h264_existing
            mv "$1" h264_existing/"$1"
            echo '    'Move original file "($size)" to directory: h264_existing.
        fi
        if [ -e "$tempfile" ];then
            size=$(du --apparent-size --block-size=1 -h "$tempfile" | awk '{ print $1}')
            mkdir -p h265_converted
            mv "$tempfile" h265_converted/"$1"
            echo '    'Move converted file "($size)" to directory: h265_converted.
        fi
        # Autokill tail.
        pidtail=$(getPid tail "tail -f $templog")
        if [ -n "$pidtail" ];then
            kill $pidtail
        fi
        rm "$templog"
    fi
}
getDuration() {
    ffmpeg -i "$1" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
}
touch h265.lock
while true; do
    find * -maxdepth 0 -iname '*.mp4' | head -1 | while IFS= read -r path; do
        echo -n "File "; echo -ne "\e[33m" >&2; echo -n "$path"; echo -ne "\e[0m" >&2; echo -n " is "
        if isTemp "$path";then
            echo temporary file.
            mkdir -p mp4_unknown
            mv "$path" -t mp4_unknown
            echo '    'Move file to directory: mp4_unknown.
        elif ish264 "$path";then
            echo h264 encoding.
            convertNow "$path"
        elif ish265 "$path";then
            echo h265 encoding.
            mkdir -p h265_existing
            mv "$path" -t h265_existing
            echo '    'Move file to directory: h265_existing.
        else
            echo unknown encoding.
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
rm h265.lock
