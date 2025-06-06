#!/bin/bash
# usage example: movshrinker -t

# --------------------
# Functions
# -------------------

numbers () {
    echo ""
    echo "------------------------------------------------"
    echo "$(echo -n 'MOV: ' ; ls | grep MOV | wc -l) ----- $(echo -n 'mp4: ' ; ls | grep mp4 | wc -l)"
    echo "------------------------------------------------"
}

help () {
    cat <<EOF
:: This program will attempt to compress any .mov
   file in the current working directory.
   And delete the orignal.
   Use at own risk!
EOF
}

let response='N'
get_response () {
    # offer for user to exit before proceeding
    cat <<EOF
:: This program will attempt to compress any .mov
   file in the current working directory.
   And delete the orignal.
   Use at own risk!

   Current working directory is: ${PWD}

   Enter Y to proceed or just press ENTER to exit safely
EOF

    read user_response
    if [ ! -z "$user_response" ]; then
        let response=$user_response
    fi
}


check_before_proceeding () {
    get_response

    if [ ${#user_response} -eq 0 ]; then
        echo "You choose to exit, exiting now..."
        exit 0;
    elif [ $user_response = "Y" ]; then
        echo ""
    else
        echo "You choose to exit, exiting now..."
        exit 0;
    fi
}

# --------------------
# Main logic
# -------------------

mode="N"
limit_to_10="n"

# expects -h or -v as options in $1 or else no options

if [ -n "$1" ]; then  # i.e. an command line argument has been provided
    case "$1" in
        -h) mode="H" ;; # will just print a help string
        -t) mode="T" ;; # verbose mode
        *) echo "::Option $1 not recognised, exiting";exit 1;
    esac
fi

#echo "MODE=${mode}"

if  [ $mode = "H" ]; then # help mode
    help
    exit 0

elif [ $mode = "N" ]; then # normal (default mode) 
    :
    #echo "Normal"

elif [ $mode = "T" ]; then # verbose mode
    #echo "Verbose"
    limit_to_10="Y"
fi

check_before_proceeding

let counter=0
for FILE in *; do

    if [ $mode = "T" ]; then
        if [ $counter -gt 5 ]; then
            echo ":: completed 5 iterations, exiting as planned..."
            exit 0
        fi
    fi

    if [[ $FILE == *.MOV ]]; then
        MP4filename=$(echo ${FILE} | sed -e 's/MOV$/mp4/')
        if [ -f "${MP4filename}" ]; then
            echo ":: skipping as mp4 file of same name exists (${FILE})"
        else
            numbers
            echo ":: compressing ${FILE}..."
            let counter=counter+1

            movshrink-one ${FILE}
            
            if [ $? -eq 0 ]; then
                if [ -f "${MP4filename}" ]; then
                    echo ":: deleting original ${FILE}"
                    rm $FILE
                fi
            fi
        fi
        
    else
        echo ":: skipping non-mov file (${FILE})"
    fi
done

exit 0
