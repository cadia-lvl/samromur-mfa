#!/bin/bash

# Colors for text
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
NC='\033[0m'              # No Color

# Getting the informations contained in info.json
path_to_data="$(grep -o '"path_to_data": "[^"]*' info.json | grep -o '[^"]*$')"
dict_file="$(grep -o '"dictionnary_file": "[^"]*' info.json | grep -o '[^"]*$')"
lex_file="$(grep -o '"lexicon_file": "[^"]*' info.json | grep -o '[^"]*$')"
model_file="$(grep -o '"MFA_model_name": "[^"]*' info.json | grep -o '[^"]*$')"
model_path=$PWD"/"$model_file
output_folder="$(grep -o '"output_folder": "[^"]*' info.json | grep -o '[^"]*$')"
data_folder="$(grep -o '"data_folder": "[^"]*' info.json | grep -o '[^"]*$')"

# If a log folder doesn't exist, it creates one
if [ ! -d "$PWD""/log" ] 
then
    mkdir 'log'
fi

# Initialize the option "overwrite" and "display"
ov=false
if [ "$1" == "-o" ] || [ "$1" == "--overwrite" ]
then
    ov=true
fi


echo '========== Preparing folders =========='
# We call the folder_prep.py program, using the informations in the info.json file and putting the errors messages in prep.log file located in log folder.
python3 folder_prep.py info.json 2> log/prep.log

# If an arror occured in the preparation of folder, it show a message and stop the program.
if [ "${?}" -eq 1 ] 
then
    # In the end of every log file, we put the date and time of the last modification.
    echo "Last modification : ""$(date)" >> log/prep.log
    printf " ${Red}FAILURE${NC} : Something went wrong. See the log/prep.log file for more information.\n "
    exit 1
else
    printf " ${Green}SUCCESS${NC} : Preparation of folder.\n "
fi
# Creating .txt files corresponding to audio files in corresponding folders



echo '========== Making lexicon ==========' 

# If the user doesn't want to overwrite on existing file and if there is an existing file, it displays a message and go to the next step. 
if [ $ov == false ] && [ -f $lex_file ]
then
    printf " ${Yellow}NOTHING DONE${NC} : %s already created.\n " "$lex_file"
else
    # We call the make_lexicon.py program, using the informations in the info.json file and putting the errors messages in lex.log file located in log folder.
    python3 make_lexicon.py info.json 2> log/lex.log

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> log/lex.log
        printf " ${Red}FAILURE${NC} : Something went wrong. See the log/lex.log file for more information. \n "
        exit 2

    else
        printf " ${Green}SUCCESS${NC} : Lexicon made. \n"
    fi
fi
# Creating the lexicon file of the data folder


echo '========== Making dictionnary =========='

if [ $ov == false ] && [ -f $dict_file ]
then
    printf " ${Yellow}NOTHING DONE${NC} : %s already created.\n " "$dict_file"
else
    # We create a dictionary of phoneme  using the lexicon, the model 'ipd_clean_slt2018.mdl'.
    python3 -m g2p --model ipd_clean_slt2018.mdl --apply "$lex_file" --encoding='utf-8' > "$dict_file" 2> log/dict.log

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> log/dict.log
        printf " ${Red}FAILURE${NC} : Something went wrong. See the log/dict.log file for more information.\n "
        exit 3
    else
        printf " ${Green}SUCCESS${NC} : Dictionnary made. \n"
    fi
fi
# Creating the dictionnary with the pre-trained model 'ipd_clean_slt2018.mdl'



echo '========== Validating the data =========='

mfa validate "$path_to_data""$data_folder" "$dict_file" 2> log/val.log

if [ "${?}" -eq 1 ] 
then
    echo "Last modification : ""$(date)" >> log/val.log
    printf " ${Red}FAILURE${NC} : Something went wrong. See the log/val.log file for more information.\n "
    exit 4
else
    printf " ${Green}SUCCESS${NC} : Data validated. \n"
fi    



echo '========== Creating and Training the MFA model =========='

if [ $ov == false ] && [ -f $model_file".zip" ]
then
    printf " ${Yellow}NOTHING DONE${NC} : %s already created.\n " "$model_file"

else
    mfa train --output_model_path "$model_path" --clean --overwrite "$path_to_data""$data_folder" "$dict_file" "$output_folder" 2> log/train.log

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> log/train.log
        printf " ${Red}FAILURE${NC} : Something went wrong. See the log/train.log file for more information.\n "
        exit 5
    else
        printf " ${Green}SUCCESS${NC} : Training finished. \n"
        steps=$(( $steps + 1 ))
    fi        
fi
# Training the model



echo '========== Checking =========='   
python3 segmentation_check.py info.json 2> log/check.log

if [ "${?}" -eq 1 ] 
then
    echo "Last modification : ""$(date)" >> log/check.log
    printf " ${Red}FAILURE${NC} : Something went wrong. See the log/check.log file for more information.\n "
    exit 6
else
    printf " ${Green}SUCCESS${NC} : Checking finished. \n"
fi    
# Checking if the alignment has been done in all files

printf " Program finished without errors.\n "