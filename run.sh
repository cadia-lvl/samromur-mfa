#!/bin/bash

# Colors for text
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
NC='\033[0m'              # No Color

# Getting the informations contained in info.json
path_to_data="$(grep -o '"path_to_data": "[^"]*' info.json | grep -o '[^"]*$')"
output="$(grep -o '"output_folder": "[^"]*' info.json | grep -o '[^"]*$')""/"

dict_file="$(grep -o '"dictionary_file": "[^"]*' info.json | grep -o '[^"]*$')"
lex_file="$(grep -o '"lexicon_file": "[^"]*' info.json | grep -o '[^"]*$')"
model_file="$(grep -o '"MFA_model_name": "[^"]*' info.json | grep -o '[^"]*$')"
data_folder="$(grep -o '"data_folder": "[^"]*' info.json | grep -o '[^"]*$')"
model_path=$PWD"/""$output"$model_file
log="$output""log"

# If the output folder doesn't exist, it creates one. It will contain all the files the tool creates (lexicon, dictionary, aligned text files)
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

# We get all the options the users wrote. 
while [ ! -z "$1" ]
do
    case $1 in
        # If the user wrote '-o' or '--overwrite', the the 'ov' variable will be changed to 'true'
        # This option means the user wants to overwrite on existing files
        -o|--overwrite)
            ov=true
            ;;
        # If the user wrote '-q' or '--quiet', the the 'qu' variable will be changed to 'true'
        # This option means the user wants the tool to display the less things possible 
        -q|--quiet)
            qu=true
            ;;
        # If the user wrote '-m' or '--model', the the 'mo' variable will be changed to 'true'``
        # This option, which should be followed by the path of an acoustic model, will use the model to align files
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

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

echo '========== Preparing folders =========='
# We call the folder_prep.py program, using the informations in the info.json file and putting the errors messages in prep.log file located in log folder.
# If the user wants to overwrite on the potentially pre-existing .txt files, we add the '-o' option after the python command. It will be recognized by the folder_prep.py program.
if [ $ov == true ]
then
    python3 folder_prep.py info.json -o 2> "$log"/prep.log
else 
    python3 folder_prep.py info.json 2> "$log"/prep.log
fi

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

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

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

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

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

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

if [ $mo == false ]  
then
    echo '========== Validating the data =========='

    if $qu
    then
        mfa validate --quiet "$path_to_data""$data_folder" "$output""$dict_file" 2>&1 "$log"/val.log
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
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

# If the user want to use a pre-existing model, it will then use this model to align the files of the dataset.
if $mo
then
    echo '========== Adapting the dataset & align the files using the model =========='
    if $qu
    then
        mfa adapt --quiet --clean --overwrite "$path_to_data""$data_folder" "$output""$dict_file" "$model_path" "$output""out" 2> "$log"/align.log
    else
        mfa adapt --clean --overwrite "$path_to_data""$data_folder" "$output""$dict_file" "$model_path" "$output""out" 2> "$log"/align.log
    fi

    if [ "${?}" -eq 1 ] 
    then
        echo "Last modification : ""$(date)" >> "$log"/align.log
        printf "${Red}FAILURE${NC} : Something went wrong. See the align/train.log file for more information.\n "
        exit 5
    else
        printf "${Green}SUCCESS${NC} : Alignment finished. \n"
    fi     

# If the user wants to create a new model, it will do so and use this model to align the files of the dataset.
else 

    echo '========== Creating and Training the MFA model =========='

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
            mfa train --output_model_path "$model_path" --quiet --clean --overwrite "$path_to_data""$data_folder" "$output""$dict_file" "$output""out" 2>&1 "$log"/train.log
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
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------ #

# Ths program will check if the alignment has been done for all the files. If not, it will put all the non-aligned files in a separate folder.
# It will always display the percentage of missing folders
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