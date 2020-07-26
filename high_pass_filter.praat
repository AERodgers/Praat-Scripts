# HIGH PASS FILTER v.1.0.1
# =========================
# Written for Praat 6.0.31

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# March 10, 2018

# This script runs a Hann stop band filter on all waveforms in a
# specified folder to remove low-frequency noise from 0 Hz to
# specfied lowest pass frequency.
# DOES NOT CREATE BACKUPS!

# UPDATES
# 1.0.01 Added version control to provide warning and stop script if running
#        earlier version of Praat (i.e. before 6.x.)


# UI INPUT
form Batch passband filter
    sentence directory test folder
    word defaultSoundFile .wav
    natural lowest_pass_frequency 40
    natural smoothing 15
    comment NB: Original sound files will be backed up to a sub-directory called 'back up'
endform
# correct form errors
if left$(defaultSoundFile$, 1) != "."
    defaultSoundFile$ = "." + defaultSoundFile$
endif
if (right$(directory$, 1) != "/" or right$(directory$, 1) != "\") and
    ... right$(directory$, 1) != ""
    directory$ += "/"
endif

# check version compatibility
version$ = praatVersion$
if left$(version$, 1) != "6"
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This script is designed to run on Praat version 6.0.31 or later.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
	exit
endif

writeInfoLine: "Filtering sound files in: """, directory$, """"
appendInfoLine: "Stop band = 0-", lowest_pass_frequency, " Hz"
appendInfoLine: "Smoothing = ", smoothing, " Hz"

#create backup directory
appendInfoLine: newline$, "Making sure back up directory exists..."
backup$ = directory$ + "backup"
createDirectory: backup$
backup$ += "/"

# get list of wave files
appendInfoLine: "Getting list of ""'defaultSoundFile$'"" files...",
    ... newline$
file_list = Create Strings as file list: "fileList", directory$
   ... + "*'defaultSoundFile$'"
Rename: "file_list"
file_list = selected ()
numberOfFiles = Get number of strings
if numberOfFiles = 0
    appendInfoLine: "No ""'defaultSoundFile$'"" files found."
	appendInfoLine: "Exiting script."
	exit
endif

info$ = ""
for curr_file to numberOfFiles
    selectObject: file_list
    fileName$ = Get string: curr_file
    info$ += "  - ""'fileName$'"" "
    unFiltered = Read from file: directory$ + fileName$
    Save as WAV file: backup$ + fileName$
    filtered = Filter (stop Hann band): 0, lowest_pass_frequency, smoothing
    Save as WAV file: directory$ + fileName$
    info$ += "filtered and saved" + newline$
    plusObject: unFiltered
    Remove
endfor
appendInfoLine: "The followng files were backuped, filtered, and saved:"
appendInfoLine: info$
selectObject: file_list
Remove
