import os, sys, json
import pandas as pd
from alive_progress import alive_bar

# As this python file will be the first one to run, we check if all the informations put in the info.json file are good

# Import all the informations of the names of the files from the 'info.json' file
try:
    with open(sys.argv[1]) as fichierOptions:
        options = json.load(fichierOptions)
except:
    raise NameError("The .json file is missing or the name is incorrect. Try changing it in the run.sh program, line 6.")

# Retrieval of the infos of all the individuals, which is put in argument.    
try:
    df_meta = pd.read_csv(filepath_or_buffer = options['path_to_data'] + options['metadata_file']['name'], sep = options['metadata_file']['sep'], index_col=0, low_memory=False)
except:
    raise NameError("Some information of the metadata file is incorrect. Try changing it in the info.json program, line 4.")

# Retrieval of the folder of all the individuals, which is put in argument.
try: 
    folder_list = os.listdir(options['path_to_data'] + options['data_folder'])
except: 
    raise NameError("Name of the data folder is incorrect. Try changing it in the info.json program, line 2.")

# If the overwrite option was added, the 'overwrite' boolean is turned to True
if ( (len(sys.argv) == 3) and (sys.argv[2] == '-o') ) :
    overwrite = True
else :
    overwrite = False


with alive_bar(bar='blocks') as bar :
    for folder_i in folder_list :
        if folder_i != ".DS_Store" :
            # For each individual, we get the list of audio file
            folder_list_i = os.listdir(options['path_to_data'] + options['data_folder'] + "/" + folder_i)

            for folder_j in folder_list_i :
                filename, file_extension = os.path.splitext(folder_j)

                # If the 'overwrite' boolean is True and 
                if not ( ( overwrite == False ) and ((filename + ".txt") in folder_list_i) ) :
                    # Checking if the file correspond to an audio file 
                    if ( (filename != ".DS_Store") and (file_extension == ('.' + options["audio_extension"])) ) :
                        ind = int(filename[(-1 * options['metadata_file']['speaker_len']):])
                        # As the index of the audio file in the dataframe is the last part of the audio file name, we use that property 
                        # to get the sentence corresponding to the audio file in the dataframe :
                        sent = df_meta.loc[ind, options['metadata_file']['columns_utt_name']]

                        # We create a file for every sentence/utterance, which got the same name as the audio file, and has the .txt extension.
                        f = open(options['path_to_data'] + options['data_folder'] + "/" + folder_i + "/" + filename + ".txt", "w")
                        f.write(sent)
                        f.close() 
    
                        bar()