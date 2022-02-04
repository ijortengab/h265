## About

Just a simple bash script to bulk convert MP4 file from h264 to h265 codec.

`ffmpeg` or `ffmpeg.exe` is required.

Tested in `Cygwin`, `WSL2`, `Ubuntu 20.04`.

## Install

Just download the shell script and put in your PATH.

```
wget https://raw.githubusercontent.com/ijortengab/h265/master/h265.sh
chmod a+x h265.sh
mv h265.sh -t /usr/local/bin
```

```
curl -O https://raw.githubusercontent.com/ijortengab/h265/master/h265.sh
chmod a+x h265.sh
mv h265.sh -t /usr/local/bin
```

Download all file: `h265.sh`,`h265-tools.sh`,`h265-recursive.sh`,`h264-find.sh`.

```
for filename in h265.sh h265-tools.sh h265-recursive.sh h264-find.sh
do
    wget https://raw.githubusercontent.com/ijortengab/h265/master/$filename
    chmod a+x $filename
    mv $filename -t /usr/local/bin
done
```

```
for filename in h265.sh h265-tools.sh h265-recursive.sh h264-find.sh
do
    curl -O https://raw.githubusercontent.com/ijortengab/h265/master/$filename
    chmod a+x $filename
    mv $filename -t /usr/local/bin
done
```

## How to Use

Just execute this command `h265.sh`, converting will be run. After finish, every
MP4 file in current working directory will be inside in one of these directory:

 - h264_existing
 - h265_existing
 - h265_converted
 - mp4_unknown

## Code Snippet for Recursive

> Tips: It would be better if you use the following two scripts:
> h265-recursive.sh and h265-tools.sh.

Convert all mp4 file inside this directory recursively:

```
find . -type d \
    ! -path '*h264_existing*' \
    ! -path '*h265_existing*' \
    ! -path '*h265_converted*' \
    ! -path '*mp4_unknown*' \
    ! -path '*h265_log*' \
    -exec sh -c 'echo "$0"; cd "$0"; h265.sh' {} \;
```

Find mp4 file inside `h264_existing` directory:

```
find . -type f -path '*h264_existing*' -iname '*.mp4'
```

then delete them:

```
find . -type f -path '*h264_existing*' -iname '*.mp4' -delete
```

Find mp4 file inside `h265_converted` or `h265_existing` directory:

```
find . -type f -path '*h265_converted*' -o -path '*h265_existing*' -iname '*.mp4'
```

then move back to parent directory:

```
find . -type f \( -path '*h265_converted*' -o -path '*h265_existing*' \) -iname '*.mp4' \
    -exec sh -c '_dir=$(dirname "$0");  dir=$(dirname "$_dir"); mv "$0" -t "$dir"' {} \;
```

Find log file:

```
find . -type f -path '*h265_log*' -iname '*.log'
```

then delete them:

```
find . -type f -path '*h265_log*' -iname '*.log' -delete
```

Find mp4 file inside `mp4_unknown` directory:

```
find . -type f -path '*mp4_unknown*' -iname '*.mp4'
```

then delete them:

```
find . -type f -path '*mp4_unknown*' -iname '*.mp4' -delete
```

Find empty directory:

```
find . \
    -type d \
    \( -path '*h264_existing*' \
    -o -path '*h265_existing*' \
    -o -path '*h265_converted*' \
    -o -path '*mp4_unknown*' \
    -o -path '*h265_log*' \) \
    -empty
```

then delete them:

```
find . \
    -type d \
    \( -path '*h264_existing*' \
    -o -path '*h265_existing*' \
    -o -path '*h265_converted*' \
    -o -path '*mp4_unknown*' \
    -o -path '*h265_log*' \) \
    -empty -delete
```

## Reference

Google query "bash loading spinner"

https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator

Google query "bash printf \r clear"

https://stackoverflow.com/questions/2388090/how-to-delete-and-replace-last-line-in-the-terminal-using-bash

Google query "bash time execution"

https://unix.stackexchange.com/questions/52313/how-to-get-execution-time-of-a-script-effectively

Google query "bash string pad"

https://stackoverflow.com/questions/1117134/padding-zeros-in-a-string/1117140
