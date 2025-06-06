#!/bin/bash

#--------------------------
# Functions
#--------------------------

get_vid_length () {
    # usage: get_vid_length somevideo.MOV
    # e.g: ffprobe -i VID_20191205_002640.MOV -show_entries format=duration -v quiet -of csv="p=0"
    echo "$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")"
}

#--------------------------
# Main logic
#--------------------------

# sanity check to make sure an argument has been provided
if [ -z "$1" ]; then
    echo "::  expected one argument (string to pass to append as line to master_learn.md)"
    exit 1
fi

# append the arg1 string to the target file
input_mov_file=$1
MP4filename=$(echo ${input_mov_file} | sed -e 's/MOV$/mp4/')

logfile=".movshrinker"$(date +%s)".txt"
touch $logfile

# https://stackoverflow.com/questions/47115191/when-i-run-ffmpeg-in-the-background-how-do-i-prevent-suspended-tty-output
# https://stackoverflow.com/questions/8220098/how-to-redirect-the-output-of-an-application-in-background-to-dev-null

VID_LENGTH=$(get_vid_length ${input_mov_file})
echo ":: Video length (seconds): ${VID_LENGTH}"

ffmpeg -nostdin -loglevel quiet -progress ${logfile} -i ${input_mov_file} -c:v libx265 -crf 28 -preset medium -tag:v hvc1 -c:a aac -b:a 128k ${MP4filename} > /dev/null 2>&1 & XPID=$!

echo ""
let grep_result=1
while ((grep_result>0)) && [ -e /proc/$XPID ]  ; do
    # https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
    echo -e "\r\033[1A\033[0K:: $(grep 'out_time=' ${logfile} | tail -n 1) $(grep speed ${logfile} | tail -n 1)"
    grep 'progress=end' ${logfile} > /dev/null 2>&1
    let grep_result=$?
    sleep 2
done

grep 'progress=end' ${logfile} > /dev/null 2>&1
let grep_result2=$?
echo ":: Result: ${grep_result2}"
rm $logfile
exit $grep_result2


