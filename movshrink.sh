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
:: This program will attempt to compress any .mov file in the current working directory.
   And delete the orignal (if -x was given as the second command line argument)
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


# Deal with first command line argument
# -------------------------------------

mode="U"
limit_to_5="n"

# expects -h, -u, -t as options in $1 or else no options

if [ -n "$1" ]; then  # i.e. an command line argument has been provided
    case "$1" in
        -h) mode="H" ;; # will just print a help string
        -t) mode="T" ;; # limit to 5 iterations
        -u) mode="U" ;; # loop through all MOV files found in CWD
        *) echo ":: Option $1 not recognised, exiting"; exit 1;
    esac
fi

if  [ $mode = "H" ]; then # help mode
    help
    exit 0

elif [ $mode = "U" ]; then # unlimited mode (default mode) 
    :

elif [ $mode = "T" ]; then # limited mode (limit to 5 iterations
    limit_to_5="Y" 
fi

# Deal with second command line argument
# --------------------------------------

# set default to not delete original unless second argument is -x

delete_original_flag_set='N'
if [ -n "$2" ]; then # i.e. a second command line argument has been provided
    case "$2" in
        -x) delete_original_flag_set="Y";;
        *) echo ":: Option $2 not recognised, existing"; exit 1;
    esac
fi



# Main Logic
# ----------

# make sure user is happy to risk proceeding
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
                    if [ $delete_original_flag_set = "Y" ]; then
                        echo ":: deleting original ${FILE}"
                        rm $FILE
                    fi
                fi
            fi
        fi
        
    else
        echo ":: skipping non-mov file (${FILE})"
    fi
done

exit 0
