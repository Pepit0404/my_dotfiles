#!/bin/bash
speed=0

# Load parameters
while [[ $# > 0 ]]
do
        case "$1" in

                -s|--speed)
                        speed=1
                        shift
                        ;;

                -h|--help|*)
                        echo "Usage:"
                        echo "    -s,  --speed \"does not execute package upgrade\""
                        echo "    -h,  --help"
                        exit 1
                        ;;
        esac
        shift
done

if [[ $speed == 0 ]]; then
    apt update
    apt upgrade
    echo 'not speed'
fi

echo -n "ZSH installation: "
if [ "$(zsh --version 2> /dev/null)" == "" ]; then 
    apt install -y zsh
    echo 'Finish'
else
    echo 'already installed'
fi

echo -n "VIM installation: "
if [ "$(vim --version 2> /dev/null)" == "" ]; then
    apt install -y vim 
    echo 'Finish'
else
    echo 'already installed'
fi
