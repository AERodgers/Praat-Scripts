# SCRIPT FOR EXTRACTING DURATIONAL AND MEAN FORMANT VALUES
# ========================================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# May 30, 2019

# This script reads all textgrid/sound file pairs in a specified folder and generates
# a tab-separated file for vowels (and consonants). Currently it tabulates F1-F4 and
# durations for vowels but only durational data for consonants.
#
# A. Preparing textgrids
# ======================
# In order for this script to work:
#     1. Textgrids and sounds files must have matching names
#        (e.g. "example.TextGrid" and "example.wav")
#     2. There must be the following tiers in the textgrid:
#            a. repetition tier (interval tier identifying repetition number)
#            b. orthographic tier (interval tier identifying target  word or phrase)
#            c. formant tier (point tier identifying point of stability for vowel formants)
#            d. vowel tier (interval tier showing onset and offset of each vowel)
#            e. consonant tier (with text identifying each consonant)
#               If you are analysing vowels only, this tier is not necessary.
#     3. Tier names must be consistent for every textgrid in the folder being analysed

# B. Error Handling
# =================
# 1. The script will not process files under the following conditions:
#       a. There is no sound file matching the textgrid
#       b. The text grid does not contain all four tiers
# 2. The script does not mind if:
#       a. The directory address ends in "/" "\" or nothing
#       b. The sound file type is indicated with an initial "." or not
# 3. Other errors may be caused by annotation errors.

# C. Running the Script
# =====================
# The input form on the script requires the following information:
#     1. directory: the directory path containing the files
#     2. default sound file type: set to .wav by default
#     3. what to analyse: choose if you want to analyse vowels only or vowels and
#        consonants. If you choose vowels only, a consonant tier is not necessary.
#     3. Tier names: the names of tiers that are needed to run the script
#     4. maximum formant frequency in Hz:
#            - Set to 5000 Hz for a male voice and 5500 Hz for a female voice

# D. Output
# =========
# The script will save tab-separated table files in the  directory for each file analysed:
#     1. [fileName]_vowel.Table
#     2. [fileName]_consonant.Table (if option "analyse vowels and consonants" has been chosen)
# The table will have an entry for each segmental analysed, and will include the following
# information based on the original annotation:
#     1. The file name
#     2. The repetition
#     3. The lexical item / orthography
#     4. The vowel transcription
#     5. Frequency and standard deviation (in Hz) of F1-F4
#  The tables can be opened in any programme which can read tab-separated files.

# E. How it works
#    ============
#    1. The script finds all sound file and textgrid pairings in the specified directory, and
#       analyses only those which have the textgrid data.
#    1. The script identifies regions for formant analysis using the vowel, formant, and
#       consonant tiers.
#    2. Duration is calculated simply be subracting the time of the end point from that of the
#       starting point (in ms) marked in the vowel or consonant tiers.
#    3. The script uses the formant tier to identify time points for formant measurements.
#       It uses the built-in "To Formant (burg)" function to extract formant data from each
#       sound file. It uses the following parameters:
#            - Time step (s):           0.0 (=auto)
#            - Max. number of formants: 5
#            - Maximum formant (Hz):    [user-defined from script form]
#            - Window length (s):       0.025
#            - Pre-emphasis from (Hz):  50

# F. Caveats and comments
# =======================
# 1. Praat automatic formant estimation is not fool-proof. It is wise to use common sense when
#    assessing the output (e.g. an F1 of 90 Hz is in all likelihood not correct, and thus all the
#    formant values will be wrong for this item).
# 2. It might be very wise to visually confirm formant results on the spectrogram.
# 3. This script was written specifically to meet some of the research needs of M.Phil students
#    studying Linguistics and Speech and Language processing in Trinity College Dublin.
#    Therefore, it might not be useful everyone.
# 4. There may be other errors. Please make sure you are happy with the results this script provides.
# 5. Please get in touch if you have any suggestions. (I am aware of a certain amount of redundancy
#    in the vowel and consonant procedures. I will make this more efficient at a later date.)