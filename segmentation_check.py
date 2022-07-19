import os, json, sys

with open(sys.argv[1]) as fichierOptions:
    options = json.load(fichierOptions)

data_folder = options['path_to_data'] + options['data_folder']

# Creation of an error folder if it doesn't exist yet
empty_folder = options['output_folder'] + "/" + options['empty_audio_user']
empty_file = empty_folder + ".txt"
if (options['empty_audio_user'] not in os.listdir(options['output_folder'])) :
    os.mkdir(empty_folder)

empty_audio_list = []
folder_list = os.listdir(data_folder)

# For every audio file of every user, if the output folder of a user is empty, we put the number of the user in a file and we copy the folder with the audio file in a new folder.
for folder_user in folder_list :
    if (folder_user != ".DS_Store") :
        audio_user_list = os.listdir(data_folder + '/' + folder_user)
        for audio_file in audio_user_list :
            audio_file_i = audio_file.split('.')
            if (audio_file_i[1] == options['audio_extension'] and (audio_file[0] + options['text_extension']) in audio_user_list) :
                os.system("cp -r " + options['path_to_data'] + options['data_folder'] + "/" + folder_user + " " + error_folder + "/" + folder_user)
                empty_audio_list.append('audio_file')

f = open(empty_file, "w")
f.write(str(empty_audio_list))
f.close()

# Printing of the percentage of empty folder
print("Portion of empty folders : " + str(len(empty_audio_list) * 100 / len(folder_list)) + " %")

# If there is no empty folders, then we delete the file and the folder created
if (len(empty_audio_list) == 0) :
    os.system("rm -r " + empty_folder)
    os.system("rm " + empty_file)
