# Generate batch of textgrids
# =========================
# Written for Praat 6.0.31

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# August 25, 2020

# This script reduces some of the donkey work involved in preparing speech
# data for analysis and processing:
# It does the following:
#     1. Cleans up the recording by remove low-freqency noise.
#     2. Automatically chunks the recording into separate phrases / repetitions
#        based on regions of silence (using "To Textgrid ( silences)" function).
#     3. Displays the automatic textgrid annotation to allow for manual
#        correction of errors.
#     4. Automatically labels each area of non-silence with a prefix +
#        number(e.g. YNQ_1, BEAG_1)
#     5. Prompts the user to correct any errors
#     6. Backs up previous version of files.
#     7. Saves Chopped up large sounds into "SmallFiles" directory.

# check version compatibility
version$ = praatVersion$
if left$(version$, 1) != "6"
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This script is designed to run on Praat version 6.0.31 or later.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
	exit
endif

# UI INPUT
beginPause: "Generate batch of textrids and sound files"
    comment: "SOUND FILES"
    sentence: "Directory", "enter directory here"
    word: "Sound file suffix", ".wav"
    comment: ""

    comment: "SILENCES DETECTION"
    comment: "Parameters for the intensity analysis"
    natural: "Minimum pitch (Hz)", 100
    real: "Time step (s)", "0.0 (= auto)"
    comment: "Silent intervals detection"
    real: "Silence threshold (dB)", -25.0
    positive: "Minimum silent interval duration (s)", 0.2
    positive: "Minimum sounding interval duration",  0.2
    real: "sounding edge buffer (s)", "0.075"
    sentence: "Sounding interval label or prefix", "sound"
    optionMenu: "Annotate sound intervals by", 1
        option: "number (1, 2, 3, ...)"
        option: "prefix plus number (sound_1, sound_2, ...)"
    comment: ""

    comment: "EXTRA OPTIONS"
    boolean: "Automatically update annotation text", 1
    comment: ""

    boolean: "Chop large file into smaller files and save", 1
    real: "buffer size at edges",0.1
    comment: ""

    boolean: "Run high pass filter", 0
    natural: "Lowest pass frequency", 40
    natural: "Smoothing", 15
    comment: ""

    comment: "NB: Original files will be backed up to a sub-directory " +
    ... "called 'backup'."

myChoice = endPause: "Exit", "Continue", 2, 1
if myChoice = 1
    exit
endif

# create manageable variable names
soundSuffix$ = sound_file_suffix$
soundDir$ = directory$
if (right$(soundDir$, 1) != "/" or right$(soundDir$, 1) != "\") and
    ... right$(soundDir$, 1) != ""
    soundDir$ += "/"
endif
if soundDir$ = ""
    soundRoot$ = "root directory"
    else
        soundRoot$ = left$(soundDir$, length(soundDir$) - 1)
    endif
soundSuffix$ = sound_file_suffix$
if left$(soundSuffix$, 1) != "."
    soundSuffix$ = "." + soundSuffix$
endif

minF0 = minimum_pitch
tStep = time_step
maxSil_dB = silence_threshold
minSil_T = minimum_silent_interval_duration
minSound_T = minimum_sounding_interval_duration
buffer = sounding_edge_buffer

soundIntLab$ = sounding_interval_label_or_prefix$
silIntLab$ = ""
annotateBy = annotate_sound_intervals_by
if annotateBy = 2
    prefix$ = soundIntLab$ + "_"
else
    prefix$ = ""
endif

autoUpdate = automatically_update_annotation_text
chopUpSound = chop_large_file_into_smaller_files_and_save
saveBuffer = buffer_size_at_edges
saveDir$ = soundDir$ + "SmallFiles"

runFilter = run_high_pass_filter
lowestPassHz = lowest_pass_frequency


# get list of wave files
soundList = Create Strings as file list: "fileList", soundDir$
   ... + "*'soundSuffix$'"
Rename: "soundList"
soundList = selected ()
numberOfFiles = Get number of strings
if numberOfFiles = 0
    appendInfoLine: "No ""'soundSuffix$'"" files found."
    appendInfoLine: "Exiting script."
    exit
endif

#create directories
backup$ = soundDir$ + "backup"
createDirectory: backup$
backup$ += "/"
if chopUpSound
    createDirectory: saveDir$
    saveDir$ += "/"
endif

if runFilter
    @filterSound: soundDir$, lowestPassHz, smoothing, soundList, backup$
endif

@createSoundTier: soundDir$, soundSuffix$, soundList,
              ... minF0, tStep,
              ... maxSil_dB, minSil_T, minSound_T, buffer,
              ... soundIntLab$, silIntLab$,
              ... prefix$, backup$


@checkManually: soundDir$, soundSuffix$, autoUpdate, soundList, prefix$,
... chopUpSound, saveBuffer, saveDir$



procedure filterSound: .soundDir$, .lowestPassHz, .smoothing,
                   ... .soundList, .backup$
    selectObject: .soundList
    .numberOfFiles = Get number of strings
    for .curFile to .numberOfFiles
        selectObject: .soundList
        .fileName$ = Get string: .curFile
        .unFiltered = Read from file: .soundDir$ + .fileName$

        Save as WAV file: .backup$ + .fileName$
        .filtered = Filter (stop Hann band): 0, .lowestPassHz, .smoothing

        Save as WAV file: .soundDir$ + .fileName$
        plusObject: .unFiltered
        Remove
    endfor

endproc

procedure createSoundTier: .soundDir$, .soundSuffix$, .soundList,
              ... .minF0, .tStep,
              ... .maxSil_dB, .minSil_T, .minSound_T, .buffer,
              ... .soundIntLab$, .silIntLab$,
              ... .prefix$, .backup$

    # adjust time step for "auto"
    if .tStep = 0
        .tStep = 0.8 / .minF0
    endif

    selectObject: .soundList
    .numberOfFiles = Get number of strings

    for .curFile to .numberOfFiles
        selectObject: .soundList
        .fileName$ = Get string: .curFile
        .gridName$ = replace$(.fileName$, .soundSuffix$, ".TextGrid", 1)
        .curSound = Read from file: .soundDir$ + .fileName$

        .grid = To TextGrid (silences): .minF0, .tStep,
            ... .maxSil_dB, .minSil_T, .minSound_T,
            ... "", "x"


        @makeSoundingTextGrid:  .grid, .curSound, .buffer, .prefix$,
        ... 0, 0, ""

        # back up old grid
        if fileReadable(.soundDir$ + .gridName$)
            Read from file: .soundDir$ + .gridName$
            Save as text file: .backup$ + .gridName$
            Remove
        endif

        # save new grid
        selectObject: .grid
        Save as text file: .soundDir$ + .gridName$
        Remove
        removeObject: .curSound
    endfor
endproc

procedure checkManually: .soundDir$, .soundSuffix$, .autoUpdate, .soundList,
                    ...  .prefix$, .chopUpSound, .saveBuffer, .saveDir$
    selectObject: .soundList
    .numSounds = Get number of strings
    for .i to .numSounds
        selectObject: .soundList
        .curSound$ = Get string: .i
        .curGrid$ = replace$(.curSound$, .soundSuffix$, ".TextGrid", 1)
        .curSound = Read from file: .soundDir$ + .curSound$
        .curGrid = Read from file: .soundDir$ + .curGrid$
        .startTime = Get start time
        .endTime = Get end time

        selectObject: .curSound
        plusObject: .curGrid

        Edit
        editor: .curGrid
            Zoom: .startTime, .endTime
        endeditor

        pauseText$ = "Checking " + replace$(.curSound$, .soundSuffix$, "", 1)
        beginPause: pauseText$
        comment: "Check and correct errors in "
        ... + replace$(.curSound$, .soundSuffix$, "", 1) +  "."
        edit_choice = endPause: "Exit", "Next", 2, 1
        if edit_choice = 1
            exit
        endif

        if .autoUpdate
            @makeSoundingTextGrid:  .curGrid, .curSound, 0, .prefix$,
            ... .chopUpSound, .saveBuffer, .saveDir$
        endif

        selectObject: .curGrid
        Save as text file:  .soundDir$ + .curGrid$
        Remove
        removeObject: .curSound
    endfor
endproc


procedure makeSoundingTextGrid: .grid, .sound, .buffer, .prefix$,
                            ... .chopUpSound, .saveBuffer, .saveDir$

    selectObject: .grid
    .startTime = Get start time
    .endTime = Get end time

    .table = Down to Table: "no", 3, "no", "no"
    .numInts = Get number of rows

    # remove silences tier
    selectObject: .grid
    Insert interval tier: 2, "sounds"
    Remove tier: 1

    selectObject: .table
    # Calculate adjusted initial boundary values
    .curMin = Get value: 1, "tmin"
    .curMin -= .buffer * (.curMin >= (.startTime + .buffer))

    .curMax = Get value: 1, "tmax"
    .nextMin = Get value: 2, "tmin"
    .curMax += .buffer * (.nextMin > (.curMin + .buffer))

    Set string value: 1, "tmin", fixed$(.curMin, 3)
    Set string value: 1, "tmax", fixed$(.curMax, 3)


    # Calculate all but final adjusted boundary values
    for .i from 2 to .numInts - 1
        .prevMin = .curMin
        .prevMax = .curMax

        .curMin = .nextMin
        .curMin -= .buffer * (.curMin >= (.prevMax + .buffer))

        .curMax = Get value: .i, "tmax"
        .nextMin = Get value: .i + 1, "tmin"
        .curMax += .buffer * (.nextMin > (.curMin + .buffer))

        Set string value: .i, "tmin", fixed$(.curMin, 3)
        Set string value: .i, "tmax", fixed$(.curMax, 3)

    endfor

    # Calculate adjusted initial boundary values
    .curMin = Get value: .numInts, "tmin"
    .curMin -= .buffer * (.curMin >= (.startTime + .buffer))

    .curMax = Get value: .numInts, "tmax"
    .nextMin = .endTime
    .curMax += .buffer * (.nextMin > (.curMin + .buffer))

    Set string value: .numInts, "tmin", fixed$(.curMin, 3)
    Set string value: .numInts, "tmax", fixed$(.curMax, 3)


    for .i to .numInts
        selectObject: .table
        Set string value: .i, "text", .prefix$ + string$(.i)
        .intStart = Get value: .i, "tmin"
        .intEnd = Get value: .i, "tmax"
        selectObject: .grid
        Insert boundary: 1, .intStart
        Insert boundary: 1, .intEnd
        Set interval text: 1, .i * 2, .prefix$ + string$(.i)
    endfor

    if .chopUpSound
        @chopUpSound: .table, .grid, .sound, .saveDir$, .saveBuffer
    endif

    removeObject: .table
endproc


procedure chopUpSound: .table, .grid, .sound, .saveDir$, .saveBuffer
    selectObject: .sound
    .name$ = selected$("Sound")
    .startTime = Get start time
    .endTime = Get end time

    selectObject: .table
    .numRows = Get number of rows
    for .i to .numRows
        .tmin[.i] = Get value: .i, "tmin"
        .tmin[.i] -= ((.tmin[.i] - .saveBuffer) >= .startTime) * .saveBuffer
        .text$[.i] = Get value: .i, "text"
        .tmax[.i] = Get value: .i, "tmax"
        .tmax[.i] += ((.tmax[.i] + .saveBuffer) >= .endTime) * .saveBuffer
    endfor

    for .i to .numRows
        selectObject: .grid
        Insert interval tier: 2, "temp"
        Insert boundary: 2, .tmin[.i]
        Insert boundary: 2, .tmax[.i]
        Set interval text: 2, 2, .text$[.i]
        plusObject: .sound
        .temp = Extract non-empty intervals: 2, "no"

        Save as WAV file: .saveDir$ + .name$ + "_" +selected$("Sound") + ".wav"
        Remove
        selectObject: .grid
        Remove tier: 2
    endfor
endproc
