import os, sys, json
import pandas as pd
from alive_progress import alive_bar

try:
    with open(sys.argv[1]) as fichierOptions:
        options = json.load(fichierOptions)
    # Import all the informations of the names of the files from the 'info.json' file
except:
    raise NameError("The .json file is missing or the name is incorrect. Try changing it in the run.sh program, line 6.")

    
try:
    df_meta = pd.read_csv(options['path_to_data'] + options['metadata_file']['name'], sep=options['metadata_file']['sep'], index_col=0, low_memory=False)
    # Retrieval of the infos of all the individuals, which is put in argument.
except:
    raise NameError("Name of the metadata file is incorrect. Try changing it in the info.json program, line 4.")

try: 
    folder_list = os.listdir(options['path_to_data'] + options['data_folder'])
    # Retrieval of the folder of all the individuals, which is put in argument.
except: 
    raise NameError("Name of the data folder is incorrect. Try changing it in the info.json program, line 2.")

with alive_bar(bar='blocks') as bar :
    for folder_i in folder_list :
        if folder_i != ".DS_Store" :
            folder_list_i = os.listdir(options['path_to_data'] + options['data_folder'] + "/" + folder_i)
            # For each individual, we get the list of audio file

            for folder_j in folder_list_i :
                filename, file_extension = os.path.splitext(folder_j)

                # Checking if the file correspond to an audio file 
                if ( (filename != ".DS_Store" ) and ( file_extension == ('.' + options["audio_extension"]) ) ) :
                    ind = int(filename[-7:])
                    # As the index of the audio file in the dataframe is the last part of the audio file name, we use that property 
                    # to get the sentence corresponding to the audio file in the dataframe :
                    sent = df_meta.loc[ind, options['metadata_file']['columns_utt_name']]

                    # We create a file for every sentence/utterance, which got the same name as the audio file, and has the .txt extension.
                    f = open(options['path_to_data'] + options['data_folder'] + "/" + folder_i + "/" + filename + ".txt", "w")
                    f.write(sent)
                    f.close() 
  
                    bar()