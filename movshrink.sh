#!/bin/bash
# usage example: movshrink -t


# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c() {
    # this is the outer trap function
    # i.e. if Ctrl-C was pressed while
    # movshrink-one was running then its trap
    # will run first, then this one...
    echo ":: exiting movshrink..."
    exit 1
}


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
:: This program will attempt to compress any .MOV
   file in the current working directory.
   And delete the original.
   Use at own risk!

:: Usage 
   'movshrink -t'    - make compressed copies of 5 MOV files
   'movshrink -t -x' - do that and DELETE the originals
   'movshrink -u'    - make compressed copies of all MOV files in CWD
   'movshrink -u -x' - do that and DELETE the originals
EOF
}

let response='N'
get_response () {
    # offer for user to exit before proceeding
    cat <<EOF
:: This program will attempt to compress any .mov file in the current working dir.
   And delete the original (if -x was given as the second command line argument)
   Use at own risk!

   Current working dir is: ${PWD}

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


# Deal with first command line arguments
# -------------------------------------

mode="unset"
limit_to_5="n"
delete_original_flag_set='N'

# https://labex.io/tutorials/shell-bash-getopt-391993
## Parse command-line options
OPTS=$(getopt -o htux -n 'movshrink' -- "$@")

if [ $? -ne 0 ]; then
  echo "Failed to parse options" >&2
  exit 1
fi

## Reset the positional parameters to the parsed options
eval set -- "$OPTS"

# Process the options
while true; do
    case "$1" in
        -h)
            mode="H"
            help
            exit 0
            shift
            ;;
        -t)
            if [ $mode = "U" ]; then
                echo ":: -t and -u options can not be used together, exiting..."
                exit 1
            fi
            mode="T"
            limit_to_5="Y"
            shift
            ;;
        -u)
            if [ $mode = "T" ]; then
                echo ":: -t and -u options can not be used together, exiting..."
                exit 1
            fi
            mode="U"
            shift
            ;;
        -x)
            delete_original_flag_set="Y"
            shift
            ;;
        --)
            shift
            break;;
        *)
            echo ":: Unrecognised arguments, exiting..."
            exit 1
            ;;
    esac
done

if [ $mode = "unset" ]; then
    mode="U"
fi


# Main Logic
# ----------

# make sure user is happy to risk proceeding
check_before_proceeding

let counter=0
for FILE in *; do

    if [ $mode = "T" ]; then
        if [ $counter -gt 4 ]; then
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
