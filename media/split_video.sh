#!/bin/bash

set -e

# https://stackoverflow.com/questions/64105342/ffmpeg-split-video-to-segments-with-audio
ffmpeg -i *.mkv \
       -segment_time 60 \
       -segment_wrap 1000 \
       -segment_list_size 0 \
       -segment_list video.m3u8 \
       -segment_list_flags +cache \
       -segment_list_type m3u8 \
       -f segment \
       video-%03d.ts
