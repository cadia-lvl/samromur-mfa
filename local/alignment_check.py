import os, json, sys
from alive_progress import alive_bar

with open(sys.argv[1]) as fichierOptions:
    options = json.load(fichierOptions)

data_folder = options['path_to_data'] + options['data_folder']
align_folder = './' + options['output_folder'] + '/out'

# Creation of an error folder if it doesn't exist yet
empty_folder = options['output_folder'] + "/" + options['empty_audio_user']
empty_file = empty_folder + ".txt"
if (options['empty_audio_user'] not in os.listdir(options['output_folder'])) :
    os.mkdir(empty_folder)

empty_audio_list = []
folder_audio_list = os.listdir(data_folder)
folder_align_list = os.listdir(align_folder)

# For every audio file of every user, if the output folder of a user is empty, we put the number of the user in a file and we copy the folder with the audio file in a new folder.
N_file = int(sys.argv[2])

with alive_bar(N_file, bar="classic2") as bar :
    for folder_user in folder_audio_list :

        if ( (folder_user != ".DS_Store") and (folder_user in folder_align_list) ) :
            audio_user_list = os.listdir(data_folder + '/' + folder_user)
            align_user_list = os.listdir(align_folder + '/' + folder_user)

            for audio_file in audio_user_list :
                audio_file_i = audio_file.split('.')

                if (audio_file_i[1] == options['audio_extension'] and (audio_file_i[0] + '.TextGrid') not in align_user_list) :
                    os.system("cp -r " + options['path_to_data'] + options['data_folder'] + folder_user + "/" + audio_file + " " + empty_folder + "/" + folder_user + "/" + audio_file)
                    empty_audio_list.append('audio_file')

                bar()

f = open(empty_file, "w")
f.write(str(empty_audio_list))
f.close()

# Printing of the percentage of empty folder
print("Portion of empty folders : " + str(len(empty_audio_list) * 100 / N_file) + " %")

# If there is no empty folders, then we delete the file and the folder created
if (len(empty_audio_list) == 0) :
    os.system("rm -r " + empty_folder)
    os.system("rm " + empty_file)
