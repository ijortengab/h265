#!/bin/bash

option=
selected=0
welcome=1
clear
until [[ "$option" == 0 ]]; do
    case "$option" in
        1)
            echo -ne "\e[35m"
            echo find . -type f -path \'*h264_existing*\' -iname \'*.mp4\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -path '*h264_existing*' -iname '*.mp4' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -path '*h264_existing*' -iname '*.mp4'
                echo
                echo "Found $count file(s)."
                echo
                option=1a
                continue
            fi
        ;;
        1a)
            echo -ne "\e[35m"
            echo find . -type f -path \'*h264_existing*\' -iname \'*.mp4\' -delete
            echo -ne "\e[0m"
            echo
            echo "Are you sure wants to delete all?"
            echo
            areyousure=
            until [[ "$areyousure" == "yes" || ${#areyousure} == 3 ]]; do
                read -rsn1 -p $'Type \e[33myes\e[0m without following the Enter key or hit Enter key to cancel.' part
                printf "\r\033[K"
                if [[ -z "$part" ]];then
                    break
                fi
                areyousure+="$part"
            done
            if [[ "$areyousure" == "yes" ]];then
                find . -type f -path '*h264_existing*' -iname '*.mp4' -delete
                echo "Deleted."
            else
                echo "Cancelled."
            fi
            echo
        ;;
        2)
            echo -ne "\e[35m"
            echo find . -type f -path \'*h265_converted*\' -o -path \'*h265_existing*\' -iname \'*.mp4\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -path '*h265_converted*' -o -path '*h265_existing*' -iname '*.mp4'| wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -path '*h265_converted*' -o -path '*h265_existing*' -iname '*.mp4'
                echo
                echo "Found $count file(s). Type yes to move to parent directory."
                echo
                option=2a
                continue
            fi
        ;;
        2a)
            echo -ne "\e[35m"
            echo find . -type f  \\\( -path \'*h265_converted*\' -o -path \'*h265_existing*\' \\\) -iname \'*.mp4\' \
                -exec sh -c \'echo \"\$0\"\; _dir=\$\(dirname \"\$0\"\)\;  dir=\$\(dirname \"\$_dir\"\)\; mv \"\$0\" -t \"\$dir\"\' \{\} \\\;
            echo -ne "\e[0m"
            echo
            echo "Are you sure wants move all to parent directory?"
            echo
            areyousure=
            until [[ "$areyousure" == "yes" || ${#areyousure} == 3 ]]; do
                read -rsn1 -p $'Type \e[33myes\e[0m without following the Enter key or hit Enter key to cancel.' part
                printf "\r\033[K"
                if [[ -z "$part" ]];then
                    break
                fi
                areyousure+="$part"
            done
            if [[ "$areyousure" == "yes" ]];then
                find . -type f \( -path '*h265_converted*' -o -path '*h265_existing*' \) -iname '*.mp4' \
                    -exec sh -c '_dir=$(dirname "$0");  dir=$(dirname "$_dir"); mv "$0" -t "$dir"' {} \;
                echo "Moved."
            else
                echo "Cancelled."
            fi
            echo
        ;;
        3)
            echo -ne "\e[35m"
            echo find . -type f -path \'*h265_log*\ -iname \'*.log\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -path '*h265_log*' -iname '*.log' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -iname '*.log' -path '*h265_log*'
                echo
                echo "Found $count file(s)."
                echo
                option=3a
                continue
            fi
        ;;
        3a)
            echo -ne "\e[35m"
            echo find . -type f -path \'*h265_log*\' -iname \'*.log\' -delete
            echo -ne "\e[0m"
            echo
            echo "Are you sure wants to delete all?"
            echo
            areyousure=
            until [[ "$areyousure" == "yes" || ${#areyousure} == 3 ]]; do
                read -rsn1 -p $'Type \e[33myes\e[0m without following the Enter key or hit Enter key to cancel.' part
                printf "\r\033[K"
                if [[ -z "$part" ]];then
                    break
                fi
                areyousure+="$part"
            done
            if [[ "$areyousure" == "yes" ]];then
                find . -type f -path '*h265_log*' -iname '*.log' -delete
                echo "Deleted."
            else
                echo "Cancelled."
            fi
            echo
        ;;
        4)
            echo -ne "\e[35m"
            echo find . -type f -path \'*mp4_unknown*\' -iname \'*.mp4\'
            echo -ne "\e[0m"
            echo
            count=$(find . -type f -path '*mp4_unknown*' -iname '*.mp4' | wc -l)
            if [[ $count -gt 0 ]];then
                find . -type f -path '*mp4_unknown*' -iname '*.mp4'
                echo
                echo "Found $count file(s)."
                echo
                option=4a
                continue
            fi
        ;;
        4a)
            echo -ne "\e[35m"
            echo find . -type f -path \'*mp4_unknown*\' -iname \'*.mp4\' -delete
            echo -ne "\e[0m"
            echo
            echo "Are you sure wants to delete all?"
            echo
            areyousure=
            until [[ "$areyousure" == "yes" || ${#areyousure} == 3 ]]; do
                read -rsn1 -p $'Type \e[33myes\e[0m without following the Enter key or hit Enter key to cancel.' part
                printf "\r\033[K"
                if [[ -z "$part" ]];then
                    break
                fi
                areyousure+="$part"
            done
            if [[ "$areyousure" == "yes" ]];then
                find . -type f -path '*mp4_unknown*' -iname '*.mp4' -delete
                echo "Deleted."
            else
                echo "Cancelled."
            fi
            echo
        ;;
        5)
            count=$(find . \
                -type d \
                \( -path '*h264_existing*' \
                -o -path '*h265_existing*' \
                -o -path '*h265_converted*' \
                -o -path '*mp4_unknown*' \
                -o -path '*h265_log*' \) \
                -empty | wc -l)
            if [[ $count -gt 0 ]];then
                echo -ne "\e[35m"
                echo find . \
                    -type d \
                    \\\( -path \'*h264_existing*\' \
                    -o -path \'*h265_existing*\' \
                    -o -path \'*h265_converted*\' \
                    -o -path \'*mp4_unknown*\' \
                    -o -path \'*h265_log*\' \\\) \
                    -empty -delete
                echo -ne "\e[0m"
                echo
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
            else
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
