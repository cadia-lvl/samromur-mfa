import os, json, sys

with open(sys.argv[1]) as fichierOptions:
    options = json.load(fichierOptions)

output_folder = options['output_folder'] + "/out"

# Creation of an error folder if it doesn't exist yet
error_folder = options['output_folder'] + "/" + options['empty_audio_user'] 
error_file = error_folder + ".txt"
if (error_folder not in os.listdir()) :
    os.mkdir(error_folder)

folder_list = os.listdir(output_folder)

clean=False

# While every audio file doesn't have a TextGrid file, we align these audio file with the model we created and trained in the previous commands (in run.sh file)
while (clean == False) :
    empty_audio_user_list = []

    # For every audio file of every user, if the output folder of a user is empty, we put the number of the user in a file and we copy the folder with the audio file in a new folder.
    for folder_user in folder_list :
        if (folder_user != ".DS_Store") :
            audio_user_list = os.listdir(output_folder + '/' + folder_user)
            if (len(audio_user_list) == 0) :
                empty_audio_user_list.append(folder_user)
                if (folder_user not in os.listdir(error_folder)) :
                    os.system("cp -r " + options['path_to_data'] + options['data_folder'] + "/" + folder_user + " " + error_folder + "/" + folder_user)

    f = open(error_file, "w")
    f.write(str(empty_audio_user_list))
    f.close()

    # Printing of the percentage of empty folder
    print("Portion of empty folders : " + str(len(empty_audio_user_list) * 100 / len(folder_list)) + " %")

    # If there is no empty folders, then we delete the file and the folder created
    if (len(empty_audio_user_list) == 0) :
        clean = True
        os.system("rm -r " + error_folder)
        os.system("rm " + error_file)
        break