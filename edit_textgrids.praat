# EDIT TEXTGRID BATCH V2.0
# ========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Jan 12, 2019

# This script opens every sound file with a matching textgid in a chosen directory for editing.
# The user can choose which tier to hide in the text grid to avoid cluttering the screen.
# 
# When the script is run, two UI forms appear:
#     1. Choose Directory form
#            - the directory with textgrid and sound files (with or without final "/" or "\")
#            - sound file suffix (with or with out ".")
#            - textgrids and sounds files (wav) must be in the same directory
#     2. Show/Hide Tiers
#            - Tick the tiers you want to display while editting
#            - It is not possible to hide all tiers

# When viewing the textgrid and sound files, the user can:
#     1. stop the script
#     2. skip back to the previous textgrid
#     3. skip to the next textgrid
#     4. save the current textgrid and move to the next one
#
# Failsafes / Error Handling
#     1. a backup directory is created which contains:
#            - a copy of each text grid which appears in the editor window (before editting)
#            - a report listing all texgrids changed
#     2. The script cannot cope with tier names beginning with a number or which contain characters
#        that break variable name conventions (with the exception of initial capitals)

###############
# USER INPUTS #
###############

### CHOOSE DIRECTORY FORM
form Text grid editor: Choose Directory
    sentence directory ..\Field Recordings\F5\sentence_modes
    word defaultSoundFile .wav
	endform
# correct form errors
if left$(defaultSoundFile$, 1) != "."
    defaultSoundFile$ = "." + defaultSoundFile$
endif
if right$(directory$, 1) != "/" or right$(directory$, 1) != "\"
    directory$ += "/"
endif

### SHOW/HIDE TIERS FORM
# Get list of all tier names in directory
@tier: directory$
tiersToShow = 0
while tiersToShow = 0
    # Show/Hide tiers UI
	beginPause: "Show/Hide Tiers"
	comment: "Check the tiers you want to view while editing"
	for i to tier.names
		curBoolean$ = replace_regex$(tier.name$[i], ".", "\L&", 1) + " tier"
		boolean: curBoolean$, 0
	endfor
	endPause: "Continue", 1
    # Check that there is at least 1 tier to show
    for i to tier.names
        curBoolean$ = replace_regex$ (tier.name$[i], ".", "\L&", 1) + "_tier"
        tiersToShow += 'curBoolean$'
    endfor
endwhile

###################
#PROCESS UI INPUT #
###################

### CREATE STRING OF TIERS TO HIDE
hide_tiers$ = ""
for i to tier.names
    curBoolean$ = replace_regex$(tier.name$[i], ".", "\L&", 1) + "_tier"
    if not 'curBoolean$'
	    hide_tiers$ += tier.name$[i] + " "
	endif
endfor
if right$(hide_tiers$, 1) = " "
    hide_tiers$ = left$(hide_tiers$, length(hide_tiers$) - 1)
endif

### GET LIST OF SOUND AND TEXT GRID FILES
# get list of wave files
sound_list_temp = Create Strings as file list: "fileList", directory$ + "*" + defaultSoundFile$

# create directories and paths
output_dir$ = "output"
outputPath$ = directory$ + output_dir$
createDirectory: outputPath$
reportName$ = "edit_textgrids_"
    ... + right$(replace$(replace$(date$()," ","", 0),":","",0),15)
    ... + " .txt"
backup_dir$ = "backup"
backupPath$ = directory$ + backup_dir$
createDirectory: backupPath$
backupPath$ = backupPath$ + "/"
reportFilePath$ = backupPath$ + reportName$
@reportInitialise: reportFilePath$, "Reading files from : " + directory$

# exit the script if directory contains no sound files
numberOfSounds = Get number of strings
if numberOfSounds = 0
    exitScript: "DIRECTORY CONTAINS NO " + defaultSoundFile$ " files." + newline$
endif

# get list of file names without suffix
Replace all: defaultSoundFile$, "", 0, "literals"
Rename: "sounds"
sound_list = selected ()
numberOfSounds = Get number of strings
selectObject: sound_list_temp
Remove

# get list of textgrids in target file
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

### get number leading zeros for output line
maxlen = length(string$(numberOfSounds))
zeros$ = "00000000"
spaces$ = "         "

#########################
# MAIN EDITTING ROUTINE #
#########################
for curr_sound to numberOfSounds
    selectObject: sound_list
    soundName$ = Get string: curr_sound

    #add info about current sound to output window
    # format pc and curr sound to have leading zeros
    curr_sound$ = string$(curr_sound)
    curr_sound$ = left$(zeros$, maxlen - length(curr_sound$)) + curr_sound$
    curr_pc = round(1000 * (curr_sound) / numberOfSounds) / 10
    curr_pc$ = string$(curr_pc)
    if curr_pc = round (curr_pc)
        curr_pc$ += ".0"
    endif
    curr_spaces$ = left$(spaces$,6 - length(curr_pc$))
    #curr_pc$ = left$(zeros$, curr_pc_zeros) + curr_pc$
    @reportUpdate: reportFilePath$, newline$ + "  >> " + curr_sound$ + "/" + string$(numberOfSounds)
            ... + curr_spaces$ + "(" +  curr_pc$ +  "%)" + " " +  soundName$

    #edit textgrid if it exists
    selectObject: textgrid_list
    textgridExists = Has word: soundName$
    if textgridExists
        # read in sound and textgrid
        Read from file: directory$ + soundName$ + defaultSoundFile$
        soundobject = selected()
        Scale intensity: 70

        Read from file: directory$ + soundName$ + ".TextGrid"
        Save as text file: backupPath$ + soundName$ + ".TextGrid"
        textgrid = selected()
        @removeDuplicateTiers: textgrid

        # remove tiers for temporary textgrid, if any have been specified
        if length(hide_tiers$) != 0
            @temp_textgrid: "textgrid", hide_tiers$
            selectObject: temp_textgrid.object
            plusObject: soundobject
        else
            selectObject: textgrid
            plusObject: soundobject
        endif
        # pause to let user edit the text gtid
        Edit

        pauseText$ = "Editting; " + replace$(soundName$, "_", " ", 0)
        beginPause: pauseText$
            comment: "Go back, skip forward without saving, or save and skip forward?"
        edit_choice = endPause: "<", ">", "Save", 3

        # save merged textgrid if any have been specified
        if length(hide_tiers$) != 0
            @merge_textgrids
        endif
        if edit_choice = 3
            selectObject: textgrid
            Save as text file: directory$ + soundName$ + ".TextGrid"
            @reportUpdate: reportFilePath$,  " saved."
        elsif edit_choice = 2
            @reportUpdate: reportFilePath$, " skipped."
        elsif edit_choice = 1 and curr_sound > 1
            curr_sound -= 2
            @reportUpdate: reportFilePath$, " jumping back."
        else
            @reportUpdate: reportFilePath$, " cannot jump back - moving forward"
        endif
        # remove current sound object and textgrid
        plusObject: soundobject
        Remove
    else
        @reportUpdate: reportFilePath$,  " does not have an associated text grid file."
    endif
endfor

# remove remaining objects
selectObject: sound_list
plusObject: textgrid_list
Remove

@reportUpdate: reportFilePath$,  newline$ + newline$ + "TextGrid Editing complete." +
... newline$ + "=========================="

##############
# Procedures #
##############

### Get all tier names in diractory
procedure tier: .directory$
.names = 0
# Get list of textgrids
.grid_list = Create Strings as file list: "fileList", .directory$ + "*.TextGrid"
.numberOfGrids =  Get number of strings
# exit if no text grids
if .numberOfGrids = 0
    exitScript: "DIRECTORY CONTAINS NO .TextGrid FILES." + newline$
endif
# Get names of all textgrid tiers in directory
for .i to .numberOfGrids
    selectObject: .grid_list
    .gridName$ = Get string: .i
    .cur_grid = Read from file: .directory$ + .gridName$
    .num_tiers = Get number of tiers
    if .names = 0
        .name$[1] = Get tier name: 1
        .names = 1
    endif
    for j to .num_tiers
        .cur_tier$ = Get tier name: j
        .nameAlreadyExists = 0
        for .k to .names
            .nameAlreadyExists += (.cur_tier$ = .name$[.k])
        endfor
        if not .nameAlreadyExists
            .names += 1
            .name$[.names] = .cur_tier$
        endif
    endfor
	Remove
endfor
selectObject: .grid_list
Remove
endproc

### Report Procedures
procedure reportInitialise: .reportFile$, .text$
	writeInfoLine: .text$
	writeFileLine: .reportFile$, .text$
endproc

procedure reportUpdate: .reportFile$, .text$
    appendInfo: .text$
    appendFile: .reportFile$, .text$
endproc

### Textgrid Management Procedures
procedure temp_textgrid: .original$, .delete_list$
    # convert  .delete_list$ to array of tiers to be deleted (.delete$[.n] with .n elements)
    .list_length = length(.delete_list$)
    .n = 1
    .prev_start = 1
    for .i to .list_length
        .char$ = mid$(.delete_list$, .i, 1)
        if .char$ = " "
            .delete$[.n] = mid$(.delete_list$, .prev_start, .i - .prev_start)
            .n += 1
            .prev_start = .i + 1
        endif

        if .n = 1
            .delete$[.n] = .delete_list$
        else
            .delete$[.n] = mid$(.delete_list$, .prev_start, .list_length - .prev_start + 1)
        endif
    endfor

    # create a copy of '.original$' and delete target tiers
    selectObject: '.original$'
    .num_tiers = Get number of tiers
    .name$ = selected$("TextGrid")
    .name$ += "_temp"
    Copy: .name$
    .object = selected ()
    for .i to .num_tiers
        .cur_tier = .num_tiers + 1 - .i
        .name_cur$ = Get tier name: .cur_tier
        for .j to .n
            if .delete$[.j] = .name_cur$
                Remove tier: .cur_tier
            endif
        endfor
    endfor
endproc

procedure merge_textgrids
    ### get number of and list of original and temporary tiers
    selectObject: temp_textgrid.object
    .temp_n_tiers = Get number of tiers
    for .i to .temp_n_tiers
        .temp_tier$[.i] = Get tier name: .i
    endfor
    selectObject: 'temp_textgrid.original$'
    .orig_n_tiers = Get number of tiers
    .name$ = selected$("TextGrid")
    for .i to .orig_n_tiers
        .orig_tier$[.i] = Get tier name: .i
    endfor

    ### create 1st tier of merged tier
    selectObject: 'temp_textgrid.original$'
    Extract one tier: 1
    .new = selected()
    if .orig_tier$[1] = .temp_tier$[1]
        selectObject: temp_textgrid.object
        Extract one tier: 1
        .temp_single_tier = selected ()
        plusObject: .new
        Merge
        .newNew =selected()
		Remove tier: 1
        selectObject: .temp_single_tier
        plusObject: .new
        Remove
        .new = .newNew
    endif

    ### merge tiers 2 to .orig_n_tiers
    for .i from 2 to .orig_n_tiers
        .useTemp = 0
        for .j to .temp_n_tiers
            if .orig_tier$[.i] =  .temp_tier$[.j]
                .useTemp = .j
            endif
        endfor
        if .useTemp
            selectObject: temp_textgrid.object
            Extract one tier: .useTemp

        else
            selectObject: 'temp_textgrid.original$'
            Extract one tier: .i
        endif
        .temp_single_tier = selected ()
        plusObject: .new
        Merge
        .newNew =selected()
        selectObject: .temp_single_tier
        plusObject: .new
        Remove
        .new = .newNew
    endfor
    selectObject: 'temp_textgrid.original$'
    plusObject: temp_textgrid.object
    Remove
    'temp_textgrid.original$' = .new
    selectObject: 'temp_textgrid.original$'
    Rename: .name$
endproc

procedure removeDuplicateTiers: .textGrid
    selectObject: .textGrid
	.name$ = selected$()
    .num_tiers = Get number of tiers
    .prev_tier$ = Get tier name: .num_tiers
    for .i from 2 to .num_tiers
        .cur_tier = .num_tiers - .i + 1
        .cur_tier$ = Get tier name: .cur_tier
        if .cur_tier$ = .prev_tier$
            appendInfo: " ", .name$, tab$, """", replace$(.cur_tier$, "TextGrid ", "", 0) , 
			    ... """ duplicate removed"
            Remove tier: .cur_tier
        endif
    .prev_tier$ = .cur_tier$ 
    endfor
endproc