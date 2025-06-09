#!/bin/bash

#--------------------------
# Global vars
#--------------------------

# Set DEBUG_MODE to either "YES" or "no"
DEBUG_MODE="no" 

#--------------------------
# Functions
#--------------------------

get_vid_length () {
    # usage: get_vid_length somevideo.MOV
    # e.g: ffprobe -i somevideo.MOV -show_entries format=duration -v quiet -of csv="p=0"
    local vlength=$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")
    #echo "$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")"
    printf %.0f $vlength
}

out_of_x_num () {
    # expects all tree arguments are numbers
    # $1: numerator, $2: denominator, $3: multiple x
    local prop=$(bc <<< "scale=3; $1 / $2")
    local out_of_x_num=$(bc <<< "scale=0; $prop * $3")
    printf %.0f $out_of_x_num
}

out_of_x () {
    # $1: numerator, $2: denominator, $3: multiple x
    # all params should be numbers.
    # If any are 0 will return 0, if all non-0 will pass
    # them to out_of_x_num for calculation
    local result=0
    if [[ -z "$3" ]] || [[ "$3" -eq "0" ]]; then
        echo -n "0";
    elif [[ -z "$2" ]] || [[ "$2" -eq "0" ]]; then
        echo -n "0";
    elif [[ -z "$1" ]] || [[ "$1" -eq "0" ]]; then
        echo -n "0"
    else
        echo -n "$(out_of_x_num $1 $2 $3)"
    fi
}

strip_leading_zeros () {
    # expects one argument
    # will strip leading zeros from and return the result
    # mm=$(echo "$mg" | sed 's/^0*//')
    local stripped_result
    local stripped=$(echo "$1" | sed 's/^0*//')
    if [ -z "$stripped" ]; then
        stripped_result="0"
    else
        stripped_result=$stripped
    fi
    echo -n $stripped_result
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

VID_LENGTH=$(get_vid_length ${input_mov_file})
echo ":: Video length (seconds): ${VID_LENGTH}"

# https://stackoverflow.com/questions/47115191/when-i-run-ffmpeg-in-the-background-how-do-i-prevent-suspended-tty-output
# https://stackoverflow.com/questions/8220098/how-to-redirect-the-output-of-an-application-in-background-to-dev-null
ffmpeg -nostdin -loglevel quiet -progress ${logfile} -i ${input_mov_file} -c:v libx265 -crf 28 -preset medium -tag:v hvc1 -c:a aac -b:a 128k ${MP4filename} > /dev/null 2>&1 & XPID=$!

echo ""
let grep_result=1
while ((grep_result>0)) && [ -e /proc/$XPID ]  ; do

    out_time_string=$(grep 'out_time=' ${logfile} | tail -n 1)
    if [ -z "$out_time_string" ]; then
        out_time_string="00";
    fi

    # strip any leading zeros out to prevent numbers being interpreted as octals etc
    # see https://www.reddit.com/r/bash/comments/wql7y1/arimetic_evaluation_value_too_great_for_base/
    out_time_string=$(strip_leading_zeros $out_time_string)
    
    outsecs=$(echo $out_time_string | grep -Eo ':[0-9][0-9]\.' | grep -Eo '[0-9]{2}')
    if [ -z "$outsecs" ]; then
        outsecs="00";
    fi

    # strip any leading zeros out to prevent numbers being interpreted as octals etc
    outsecs=$(strip_leading_zeros $outsecs)
    
    percent_comp=$(out_of_x $outsecs $VID_LENGTH 100)
    
    # https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
    if [ "$DEBUG_MODE" = "YES" ]; then
        echo -e                 ":: ${out_time_string} $(grep speed ${logfile} | tail -n 1) ${outsecs} (${percent_comp})"
    else
        echo -e "\r\033[1A\033[0K:: ${out_time_string} $(grep speed ${logfile} | tail -n 1) ${outsecs} (${percent_comp})"
    fi
        
    grep 'progress=end' ${logfile} > /dev/null 2>&1
    let grep_result=$?
    sleep 2
done

grep 'progress=end' ${logfile} > /dev/null 2>&1
let grep_result2=$?
echo ":: Result: ${grep_result2}"
rm $logfile
exit $grep_result2

