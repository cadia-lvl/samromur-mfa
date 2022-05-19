# Preparation for Montreal Forced Alignment with Samromur dataset
This tool is to align and segmentate a dataset of audio files to prepare it for Kaldi using Montreal Forced Alignment (MFA). 

The purpose of this tool is to automatically generate an acoustic model for the data and all the files required from audio files and the metadata. In the end, we will have a folder in the following structure.

# Table of Contents
- [Preparation for Montreal Forced Alignment with Samromur dataset](#preparation-for-montreal-forced-alignment-with-samromur-dataset)
- [Table of Contents](#table-of-contents)
- [Requirements](#requirements)
  * [Input data](#input-data)
  * [JASON file](#jason-file)
- [Run](#run)
  * [Making run](#making-run)
  * [Errors](#errors)
  * [Output](#output)
  * [Segmentation checking](#segmentation-checking)
- [License](#license)
- [Authors/Credit](#authors-credit)
- [Acknowledgements](#acknowledgements)
- [Explanation of the toolkit](#explanation-of-the-toolkit)

# Requirements
## Input data

The input is a folder with multiple speakers, for which there are one or several audio file. An audio file is made up of a sentence, spoke in Icelandic. To use this tool, the data has to be in this form :

'''
metadata.tsv
data_folder/
├── id_user_1/
│   ├── id_user_1-id_file_1.flac
│   ├── id_user_1-id_file_2.flac
│   └── id_user_1-id_file_3.flac
├── id_user_2/
│   ├── id_user_2-id_file_4.flac
│   ├── id_user_2-id_file_5.flac
│   ├── id_user_2-id_file_6.flac
│   ├── id_user_2-id_file_7.flac
│   └── id_user_2-id_file_8.flac
├── id_user_3/
│   ├── id_user_3-id_file_9.flac
│   └── id_user_3-id_file_10.flac
├── id_user_4/
│   ├── id_user_4-id_file_11.flac
│   ├── id_user_4-id_file_12.flac
│   ├── id_user_4-id_file_13.flac
│   ├── id_user_4-id_file_14.flac
│   └── id_user_4-id_file_15.flac
├── ...
'''

Another file is required to use this tool : a metadata file, containing the utterances said in the audio files. This file has to be in the shape of a table, so that python can read it as a Dataframe :

'''
    speaker_id             filename                                           sentence  ...    size user_agent status
id                                                                                      ...                          
2            1  000001-0000002.flac  Því sést hún oft á helgimyndum með augu sín á ...  ...  147918        NAN   test
3            1  000001-0000003.flac        Bettý er sjöunda bók Arnaldar Indriðasonar.  ...  140238        NAN   test
4            1  000001-0000004.flac  Afar hafa sitt eigið tungumál og sérstaka menn...  ...  147918        NAN   test
6            2  000002-0000006.flac  Fyrsta fullorðinstönnin kemur við sex ára aldu...  ...  158456        NAN   test
7            2  000002-0000007.flac      Landið var þá kallað „Sviss Mið-Austurlanda“.  ...  137976        NAN   test
'''

**IMPORTANT** : The data folder and the metadata file should be in the same folder, so that the program can read them.

## JASON file

All the information that can varies in the project are inside the info.json file :

'''jsonc
{
    "path_to_data": "path/to/data/",
    "output_folder": "output_test",
    "data_folder": "data_test",
    "empty_audio_user": "empty_data_test",
    "audio_extension": "flac",
    "lexicon_file": "lexicon.lex",
    "dictionary_file": "icelandic.dict",
    "MFA_model_name": "mfa_model",
    "metadata_file": {
        "name": "metadata.tsv",
        "columns_utt_name": "sentence_norm",
        "sep": "\t"
    }
}
'''

It is necessary to adapt the informations inside it as your case, in order for all the files to work. We will list here the elements included in the files, with a description of them.
- **path_to_data** : the path to the input data (which contain the folder of audio files _and_ the metadata file;
- **output_folder** : the name of the folder which will contain all the align and segmented files;
- **data_folder** : the name of the folder containing the audio files;
- **empty_audio_user** : the name of the folder which will eventually contain the audio files of the data that has not been segmented;
- **audio_extension** : the extension of the audio files;
- **lexicon_file** : the name of the file which will contain the lexicon of the input data;
- **dictionary_file** : name of the file which will contain the lexicon plus the phonemes of each word;
- **MFA_model_name*** : name of the model created by the MFA;
- **metadata_file** :
	- **name** : name of the metadata file;
	- **columns_utt_name** : name of the columns that contains the **normalized** utterances of each audio files;
	- **sep** : separator of the data.


# Run
## Making run

Once you installed everything, and adapted the 'info.json' to your case, you can run the toolkit ! You simply need to write the folowing command on your terminal :

'''
./run.sh
'''

## Options
### Overwrite

After running the toolkit once, it is designed to use the file created. This means, if it recognize files such as dictionary or lexicon, it won't make it again. To overwrite these files, you can add the '-o' or '--overwrite' option in the end of the command :

'''
./run.sh -o
'''

or 

'''
./run.sh --overwrite
'''

### Quiet

To display less information; you can add '-q' or '--quiet' options after "./run.sh" :

'''
./run.sh -q
'''

or 

'''
./run.sh --quiet
'''

If you want the two options in the same time, you must put 'overwrite' before 'quiet'.

## Errors handling

The toolkit contain basic errors handling. Indeed, for each steps of the program, there is a corresponding '.log' file, located in the 'log' folder. 
If an error occur during the run, the program will stop and a message will be displayed explaining where the error happened, and will ask to see the corresponding log file. 

## Output

If the toolkit run successfully, it will create the following files :
- lexicon
- dictionary
- acoustic model (.zip file)
and a folder containing the TextGrid files of each audio file.

## Segmentation checking

At the end of the process - after the model has been created and trained - a program will check if the segmentation has been a success for every speaker's audio file and will display the percentage of folders having an error.
If some folders are empty, a folder containing the speaker's audio files and a file with the id of the "missing speakers" will be created. The programm will ask the user if it should be corrected. If the user wants to correct it, then it will align the "missing data" using the model created before.

# License
See the [LICENSE](LICENSE)

# Authors/Credit
Reykjavik University

Thomas Mestrou

Main authors <thomasm@ru.is>

# Acknowledgements
This project was funded by the Language Technology Programme for Icelandic 2019-2023. The programme, which is managed and coordinated by [Almannarómur](https://almannaromur.is/), is funded by the Icelandic Ministry of Education, Science and Culture.

# Explanation of the toolkit

The toolkit is globally divided in 6 sections. Each of them has a spceific role in a specific order.

1. Preparing the folders

A condition of the Montreal Forced Alignment is, for each audio file, to have a text file having the utterance said in the corresponding audio file. Moreover, this .txt file has to be in the same place and to have the same name as the audio file. In the end, the 'data_folder' looks like this :

'''
data_folder/
├── id_user_1/
│   ├── id_user_1-id_file_1.flac
│   ├── id_user_1-id_file_1.txt
│   ├── id_user_1-id_file_2.flac
│   ├── id_user_1-id_file_2.txt
│   ├── id_user_1-id_file_3.flac
│   └── id_user_1-id_file_3.txt
├── id_user_2/
│   ├── id_user_2-id_file_4.flac
│   ├── id_user_2-id_file_4.txt
│   ├── id_user_2-id_file_5.flac
│   ├── id_user_2-id_file_5.txt
│   ├── id_user_2-id_file_6.flac
│   ├── id_user_2-id_file_6.txt
│   ├── id_user_2-id_file_7.flac
│   ├── id_user_2-id_file_7.txt
│   ├── id_user_2-id_file_8.flac
│   └── id_user_2-id_file_8.txt
├── ...
'''

2. Making the lexicon

Another file needed for the MFA is the dictionary. But before that, we need to make a lexicon with every word said in the audio files. This is the role of this section. The program will take every utterances contained in the metadata file and will output a file under this format :

'''
augu
arnaldar
afar
aldurinn
austurlanda
af
alþýðuflokks
alþýðubandalags
alheimsins
austur
afríku
algengt
að
aðrar
adolf
alls
allar
alspeglun
...
'''

3. Making the lexicon

The lexicon is a dictionary, with the phoneme traduction of each word. To do this, we use a g2p (grapheme-to-phoneme) converter, with a pre-trained model : 'ipd_clean_slt2018.mdl'. The result of it is the following :

'''
augu    œyː ɣ ʏ
arnaldar    a r t n a l t a r
afar    aː v a r
aldurinn    a l t ʏ r ɪ n
austurlanda œy s t ʏ r l a n t a
af  aː v
alþýðuflokks    a l θ i ð ʏ f l ɔ h k s
alþýðubandalags a l θ i ð ʏ p a n t a l a x s
alheimsins  aː l h ei m s ɪ n s
austur  œy s t ʏ r
afríku  aː f r i k ʏ
algengt a l c ei ŋ̊ t
að  aː ð
aðrar   a ð r a r
adolf   aː t ɔ l v
alls    a l s
allar   a t l a r
alspeglun   a l s p ei k l ʏ n
...
'''

4. Validating the data

Before creating and training the acoustic model, we need to make sure all the data is ready for it. We then use the 'validate' command from mfa module to do it

5. Creating and Training the acoustic model

Here we are ! Once every step we saw before has been done, we can finally create and train the acoustic model. This will create a '.zip' file, containing the model and a folder containing the segmentation of every audio file. This folder will be in ythe same shape as the input data folder :

output_folder/
├── id_user_1/
│   ├── id_user_1-id_file_1.TextGrid
│   ├── id_user_1-id_file_2.TextGrid
│   └── id_user_1-id_file_3.TextGrid
├── id_user_2/
│   ├── id_user_2-id_file_4.TextGrid
│   ├── id_user_2-id_file_5.TextGrid
│   ├── id_user_2-id_file_6.TextGrid
│   ├── id_user_2-id_file_7.TextGrid
│   └── id_user_2-id_file_8.TextGrid
├── id_user_3/
│   ├── id_user_3-id_file_9.TextGrid
│   └── id_user_3-id_file_10.TextGrid
├── id_user_4/
│   ├── id_user_4-id_file_11.TextGrid
│   ├── id_user_4-id_file_12.TextGrid
│   ├── id_user_4-id_file_13.TextGrid
│   ├── id_user_4-id_file_14.TextGrid
│   └── id_user_4-id_file_15.TextGrid
├── ...
'''

6. Segmentation checking 

See the [Segmentation checking section](##segmentation-checking)



