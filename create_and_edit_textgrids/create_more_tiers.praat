# AUTOMATIC TEXTGRID GENERATION USING SYLLABLE TIER
# =================================================
# One of a set of scripts to help automate some of my PhD research.
# Written for Praat 6.0.36
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and Speech Laboratory, Trinity College Dublin
# October 28, 2017
#
# This script reads all .TextGrid files with a pre-existing annotated SYLLABLE tier
# in a specified directory and creates additional textgrid tiers for prosodic analysis.
#
#    - It is designed for sound files containing a single intonational phrase.
#    - It assumes the analysis will be carried out using the AM approach.
#    - If a textgrid with the same name already exists, a copy will be saved in the backup
#      directory and then overwritten.
#    - A report is saved to the "output" folder.

### SYLLABLE TIER ANNOTATION INSTRUCTIONS
###    1. You can use the "create_textgrids.praat" script to generate syllable and comments tiers.
###    2. Annotate the syllable tier in the original textgrids using the following conventions:
###         A. use "-" at start AND end of syllable if there is no word boundary
###            between the current and previous / following syllable
###         B. use ALL CAPS in stressed syllables
###         C. do not use capital "I" as a pronoun if the pronous is not stressed (the some goes for
###            all cases where a single letter capital could be interpreted as a stressed syllable).
###    3. Save the .TextGrid in the same folder with the same name as the corresponding .wav file
###
### UI FORM
###    1. directory - folder containing the original textgrids
###    2. syllable tier name must match name in the original textgrids
###    3. leave rhythmic, phono, and vowel tiers blank of you do not want these tiers
###    4. ortho, syllable, and comments tiers will be generated even if left blank, and will use
###       the default names.
###
### OUPUT TIERS
###    1. ORTHOGRAPHIC tier (interval)
###          - Shows orthography and can be used to identify word boundaries
###    3. RHYTHMIC tier (point)
###          - uses "%" to show boundaries and "<" & ">" to idenfity stressed syllables
###          - boundary tones should be marked manually in this tier later
###    4. PHONOLOGICAL tier (interval)
###          - will be blank, with intervals marked on stressed syllables
###          - used later to manually annotate the phonological patterns (e.g. L*H)
###    4. PHONETIC tier (point)
###          - will contain blank points in the centre of the stressed syllables
###          - allows user to mark IViE style phonetic/target tier information
###    6. VOWEL tier (interval)
###          - I use this to mark vowel onsets and offsets
###    7. COMMENTS tier (interval)
###          - If the comments tier already exists, it will not be overwritten

#####################
### UI Input form ###
#####################
form Automatic Generation of textgrids from syllable tier only
    comment TARGET DIRECTORY CONTAINING .TextGrid files
    sentence directory ..\2 Field Recordings\M4\sentence_modes
    comment ANNOTATION TIER NAMES
    word ortho ortho
    word syllable syllable
    word rhythmic rhythmic
    word phono phono
    word phonetic phonetic
    word vowel vowel
    word comments comments
endform

###stop script if directory contains no .wav files
list_temp = Create Strings as file list: "fileList", directory$ + "/*.wav"
dir_okay = Get number of strings
selectObject: list_temp
Remove
if dir_okay = 0
    exitScript: "DIRECTORY CONTAINS NO .WAV FILES." + newline$
endif

##########################
### PROCESS FORM INPUT ###
##########################
### SET UP DIRECTORY AND OUTPUT FOLDER
output_dir$ = "output"
backup_dir$ = "backup"
reportName$ = "textgrids_from_syllable_report_"
    ... + right$(replace$(replace$(date$()," ","", 0),":","",0),15)
    ... + " .txt"
reportPath$ = directory$ + "/" + output_dir$
backupPath$ = directory$ + "/" + backup_dir$

createDirectory: reportPath$
createDirectory: backupPath$
reportPath$ = reportPath$ + "/"
backupPath$ = backupPath$ + "/"
reportFilePath$ = reportPath$ + reportName$

### preferred order of tiers
ortho = 1
syllable = 2
rhythmic = 3
phono = 4
phonetic = 5
vowel = 6
comments = 7

### start report
text$ = "========================================================"
writeInfoLine: text$
writeFileLine: reportFilePath$, text$
text$ = "AUTOMATIC GENERATION OF TEXTGRID TIER FROM SYLLABLE TIER"
text$ = text$ + newline$ + date$ ( ) + newline$
@reportUpdate: reportFilePath$, text$

### fix directory name
if directory$ = ""
    text$ = "Target files and  script in same directory." + newline$
    @reportUpdate: reportFilePath$, text$
elsif right$(directory$, 1) <> "/"
        directory$ = directory$ + "/"
endif
    @ChopLines: directory$, 50, "Directory: """, """"
    text$ = newText$
    @reportUpdate: reportFilePath$, text$

### fix ortho, comment, and syllable tier names if blank
if ortho$ = ""
    ortho$ = "ortho"
    text$ = "Orthographic tier name set to ""ortho"" as default."
    @reportUpdate: reportFilePath$, text$
endif
if syllable$ = ""
    syllable$ = "syllable"
    text$ = "Syllable tier name set to ""syllable"" as default."
    @reportUpdate: reportFilePath$, text$
endif
if comments$ = ""
    comments$ = "comments"
    text$ = "Comments tier name set to ""comments"" as default."
    @reportUpdate: reportFilePath$, text$
endif

text$ = newline$ + "Original TextGrids saved in ""backup"" directory."
@reportUpdate: reportFilePath$, text$

###################################################
### Process .TextGrid files in target directory ###
###################################################
textgrid_file_list = Create Strings as file list: "textgrids", directory$ + "*.TextGrid"
numberOfGrids = Get number of strings
textgrid_list = selected ()
for currGrid to numberOfGrids
    selectObject: textgrid_list
    gridName$ = Get string: currGrid
    text$ = newline$ + "-> " + gridName$
    @reportUpdate: reportFilePath$, text$

    # open current textgrid and back up
    gridPath$  = directory$ +  gridName$
    Read from file: gridPath$
    Save as text file: backupPath$ + gridName$
    curTextGrid = selected()

    # find tier number of syllable tier if it exists
    numTiers = Get number of tiers
    currComments = 0
    currSyllable = 2

    # remove all non-comment and non-syllable tiers
    numTiersCur = numTiers
    for i to numTiers
        currTier = numTiers - i + 1
        currTier$ = Get tier name: currTier
        if currTier$ <> syllable$ and currTier$ <> comments$ and numTiersCur > 1
            Remove tier: currTier
            numTiersCur -= 1
        endif
    endfor

    # recheck for syllable and comment tiers
    numTiers = Get number of tiers
    for i to numTiers
        currTier = numTiers - i + 1
        currTier$ = Get tier name: currTier
        if currTier$ = syllable$
            syllTierError = 0
            currSyllable = currTier
            selectObject: curTextGrid
            # check syll tier has minimum number of acceptable intervals
            enoughSylls = Count intervals where: currTier, "is not equal to", ""
            if enoughSylls = 0
                syllTierError = 1
            endif
       elsif currTier$ = comments$
            currComments = currTier
       endif
    endfor

    # createBlankTiers
    if syllTierError = 0
        Duplicate tier: currSyllable, ortho, ortho$
        Insert point tier: rhythmic, rhythmic$
        Insert interval tier: phono, phono$
        Insert point tier: phonetic, phonetic$
        Insert interval tier: vowel, vowel$
        if currComments = 0
            Insert interval tier: comments, comments$
        endif
        noInts = Get number of intervals: syllable
        text$ = "   Detailed textgrid being generated and saved."
        @reportUpdate: reportFilePath$, text$
        @createOrthoTier: curTextGrid
        @createRhythmPhonTiers
        selectObject: curTextGrid

        #Remove unwanted tiers
        if vowel$ = ""
            Remove tier: vowel
        endif
        if phono$ = ""
            Remove tier: phono
        endif
        if rhythmic$ = ""
            Remove tier: rhythmic
        endif
        if phonetic$ = ""
            Remove tier: phonetic
        endif
        Save as text file: gridPath$
    else
        text$ = "   No valid syllable tier for this textgrid." + newline$
          ... + "   It will be ignored."
        @reportUpdate: reportFilePath$, text$
    endif
    selectObject: curTextGrid
    Remove
endfor

text$ = newline$ + "PROCESS COMPLETE"
  ... + newline$ + "================"
@reportUpdate: reportFilePath$, text$

selectObject: textgrid_list
Remove

##################
### procedures ###
##################

procedure createOrthoTier curTextGrid
    # duplicates rhythm tier and runs through tier intervals from right to left
    # and deletes intervals which are not word boundaries
    selectObject: curTextGrid
    for i to noInts - 1
        curIntLabel$ = Get label of interval: ortho, noInts - i
        nextIntLabel$ = Get label of interval: ortho, noInts -i+1
        curEnd$ = right$(curIntLabel$,1)
        nextStart$ = left$ (nextIntLabel$)
        if curEnd$ = "-" or nextStart$ = "-"
            Remove right boundary: ortho, noInts - i
        endif
    endfor
    Replace interval text: ortho, 0, 0, "-", "", "Literals"
    Replace interval text: ortho, 0, 0, "(", "", "Literals"
    Replace interval text: ortho, 0, 0, ")", "", "Literals"
endproc

procedure createRhythmPhonTiers
    selectObject: curTextGrid
    oldTimeRight = 999999
    firstText = 0
    isInit = 0
    isFin = 0
    punctuation$ = " _\/!?,.'-[]()#"
    points = 1
    rhythmText$[points] = ""
    rhythmTime[points] = 0

    for i to noInts - 1
        isInit = 0
        isEnd = 0
        timeLeft = Get start time of interval: syllable, i
        timeRight = Get end time of interval: syllable, i
        curIntLabel$ = Get label of interval: syllable, i
        curHasNoText = curIntLabel$ = ""
        nextIntLabel$ = Get label of interval: syllable, i+1
        nextHasNoText = nextIntLabel$ = ""

        #identify if current interval is phrase start or end
        if curHasNoText = 1 and firstText = 0
            firstText = 1
            isInit = 1
            points = 1
        elsif nextHasNoText = 1 and curHasNoText = 0 and firstText = 1
            isEnd = 1
        endif

        #remove punctuation from current interval
        phraseNoPunct$ = curIntLabel$
        for j to length(punctuation$)
            phraseNoPunct$ = replace$(phraseNoPunct$, mid$(punctuation$, j, 1), "", 0)
        endfor
        #get all caps version of phrase%
        compare$ = replace_regex$ (phraseNoPunct$, ".", "\u&", 0)
        isStress = compare$ = phraseNoPunct$ and compare$<>""

        #create text for rhythmic tier and identify time points
        if isInit = 1
            rhythmText$[points] = "%"
            rhythmTime[points] = timeRight
            oldTimeRight = timeRight
            points = points + 1
        endif

        if isStress = 1
            if timeLeft = oldTimeRight
                points = points - 1
                rhythmText$[points] = rhythmText$[points] + "<"
            else
                rhythmText$[points] = "<"
            endif
            rhythmTime[points] = timeLeft
            rhythmText$[points+1] = ">"
            rhythmTime[points+1] = timeRight
            oldTimeRight = timeRight
            points = points + 2
			# add blank point in phonetic tier
			rhythmPoint = (timeRight + timeLeft) / 2
			Insert point: phonetic, rhythmPoint, ""
        endif

        if isEnd = 1
            if isStress = 1
               points = points - 1
               rhythmText$[points] = rhythmText$[points] + "%"
            else
               rhythmText$[points] = "%"
            endif
            rhythmTime[points] = timeRight
        endif
    endfor

    #insert rhythmic and phono tier points and intervals
    for i to points
        Insert point: rhythmic, rhythmTime[i], rhythmText$[i]
        if index(rhythmText$[i], "<") > 0 or index(rhythmText$[i], ">") > 0
            Insert boundary: phono, rhythmTime[i]
        endif
    endfor
endproc

### add to InfoLine and Report ###
procedure reportUpdate: .reportFile$, .lineText$
    appendInfoLine: .lineText$
    appendFileLine: .reportFile$, .lineText$
endproc

### create text for directory info
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
