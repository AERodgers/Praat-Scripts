# SCRIPT FOR EXTRACTING DURATIONAL AND MEAN FORMANT VALUES V1.01
# ==============================================================
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
# 4. The script will provide a warning and exit if version earlier than Praat 6.x is used.

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

# UPDATES
# V1.01: added version control to warn if incompatible version of Praat (pre v.6.x) is being used.
##USER INPUT
form Segmental analysis script: formants and durations
    sentence directory
    word default_Sound_File .wav
    comment What to analyse
    choice analyse 1
        button vowels only
        button vowels and consonants
    comment Tier Names
    word repetition_tier_name rep
    word orthography_tier_name ortho
    word formant_tier formant
    word vowel_tier_name vowel
    word consonant_tier_name consonant
    comment Maximum formant frequency to extract five formants
    positive maximum_formant_Frequency_in_Hz 5000
endform

# check version compatibility
if number(left$(praatVersion$, 1)) < 6
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This version of Praat is out of date.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
	exit
endif

## process input variables
if right$(directory$, 1) <> "/" or right$(directory$, 1) <> "\"
    directory$ = directory$ + "/"
endif
soundType$ = default_Sound_File$
repG$ = repetition_tier_name$
orthoG$ = orthography_tier_name$
formantG$ = formant_tier$
vowelG$ = vowel_tier_name$
consG$ = consonant_tier_name$
maxFormantG = round(maximum_formant_Frequency_in_Hz)

# Get list of text grids in directory
textgridList = Create Strings as file list: "textgrids", directory$ + "*.TextGrid"
numberOfGrids = Get number of strings

#MAIN ROUTINE
writeInfoLine: "Running script to extract segmental data from files in directory:"
appendInfoLine: directory$, newline$
for currGrid to numberOfGrids
    # Get current textgrid and file info
    selectObject: textgridList
    gridName$ = Get string: currGrid
    gridPathG$ = directory$ +  gridName$
    soundPath$ = replace$(gridPathG$, ".TextGrid", soundType$, 1)

    # check soundfile exists for textgrid
    soundExists = fileReadable (soundPath$)
    if soundExists
        curTextGrid = Read from file: gridPathG$
        curSound = Read from file: soundPath$

        # check textgrid contains necessary tiers
        selectObject: curTextGrid
        numTiers = Get number of tiers
        tierExists# = zero#(5)
        for curTier to numTiers
            curTierName$ = Get tier name: curTier
            if curTierName$ = repG$
                tierExists#[1] = 1
            elsif curTierName$ = orthoG$
                tierExists#[2] = 1
            elsif curTierName$ = vowelG$
                tierExists#[3] = 1
            elsif curTierName$ = consG$
                tierExists#[4] = 1
            elsif curTierName$ = formantG$
                tierExists#[5] = 1
            endif
        endfor
        parityCheck = sum(tierExists#)
        parityCheckVOnly = parityCheck - tierExists#[4]
        if (parityCheck = 5 and analyse = 2) or
                ... (parityCheckVOnly = 4 and analyse = 1)
            # Run analysis procedures if all okay
            appendInfoLine: "Extracting data from ",
                ... replace$(gridName$, ".TextGrid", "", 1)
            @getAllData: curTextGrid, curSound,
                ... replace$(gridName$, ".TextGrid", "", 1)
        else
            # Provide error output if tiers are missing
            appendInfoLine: "Cannot find the following tier(s) in ",
                ... replace$(gridName$, ".TextGrid", "", 1), ":"
            if not tierExists#[1]
                appendInfoLine: "   - Repetition tier"
            endif
            if not tierExists#[2]
                appendInfoLine: "   - Orthographic tier"
            endif
            if not tierExists#[3]
                appendInfoLine: "   - Vowel tier"
            endif
            if not tierExists#[4] and analyse = 2
                appendInfoLine: "   - Consonant tier"
            endif
            if not tierExists#[5]
                appendInfoLine: "   - Formant tier"
            endif
        endif
    selectObject: curTextGrid
    plusObject: curSound
    Remove
    else
        # Provide error output if sound file is missing
        appendInfoLine: "Sound file could not be found for ", gridName$
    endif
    # find tier number of syllable tier if it exists
endfor

selectObject: textgridList
Remove

###PROCEDURES

procedure getAllData: .textGrid, .soundObj, .file$
    ### Convert textgrid and sound file to analysable objects
    selectObject: .soundObj
    .formantObj = To Formant (burg): 0, 5, maxFormantG, 0.025, 50
    selectObject: .textGrid
    .gridTable =Down to Table: "no", 3, "yes", "no"

    ### Run procedure to populate databases
    @getVowelData: .formantObj, .gridTable, .file$
    if analyse = 2
        @getConsonantData: .gridTable, .file$
    endif
    ### remove temporary objects
    plusObject: .formantObj
    plusObject: .gridTable
    Remove
endproc

procedure getVowelData: .formantObj, .gridTable, .file$
    ## reference variables
    .formantCol$[1] = "F1(Hz)"
    .formantCol$[2] = "F2(Hz)"
    .formantCol$[3] = "F3(Hz)"
    .formantCol$[4] = "F4(Hz)"

    # get constituent tables from textgrid
    selectObject: .gridTable
    .repTable = Extract rows where column (text): "tier", "is equal to", repG$
    selectObject: .gridTable
    .orthoTable = Extract rows where column (text): "tier", "is equal to", orthoG$
    selectObject: .gridTable
    .formantPtsTable = Extract rows where column (text): "tier", "is equal to", formantG$
    .numFormantPts = Get number of rows
    selectObject: .gridTable
    .vowelTable = Extract rows where column (text): "tier", "is equal to", vowelG$
    .numVowels = Get number of rows

    # create vowel database table
    .vowelData = Create Table with column names: "vowelData",
        ... .numFormantPts, "file rep ortho vowel dur formantPt F1 F2 F3 F4"

    ### get formant, duration, and identification data for each segmental
    for .i to .numFormantPts
        selectObject: .formantPtsTable
        .t = Get value: .i, "tmin"
        .formantPtName$ = Get value: .i, "text"

        # Get formant values and populate table for current segmental
        for .j to 4
            selectObject: .formantObj
            .fCur = Get value at time: .j, .t, "hertz", "Linear"
            selectObject: .vowelData
            Set numeric value: .i, "F"+string$(.j), round(.fCur)
        endfor


        # get cur rep name
        selectObject: .repTable
        .tempRep = Extract rows where: "self[""tmin""]<=.t and self[""tmax""]>=.t"
        .repName$ = Get value: 1, "text"
        Remove

        # get cur ortho name
        selectObject: .orthoTable
        .tempOrtho = Extract rows where: "self[""tmin""]<=.t and self[""tmax""]>=.t"
        .orthoName$ = Get value: 1, "text"
        Remove

        # get cur vowel name and duration
        selectObject: .vowelTable
        .tempVowel = Extract rows where: "self[""tmin""]<=.t and self[""tmax""]>=.t"
        .segmentName$ = Get value: 1, "text"
        .tmin = Get value: 1, "tmin"
        .tmax = Get value: 1, "tmax"
        .dur = round((.tmax-.tmin)*1000)
        Remove

        # populate database table with identification data
        selectObject: .vowelData
        Set string value: .i, "file", .file$
        Set string value: .i, "rep", .repName$
        Set string value: .i, "ortho", .orthoName$
        Set string value: .i, "formantPt", .formantPtName$
        Set string value: .i, "vowel", .segmentName$
        # populate database table with durational data
        Set numeric value: .i, "dur", .dur
    endfor

    selectObject: .vowelData
    Save as tab-separated file: replace$(gridPathG$, ".TextGrid", "_vowel.Table", 1)
    plusObject: .repTable
    plusObject: .orthoTable
    plusObject: .formantPtsTable
    plusObject: .vowelTable
    Remove
endproc

procedure getConsonantData: .gridTable, .file$

    # get constituent tables for textgrid
    selectObject: .gridTable
    .repTable = Extract rows where column (text): "tier", "is equal to", repG$
    selectObject: .gridTable
    .orthoTable = Extract rows where column (text): "tier", "is equal to", orthoG$
    selectObject: .gridTable
    .consTable = Extract rows where column (text): "tier", "is equal to", consG$
    .consRows = Get number of rows

    # create consonant database table
    .consData = Create Table with column names: "ConsonantData",
        ... .consRows, "file rep ortho consonant dur"

    ### get duration, and identification data for each segmental
    for .i to .consRows
        selectObject: .consTable
        .tmin = Get value: .i, "tmin"
        .tmax = Get value: .i, "tmax"
        .dur = round((.tmax-.tmin)*1000)
        .segmentName$ = Get value: .i, "text"

        # get cur rep name
        selectObject: .repTable
        .tempRep = Extract rows where: "self[""tmin""]<=.tmin and self[""tmax""]>=.tmax"
        .repName$ = Get value: 1, "text"
        Remove

        # get cur ortho name
        selectObject: .orthoTable
        .tempOrtho = Extract rows where: "self[""tmin""]<=.tmin and self[""tmax""]>=.tmax"
        .orthoName$ = Get value: 1, "text"
        Remove

        # populate database table with identification data
        selectObject: .consData
        Set string value: .i, "file", .file$
        Set string value: .i, "rep", .repName$
        Set string value: .i, "ortho", .orthoName$
        Set string value: .i, "consonant", .segmentName$
        # populate database table with durational data
        Set numeric value: .i, "dur", .dur
    endfor

    selectObject: .consData
    Save as tab-separated file: replace$(gridPathG$, ".TextGrid", "_consonant.Table", 1)
    plusObject: .repTable
    plusObject: .orthoTable
    plusObject: .consTable
    Remove

endproc
