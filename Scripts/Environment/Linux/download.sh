#!/bin/bash
# Script to download WRCCDC archive images

RED="31"
GREEN="32"
BOLDGREEN="\e[1;${GREEN}m"
ITALICRED="\e[3;${RED}m"
ENDCOLOR="\e[0m"

URL='https://archive.wrccdc.org/images/2022/wrccdc-2022-invitationals/'

files=(
    'bubble.lol.ova'
    'cptspaulding-alt.lol.ova'
    'cptspaulding.loldonotuse.ova'
    'drrockso.lol.ova'
    'freddie.lol.ova'
    'happyslappy.lol.ova'
    'joker.lol.ova'
    'pesky.lol.ova'
    'ronaldmcdonald.lol.ova'
    'sideshowbob.lol.ova'
    'wearywillie.lol.ova'
)

# mkdir images

mkdir -p images && cd images || exit

for file in "${files[@]}"; do
    echo -e "${BOLDGREEN}Downloading ${file}...${ENDCOLOR}"
    wget -k "${URL}${file}" &
    sleep 15;
    echo -e "${ITALICRED}Done!${ENDCOLOR}"
done
