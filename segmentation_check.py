import os, json, sys

with open(sys.argv[1]) as fichierOptions:
    options = json.load(fichierOptions)

output_folder = options['output_folder']

error_folder = 'empty_data'
if (error_folder not in os.listdir()) :
    os.mkdir(error_folder)

folder_list = os.listdir(output_folder)
empty_audio_user_list = []

for folder_user in folder_list :
    if (folder_user != ".DS_Store") :
        audio_user_list = os.listdir(output_folder + '/' + folder_user)
        if (len(audio_user_list) == 0) :
            empty_audio_user_list.append(folder_user)
            if (folder_user not in os.listdir(error_folder)) :
                os.system("cp -r " + options['path_to_data'] + options['data_folder'] + "/" + folder_user + " " + error_folder + "/" + folder_user)

f = open(options['empty_audio_user_folder'] + '.txt', "w")
f.write(str(empty_audio_user_list))
f.close()

print("Portion of empty folders : " + str(len(empty_audio_user_list) * 100 / len(folder_list)) + " %")

# while (len(empty_audio_user_list) > 0) :
#     bash_command_align = "mfa align --clean " + error_folder + " " + options['dictionnary_file'] + " " + options["MFA_model_name"] + ".zip" + " output_2"
#     os.system(bash_command_align)