#!/bin/bash

# Colors for text
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
NC='\033[0m'              # No Color

# Getting the informations contained in info.json
path_to_data="$(grep -o '"path_to_data": "[^"]*' info.json | grep -o '[^"]*$')"
output="$(grep -o '"output_folder": "[^"]*' info.json | grep -o '[^"]*$')""/"
model_path=$PWD"/""$output"$model_file

dict_file="$(grep -o '"dictionary_file": "[^"]*' info.json | grep -o '[^"]*$')"
lex_file="$(grep -o '"lexicon_file": "[^"]*' info.json | grep -o '[^"]*$')"
model_file="$(grep -o '"MFA_model_name": "[^"]*' info.json | grep -o '[^"]*$')"
data_folder="$(grep -o '"data_folder": "[^"]*' info.json | grep -o '[^"]*$')"

log="$output""log"

# If a out folder doesn't exist, it creates one. It will contain every files the 
if [ ! -d "$output" ] 
then
    mkdir $output
fi

# If a log folder doesn't exist, it creates one. This folder will contain the log files that may be created in the different steps
if [ ! -d "$output""log" ] 
then
    mkdir $output'log'
fi

# Initialize the options "overwrite", "quiet" and "model"
ov=false
qu=false
mo=false

while [ ! -z "$1" ]
do
    case $1 in
        -o|--overwrite)
            ov=true
            ;;
        -q|--quiet)
            qu=true
            ;;
        -m|--model)
            mo=true
            shift
            if [ -f "$1" ]
            then
                model_path=$1
            else 
                printf "${Red}FAILURE${NC} : The model path has not been initialized.\n"
                exit 1
            fi
            ;;
    esac
shift
done

echo '========== Preparing folders =========='
# We call the folder_prep.py program, using the informations in the info.json file and putting the errors messages in prep.log file located in log folder.
python3 folder_prep.py info.json 2> "$log"/prep.log

# If an arror occured in the preparation of folder, it show a message and stop the program.
if [ "${?}" -eq 1 ] 
then
    # In the end of every log file, we put the date and time of the last modification.
    echo "Last modification : ""$(date)" >> "$log"/prep.log
    printf "${Red}FAILURE${NC} : Something went wrong. See the log/prep.log file for more information.\n "
    exit 1
else
    printf "${Green}SUCCESS${NC} : Preparation of folder.\n "
fi



echo '========== Making lexicon ==========' 

# If the user doesn't want to overwrite on existing file and if there is an existing file, it displays a message and go to the next step. 
if [ $ov == false ] && [ -f "$output""$lex_file" ]
then

    printf "${Yellow}NOTHING DONE${NC} : %s already existing.\n " "$lex_file"
else

    python3 make_lexicon.py info.json 2> "$log"/lex.log

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> "$log"/lex.log
        printf "${Red}FAILURE${NC} : Something went wrong. See the log/lex.log file for more information. \n "
        exit 2

    else
        printf "${Green}SUCCESS${NC} : Lexicon made. \n"
    fi
fi




echo '========== Making dictionnary =========='

if [ $ov == false ] && [ -f "$output""$dict_file" ]
then
    printf "${Yellow}NOTHING DONE${NC} : %s already existing.\n " "$output""$dict_file"
else
    # We create a dictionary of phoneme  using the lexicon, the model 'ipd_clean_slt2018.mdl'.
python3 -m g2p --model ipd_clean_slt2018.mdl --apply "$output""$lex_file" --encoding='utf-8' 1> "$output""$dict_file" 2> "$log"/dict.log

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> "$log"/dict.log
        printf "${Red}FAILURE${NC} : Something went wrong. See the log/dict.log file for more information.\n "
        exit 3
    else
        printf "${Green}SUCCESS${NC} : Dictionnary made. \n"
    fi
fi



echo '========== Validating the data =========='

if $qu
then
    mfa validate --quiet "$path_to_data""$data_folder" "$output""$dict_file" 2> "$log"/val.log
else
    mfa validate "$path_to_data""$data_folder" "$output""$dict_file" 2> "$log"/val.log
fi

if [ "${?}" -eq 1 ] 
then
    echo "Last modification : ""$(date)" >> "$log"/val.log
    printf "${Red}FAILURE${NC} : Something went wrong. See the log/val.log file for more information.\n "
    exit 4
else
    printf "${Green}SUCCESS${NC} : Data validated. \n"
fi    


echo '========== Creating and Training the MFA model or align the file=========='

# If a out folder doesn't exist, it creates one. It will contain every files the 
if [ ! -d "$output""out" ] 
then
    mkdir $output'out'
fi

if [ $ov == false ] && [ -f "$output""$model_file"".zip" ]
then
    printf "${Yellow}NOTHING DONE${NC} : %s already created.\n " "$output""$model_file"

else
    if $qu
    then
        mfa train --output_model_path "$model_path" --quiet --clean --overwrite "$path_to_data""$data_folder" "$output""$dict_file" "$output""out" 2> "$log"/train.log
    else
        mfa train --output_model_path "$model_path" --clean --overwrite "$path_to_data""$data_folder" "$output""$dict_file" "$output""out" 2> "$log"/train.log
    fi

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> "$log"/train.log
        printf "${Red}FAILURE${NC} : Something went wrong. See the log/train.log file for more information.\n "
        exit 5
    else
        printf "${Green}SUCCESS${NC} : Training finished. \n"
    fi        
fi



echo '========== Checking =========='   
python3 segmentation_check.py info.json 2> "$log"/check.log

if [ "${?}" -eq 1 ] 
then
    echo "Last modification : ""$(date)" >> "$log"/check.log
    printf "${Red}FAILURE${NC} : Something went wrong. See the log/check.log file for more information.\n "
    exit 6
else
    printf "${Green}SUCCESS${NC} : Checking finished. \n"
fi    

printf "${Green}==================== Program finished without errors ====================${NC}\n "