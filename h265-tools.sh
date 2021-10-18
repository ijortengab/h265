#!/bin/bash

option=
selected=0
welcome=1
clear
until [[ "$option" == 0 ]]; do
    case "$option" in
        1)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.mp4\' -path \'*h264_existing*\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -iname '*.mp4' -path '*h264_existing*' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -iname '*.mp4' -path '*h264_existing*'
                echo
                echo "Found $count file(s). Type yes to delete."
                echo
                option=1a
                continue
            fi
        ;;
        1a)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.mp4\' -path \'*h264_existing*\' -delete
            echo -ne "\e[0m"
            echo
            read -p "Are you sure wants to delete all? " areyousure
            echo
            if [[ "$areyousure" == "yes" ]]; then
                find . -type f -iname '*.mp4' -path '*h264_existing*' -delete
                echo "Deleted."
            else
                echo "Ignored."
            fi
            echo
        ;;
        2)
            echo -ne "\e[35m"
            echo find . -iname \'*.mp4\' -path \'*h265_converted*\' -o -path \'*h265_existing*\' -type f
            echo -ne "\e[0m"
            echo
            count=$(find . -iname '*.mp4' -path '*h265_converted*' -o -path '*h265_existing*' -type f | wc -l)
            if [[ $count -gt 0 ]];then
                find . -iname '*.mp4' -path '*h265_converted*' -o -path '*h265_existing*' -type f
                echo
                echo "Found $count file(s). Type yes to move to parent directory."
                echo
                option=2a
                continue
            fi
        ;;
        2a)
            echo -ne "\e[35m"
            echo find . -iname \'*.mp4\' \\\( -path \'*h265_converted*\' -o -path \'*h265_existing*\' \\\) -type f  \
                -exec sh -c \'echo \"\$0\"\; _dir=\$\(dirname \"\$0\"\)\;  dir=\$\(dirname \"\$_dir\"\)\; mv \"\$0\" -t \"\$dir\"\' \{\} \\\;
            echo -ne "\e[0m"
            echo
            read -p "Are you sure wants move all to parent directory? " areyousure
            echo
            if [[ "$areyousure" == "yes" ]]; then
                find . -iname '*.mp4' \( -path '*h265_converted*' -o -path '*h265_existing*' \) -type f  \
                    -exec sh -c '_dir=$(dirname "$0");  dir=$(dirname "$_dir"); mv "$0" -t "$dir"' {} \;
                echo "Moved."
            else
                echo "Ignored."
            fi
            echo
        ;;
        3)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.log\' -path \'*h265_log*\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -iname '*.log' -path '*h265_log*' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -iname '*.log' -path '*h265_log*'
                echo
                echo "Found $count file(s). Type yes to delete."
                echo
                option=3a
                continue
            fi
        ;;
        3a)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.log\' -path \'*h265_log*\' -delete
            echo -ne "\e[0m"
            echo
            read -p "Are you sure wants to delete all? " areyousure
            echo
            if [[ "$areyousure" == "yes" ]]; then
                find . -type f -iname '*.log' -path '*h265_log*' -delete
                echo "Deleted."
            else
                echo "Ignored."
            fi
            echo
        ;;
        4)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.mp4\' -path \'*mp4_unknown*\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -iname '*.mp4' -path '*mp4_unknown*' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -iname '*.mp4' -path '*mp4_unknown*'
                echo
                echo "Found $count file(s). Type yes to delete."
                echo
                option=4a
                continue
            fi
        ;;
        4a)
            echo -ne "\e[35m"
            echo find . -type f -iname \'*.mp4\' -path \'*mp4_unknown*\' -delete
            echo -ne "\e[0m"
            echo
            read -p "Are you sure wants to delete all? " areyousure
            echo
            if [[ "$areyousure" == "yes" ]]; then
                find . -type f -iname '*.mp4' -path '*mp4_unknown*' -delete
                echo "Deleted."
            else
                echo "Ignored."
            fi
            echo
        ;;
        5)
            echo -ne "\e[35m"
            echo find . \
                -type d \
                \\\( -path \'*h264_existing*\' \
                -o -path \'*h265_existing*\' \
                -o -path \'*h265_converted*\' \
                -o -path \'*mp4_unknown*\' \
                -o -path \'*h265_log*\' \\\) \
                -empty
            echo -ne "\e[0m"
            echo
            count=$(find . \
                -type d \
                \( -path '*h264_existing*' \
                -o -path '*h265_existing*' \
                -o -path '*h265_converted*' \
                -o -path '*mp4_unknown*' \
                -o -path '*h265_log*' \) \
                -empty | wc -l)
            if [[ $count -gt 0 ]];then
                find . \
                    -type d \
                    \( -path '*h264_existing*' \
                    -o -path '*h265_existing*' \
                    -o -path '*h265_converted*' \
                    -o -path '*mp4_unknown*' \
                    -o -path '*h265_log*' \) \
                    -empty
                find . \
                    -type d \
                    \( -path '*h264_existing*' \
                    -o -path '*h265_existing*' \
                    -o -path '*h265_converted*' \
                    -o -path '*mp4_unknown*' \
                    -o -path '*h265_log*' \) \
                    -empty -delete
                echo
            fi
        ;;
    esac
    if [[ $selected == 1 ]];then
        echo -ne " [\e[33m0\e[0m] "
        echo Finish
        echo -ne " [\e[33m*\e[0m] "
        echo Back to menu
        echo
        read -rsn1 -p "Your option: " option; echo
        if [[ $option == 0 ]];then
            break
        fi
        clear
        option=
        selected=0
    fi
    if [[ $welcome == 1 ]];then
        echo -ne "\e[32mWelcome to h265 tools.\e[0m\n"
        echo -ne "\e[32mJust hit the \e[33myellow\e[32m number without following the Enter key.\e[0m\n"
        echo
        welcome=
    else
        echo "What's next?"
        echo
    fi
    echo -ne " [\e[33m0\e[0m] "
    echo Cancel
    echo -ne " [\e[33m1\e[0m] "
    echo Find mp4 file inside h264_existing directory '(then ask to delete)'
    echo -ne " [\e[33m2\e[0m] "
    echo Find mp4 file inside h265_converted or h265_existing directory
    echo '     (then ask to move)'
    echo -ne " [\e[33m3\e[0m] "
    echo Find log file inside h265_log directory '(then ask to delete)'
    echo -ne " [\e[33m4\e[0m] "
    echo Find mp4 file inside mp4_unknown directory '(then ask to delete)'
    echo -ne " [\e[33m5\e[0m] "
    echo Remove empty directory '(no confirmation)':
    echo '     'h264_existing, h265_converted, h265_log, mp4_unknown
    echo
    read -rsn1 -p "Your option: " option; echo
    echo
    until [[ -n "$option" && "$option" =~ ^[0-5]$ ]]; do
        if [[ -n "$option" ]];then
            echo -n "[$option] Invalid selection. "
        fi
        read -rsn1 -p "Your option: " option; echo
        echo
    done
    selected=1
done
