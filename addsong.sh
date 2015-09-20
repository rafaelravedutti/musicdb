#!/bin/bash

DATABASE_PATH=db1
LOGFILE=musicdb.log

filepath="$1"

function log {
  echo "$1" && echo "[$(date '+%m/%d/%y %H:%M:%S')] \"$filepath\": $1" >> "$LOGFILE"
}

[ ! -f "$1" ] && log "File doesn't exist!" && exit

filename=$(echo "${filepath##*/}" | tr -s " ")
fileformat="${filename##*.}"
filetype="$(file -b "$1")"

[[ ! $fileformat =~ mp3|wav|wma|ogg|aac|flac|alac|aiff ]] && log "Invalid file format" && exit
[[ ! $filetype =~ ID3 ]] && log "File is not a valid ID3 tag file!" && exit
[[ ! $filetype =~ Audio ]] && log "File is not a valid audio file!" && exit

genre=$(id3v2 -l "$1" | grep -m 1 -aE "^(TCON|TCO) ")
[ -z "$genre" ] && id3v2 -C "$1" && genre=$(id3v2 -l "$1" | grep -aE "^(TCON|TCO) ") 
genre="${genre##*: }" && genre="${genre% ([0-9]*)}"
[ -z "$genre" ] && log "Invalid song genre, please specify it!" && exit

artist=$(id3v2 -l "$1" | grep -m 1 -aE "^(TPE1|TP1) ") && artist="${artist#*: }"
[ -n "$artist" ] || artist="${filename%% - *}"
[ -z "$artist" ] && log "Invalid song artist, please specify it!" && exit

title=$(id3v2 -l "$1" | grep -m 1 -aE "^(TIT2|TT2) ") && title="${title#*: }"
[ -z "$title" ] && title="${filename##* - }" && title="${title%.*}"
[ -z "$title" ] && log "Invalid song title, please specify it!" && exit

album=$(id3v2 -l "$1" | grep -m 1 -a "^TALB ") && album="${album#*: }"
[ -z "$album" ] && album="Unknown Album"

genre=${genre//\//-} && artist=${artist//\//-} && title=${title//\//-} && album=${album//\//-}

path="$DATABASE_PATH/$genre/$artist/$album/$title.$fileformat"
mkdir -p "${path%/*}" && cp -p "$1" "$path"
