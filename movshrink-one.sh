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
    # returns video length in whole seconds
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

bar_chart () {
    # expects one argument (number between 0 and 40)
    # returns a string to represent progress  [### ... ]
    local full_bar_points=40
    local done_points=$1
    local remaining_points=$(bc <<< "scale=0; $full_bar_points - $done_points")

    local done_squares=$(printf "%${done_points}s" | tr ' ' '#')

    # Uncomment one of the below two lines
    #local remainingSpc=$(printf "%${remaining_points}s") # fill with whitespace
    local remainingSpc=$(printf "%${remaining_points}s" | tr ' ' '-') # fill with -

    echo -n "[${done_squares}${remainingSpc}]"
}

full_bar_chart () {
    # return 100% progress bar
    echo -n $(bar_chart 40)
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

#logfile=".movshrinker"$(date +%s)".txt"
logfilename="movshrinker"$(date +%s)".txt"

# First attempt to create the log file in /tmp
touch /tmp/${logfilename} > /dev/null 2&>1
touch_tmp_result=$?

# check if we were able to create log file in /tmp
# if so set value of logfile accordingly
# if we were not able to so so we
# fall back on creating the logfile as a hidden
# file in the in the CWD 
if [ "$touch_tmp_result" -eq "0" ]; then # i.e. temp file has been created in /tmp
    logfile="/tmp/${logfilename}"
else # i.e. were not able to create in /tmp, so will create in CWD
    logfilename=".${logfilename}"
    logfile=$logfilename
    touch $logfile
fi

# Get the video length in seconds
VID_LENGTH=$(get_vid_length ${input_mov_file})
echo ":: Video length (seconds): ${VID_LENGTH}"

# https://stackoverflow.com/questions/47115191/when-i-run-ffmpeg-in-the-background-how-do-i-prevent-suspended-tty-output
# https://stackoverflow.com/questions/8220098/how-to-redirect-the-output-of-an-application-in-background-to-dev-null
ffmpeg -nostdin -loglevel quiet -progress ${logfile} -i ${input_mov_file} -c:v libx265 -crf 28 -preset medium -tag:v hvc1 -c:a aac -b:a 128k ${MP4filename} > /dev/null 2>&1 & XPID=$!

echo ""
outsecs="0" # set initial seconds of progress to 0
let grep_result=1
while ((grep_result>0)) && [ -e /proc/$XPID ]  ; do

    out_time_string=$(grep 'out_time=' ${logfile} | tail -n 1)
    if [ -z "$out_time_string" ]; then
        out_time_string="00";
    fi

    # out_time_ms will be set to 0 if the regex returns empty
    # or returns a value less than 0
    # out_time_ms is in microseconds
    #out_time_ms=$(grep 'out_time_ms=' ${logfile} | tail -n 1 | grep -Eo [0-9]+$)
    # grep -E =[0-9]+$ should ensure negative numbers are ignored e.g. =-123 etc
    out_time_ms=$(grep 'out_time_ms=' ${logfile} | tail -n 1 | grep -Eo =[0-9]+$ | grep -Eo [0-9]+)
    if [ -z "$out_time_ms" ]; then
        out_time_ms="0";
    fi

    if [ "$out_time_ms" -lt "0" ]; then
        out_time_ms="0";
    fi

    # convert from microseconds to seconds (whole seconds)
    outsecsMS=$(bc <<< "scale=0; ${out_time_ms} / 1000000")

    
    # strip any leading zeros out to prevent numbers being interpreted as octals etc
    # see https://www.reddit.com/r/bash/comments/wql7y1/arimetic_evaluation_value_too_great_for_base/
    out_time_string=$(strip_leading_zeros $out_time_string)

    # Using out_time_string to get outsecs (commented out as using out_time_ms instead)
    #--------------------------------------------------------------------------------
    #outsecs=$(echo $out_time_string | grep -Eo ':[0-9][0-9]\.' | grep -Eo '[0-9]{2}')
    #if [ -z "$outsecs" ]; then
    #    outsecs="00";
    #fi
    #
    ## strip any leading zeros out to prevent numbers being interpreted as octals etc
    #outsecs=$(strip_leading_zeros $outsecs)

    # set outsecs to outsecsMS if outsecMS is greater than outsecs
    # this has the effect of ratcheting outsecs
    # so the count won't fall to 0 in the case of a loss
    # of input data
    if [ "$outsecsMS" -gt "$outsecs" ]; then
        outsecs=$outsecsMS
    fi
    
    percent_comp=$(out_of_x $outsecs $VID_LENGTH 100)
    barchar_comp=$(out_of_x $outsecs $VID_LENGTH 40)
    progress=$(bar_chart $barchar_comp)

    padded_info=$(printf '%-17s' "$(grep speed ${logfile} | tail -n 1)")
    
    # https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
    if [ "$DEBUG_MODE" = "YES" ]; then
        echo -e                 ":: ${padded_info} ${progress} (${percent_comp}%) ${outsecs}s"
    else
        #echo -e "\r\033[1A\033[0K:: ${progress} ${out_time_string} $(grep speed ${logfile} | tail -n 1) ${outsecs} (${percent_comp}%)"
        echo -e "\r\033[1A\033[0K:: ${padded_info} ${progress} (${percent_comp}%) ${outsecs}s"
    fi
        
    grep 'progress=end' ${logfile} > /dev/null 2>&1
    let grep_result=$?
    sleep 2
done

grep 'progress=end' ${logfile} > /dev/null 2>&1
let grep_result2=$?
# if progress=end was spotted do final update of the progress bar and data to reflect full completion
if [ "$grep_result2" -eq "0" ]; then
    echo -e "\r\033[1A\033[0K:: ${padded_info} $(full_bar_chart) (100%) ${VID_LENGTH}s"
    echo ":: Result: GOOD"
else
    echo ":: Result: FAIL"
fi

rm $logfile
exit $grep_result2

