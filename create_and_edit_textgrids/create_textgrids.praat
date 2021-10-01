# AUTOMATIC TEXTGRID CREATION
# ===========================
# One of a set of scripts to help automate some of my PhD research.
# Written for Praat 6.0.36
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and Speech Laboratory, Trinity College Dublin
# October 26, 2017
#
# This script generates textgrids intended for prosodic analysis.

# This version is intended to create textgrids for manual annotation of the
# following tiers:
#    a. Core interval tier
#    b. Comments tier (interval)


#####################
### UI Input form ###
#####################
form Automatic Generation of textgrids for sound files in a folder
    sentence directory
    comment
    word core_interval_tier_name syllable
    word comments_tier_name comments
endform
if core_interval_tier_name$ = ""
    core_interval_tier_name$ = "syllable"
endif
if comments_tier_name$ = ""
    comments_tier_name$ = "comments"
endif

tiers$ = core_interval_tier_name$ + " " + comments_tier_name$

### stop script if directory contains no .wav files
list_temp = Create Strings as file list: "fileList", directory$ + "/*.wav"
dir_okay = Get number of strings
selectObject: list_temp
Remove
if dir_okay = 0
    exitScript: "DIRECTORY CONTAINS NO .WAV FILES." + newline$
endif

### SET UP DIRECTORY AND OUTPUT FOLDER
output_dir$ = "output"
backup_dir$ = "backup"
reportName$ = "textgrid_creation_report_"
    ... + right$(replace$(replace$(date$()," ","", 0),":","",0),15)
    ... + " .txt"
reportPath$ = directory$ + "/" + output_dir$
backupPath$ = directory$ + "/" + backup_dir$
createDirectory: reportPath$
createDirectory: backupPath$
reportPath$ = reportPath$ + "/"
backupPath$ = backupPath$ + "/"
reportFilePath$ = reportPath$ + reportName$

### start report
text$ = "=================================="
writeInfoLine: text$
writeFileLine: reportFilePath$, text$
text$ = "Automatic TextGrid Creation Script"
text$ = text$ + newline$ + date$ ( ) + newline$
@reportUpdate: reportFilePath$, text$

if directory$ = ""
   text$ = "Target files and script in same directory." + newline$
   @reportUpdate: reportFilePath$, text$
else
   if right$(directory$, 1) <> "/"
       directory$ = directory$ + "/"
   endif
   @ChopLines: directory$, 50, "Directory: """, """"
   text$ = newText$
   @reportUpdate: reportFilePath$, text$
endif

### get list of .wav and .TextGrid files in target directory
sound_list_temp = Create Strings as file list: "sounds",  directory$ + "*.wav"
#sound_list_temp = selected ()
Replace all: ".wav", "", 0, "literals"
Rename: "sounds"
sound_list = selected ()
numberOfSounds = Get number of strings
selectObject: sound_list_temp
Remove
textgrid_file_list = Create Strings as file list: "textgrids", directory$ + "*.textgrid"
textgrid_list_temp1 = selected ()
Replace all: ".TextGrid", "", 0, "literals"
textgrid_list_temp2 = selected ()
Rename: "textgrids"
To WordList
textgrid_list = selected ()
selectObject: textgrid_list_temp1
plusObject: textgrid_list_temp2
Remove

### cycle through all sound files, back up existing textgrids and create new ones
for curr_sound to numberOfSounds
    selectObject: sound_list
    soundName$ = Get string: curr_sound
    text$ =  newline$ + ">> " + soundName$ + ".wav"
    @reportUpdate: reportFilePath$, text$

    # open current sound file
    selectObject: textgrid_list
    textgridExists = Has word: soundName$

    # back up existing textgrid files
    if textgridExists
        text$ = "   - A textgrid already exists for this sound file." + newline$
        text$ = text$ + "     The original textgrid will be saved in the back up folder."
        @reportUpdate: reportFilePath$, text$
        gridName$  = directory$ +  soundName$ + ".TextGrid"
        Read from file: gridName$
        Save as text file: backupPath$ + soundName$ + ".TextGrid"
        Remove
    endif
    Read from file: directory$ + soundName$ + ".wav"
    soundobject = selected()
    To TextGrid: tiers$, ""
    textgrid = selected()
    Save as text file: directory$ + soundName$ + ".TextGrid"
    text$ = "   - Empty textgrid generated and saved."
    @reportUpdate: reportFilePath$, text$

    # remove current sound and textgrid objects
    plusObject: soundobject
    Remove
endfor

# remove remaining objects
selectObject: sound_list
plusObject: textgrid_list
Remove

text$ = newline$ + "Automatic TextGrid Creation complete"
@reportUpdate: reportFilePath$, text$
text$ = "===================================="
@reportUpdate: reportFilePath$, text$

##################
### procedures ###
##################
###report update
procedure reportUpdate: .reportFile$, .lineText$
    appendInfoLine: .lineText$
    appendFileLine: .reportFile$, .lineText$
endproc

###create text for directory info
procedure ChopLines: .originalText$, .lineLength, .newText$, .endtext$
    .spaces$ = ""
    for .i to length(.newText$)
        .spaces$ = .spaces$ + " "
    endfor
    .dir_len = length(.originalText$)
    .full_chunks = floor(.dir_len/.lineLength)
    .remainder = .dir_len - .full_chunks * .lineLength
    for .i to .full_chunks
        .newText$ = .newText$ + mid$(.originalText$, 1 + .lineLength * (.i - 1), .lineLength)
                ... + newline$ + .spaces$
    endfor
    .newText$ = .newText$ + right$(.originalText$, .remainder) + .endtext$
    newText$ = .newText$
endproc