import pandas as pd
from alive_progress import alive_bar
import sys, json

# Import all the informations of the names of the files from the 'info.json' file
with open(sys.argv[1]) as fichierOptions:
    options = json.load(fichierOptions)

# Retrieval of the infos of all the individuals, which is put in argument.
df_meta = pd.read_csv(options['path_to_data'] + options['metadata_file']['name'], options['metadata_file']['sep'], index_col=0, low_memory=False)
# f2 = open('df_head.txt', "w")
# f2.write(df_meta.head())
# f2.close
print(df_meta.head())

# Creating a dictionnary which will contain a list of all the words beginning by the letter in index.
word_dict = {"a" : [],"á" : [],"b" : [], "c" : [],"d" : [],"ð" : [],"e" : [],"é" : [],"f" : [],"g" : [],"h" : [],"i" : [],"í" : [],"j" : [],"k" : [],"l" : [],"m" : [],"n" : [],"o" : [],"ó" : [],"p" : [], "q" : [],"r" : [],"s" : [],"t" : [],"u" : [],"ú" : [],"v" : [], "w" : [],"x" : [],"y" : [],"ý" : [], "z" : [],"þ" : [],"æ" : [],"ö" : []}

# Transforming the utterances in the dataframe in a list of utterances 
sent_list = df_meta[options['metadata_file']['columns_utt_name']].to_list()

with alive_bar(bar='blocks') as bar :
    # For every sentences :
    for i in sent_list :
        # Transform the sentence (which is a string variable) in a list of words
        i = i.split()

        # For every word :
        for j in i :
            # If the word isn't already in the dictionnary, then we put the word in the list corresponding of the first letter of this word
            if j not in word_dict[j[0]] :
                word_dict[j[0]].append(j)
                bar()

# Creating a file that will contain all the words
f = open(options['lexicon_file'], "w")

# Inserting every word in the file
for i in word_dict :
    for j in word_dict[i] :
        f.write(j + "\n")

# Close the file
f.close()   