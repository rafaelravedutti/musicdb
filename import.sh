#!/bin/bash

while read track; do
  [[ $track =~ ^.*\.(mp3|wav|wma|ogg|aac|flac|alac|aiff)$ ]] && ./addsong.sh "$track"
done
