#!/bin/bash

Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
NC='\033[0m'              # No Color

path_to_data="$(grep -o '"path_to_data": "[^"]*' info.json | grep -o '[^"]*$')"
dict_file="$(grep -o '"dictionnary_file": "[^"]*' info.json | grep -o '[^"]*$')"
lex_file="$(grep -o '"lexicon_file": "[^"]*' info.json | grep -o '[^"]*$')"
model_file="$(grep -o '"MFA_model_name": "[^"]*' info.json | grep -o '[^"]*$')"
model_path=$PWD"/"$model_file
output_folder="$(grep -o '"output_folder": "[^"]*' info.json | grep -o '[^"]*$')"


if [ ! -d "$PWD""/log" ] 
then
    mkdir 'log'
fi

ov=false
dis=false

if [ "$1" == "-o" ] || [ "$1" == "--overwrite" ]
then
    ov=true
    if [ "$2" == "-d" ] || [ "$2" == "--display" ]
    then
        dis=true
    fi
elif [ "$2" == "-d" ] || [ "$2" == "--display" ]
    then dis=true
fi

echo '========== Preparing folders =========='
python3 folder_prep.py info.json 2> log/prep.log

if [ "${?}" -eq 1 ] 
then
    echo "Last modification : ""$(date)" >> log/prep.log
    printf " ${Red}FAILURE${NC} : Something went wrong. See the log/prep.log file for more information.\n "
    exit 1
else
    printf " ${Green}SUCCESS${NC} : Preparation of folder.\n "
fi
# Creating .txt files corresponding to audio files in corresponding folders


echo '========== Making lexicon ==========' 

if [ $ov == false ] && [ -f $lex_file ]
then
    printf " ${Yellow}NOTHING DONE${NC} : %s already created.\n " "$lex_file"
else
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
data_folder="$(grep -o '"data_folder": "[^"]*' info.json | grep -o '[^"]*$')"

if $dis
then 
    mfa validate "$path_to_data""$data_folder" "$dict_file" 2> log/val.log
else 
    mfa validate "$path_to_data""$data_folder" "$dict_file" > log/val.log
fi

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
    if $dis
    then
        mfa train --output_model_path "$model_path" --clean --overwrite "$path_to_data""$data_folder" "$dict_file" "$output_folder" 2> log/train.log
    else
        mfa train --output_model_path "$model_path" --clean --overwrite "$path_to_data""$data_folder" "$dict_file" "$output_folder" > log/train.log
    fi

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
if $dis
then    
    python3 segmentation_check.py info.json 2> log/check.log
else
    python3 segmentation_check.py info.json >> log/check.log
fi

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