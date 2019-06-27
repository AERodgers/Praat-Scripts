# FIX PITCH v 2.0.1
# =================
# Written for Praat 6.0.31

# Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 21 2018

# This script designed to help with the semi-automatic correction of errors and
# removal of unwanted segmental effects in the pitch contour.
# !!!! USE WITH CAUTION !!!!!

# A. THE BASICS
#    - Reads wave and textgrid files with at least one pre-annotated reference tier.
#    - Prompts the user to:
#          1. mark intervals which should be removed from the pitch contour
#             (e.g. errors and segmental effects)
#          2. to manually remove or correct anomolies the pitch contour (uses the manipulation object)
#    - Smooths (and interpolates) the F0 contour based on user input.
#    - Saves original and corrected versions of the pitch ojbect.
#    - Saves a resynthesised waveform for each sound.
#    - Saves an image showing original and modified pitch trace on spectrogram with reference tier,
#    - Saves a report on files edited
#
# C. RUNNING THE SCRIPT: USER INPUT FORM
#      1. DIRECTORY: This is the path directory for the sound and textgrid file. Leave blank is
#         script is in same folder as files.
#      2. DRAW LEGEND: choose whether to draw a legend for each output image
#      2. REFERENCE: name of the REFERENCE tier that the script will search for:
#           - must match the original textgrid names consistently.
#           - used as reference points for the user and for graphical output.
#      3. INTERPOLATE PITCH: choose whether or not to interpolate the edited pitch trace
#      3. USE SMOOTHING: Choose the kind of smoothing you with to use
#                * none        = no smoothing
#                * praat_BW_10 = praat smooth, bandwith = 10
#                * praat_BW_19 = praat smooth, bandwith = 19
#                * Xu_Smooth   = use smoothing algorithm from Prosody Pro (see note below)
#      5. TIME STEP: The size of the time steps for fo analysis
#      6. MIN F0 and MAX FO: These set the boundaries for fundamental frequency analysis
#             - NB this is used as a baseline - the script will find the best range across all
#               files in the directory or use previously found values.
#             - To force the script to use the range specified, uncheck the box beneath.
#
# D. RUNNING THE SCRIPT: EDITING F0 CONTOURS
#   The user will be prompted twice to intervene at two points for each sound:
#      1. to create and mark intervals in a "Segmental Effects" tier.
#         This highlights portions of the F0 trace to be removed / ignored in the F0 confour.
#      2. to make any manual corrections to manipulation object
#         This allows the user to correct or remove spurious values or micro-prosodic effects which
#         will not be accounted for by smoothing (e.g. pitch halving or pitch doubling).
#
# F. OUTPUT
#      1. OUPUT folder: report for the processed batch (also appears in Info window)
#      2. RESYNTH folder: resynthesised wav files with the corrected F0.
#      3. IMAGE folder: image showing original & corrected F0 with original spectrogram and textgrid,
#      4. PITCH folder: pitch object for each utterance. (PO = original, PF = corrected)
#
# G. UPDATES
#      2.0.1 Added version control to provide warning and stop script if running earlier version 
#            of Praat (i.e. before 6.x.)

#NB: TO USE "Xu_Smooth" you must:
# 1. download "Prosody Pro" from http://www.homepages.ucl.ac.uk/~uclyyix/ProsodyPro/
# 2. place it in the same directory as this script
# 3. delete the "#" symbol in lines 100 and 679
#
# See: Xu, Y. (1999) 'Effects of tone and focus on the formation and alignment of f 0 contours',
#          Journal of Phonetics, 5, pp. 55–105.

### pitch track settings: Not included in UI form in order to prevent clutter
candidates = 15
s_threshold = 0.03
v_threshold = 0.45
oct_cost = 0.01
oct_j_cost = 0.35
vuv_cost = 0.14

### default directory and file codes
output_dir$ = "output"
image_dir$ = "image"
resynth_dir$ = "resynth"
segmentalFx_dir$ = "segmentalFx"
pitch_dir$ = "pitch"
reportName$ = "Pitch_Correction_report_"
    ... + right$(replace$(replace$(date$()," ","", 0),":","",0),15)
    ... + " .txt"

##########################
#### input procedures ####
##########################
form Automatic Annotation Script for fo tracking in Praat
    comment TARGET DIRECTORY AND TIER NAMES
    sentence directory test folder
    word reference_tier syllable
    boolean drawLegend 0
    optionmenu interpolate_pitch: 2
           option No
           option Yes
    optionmenu use_smoothing: 3
           option None
           option Praat (bandwidth 10)
           option Praat (bandwidth 19)
#           option Xu smooth
    positive time_step 0.01 (= fo analysis time step in secs)
    natural min_fo 75
    natural max_fo 500
    boolean search_directory_for_best_F0_range 1
endform
adjust_fo_range = search_directory_for_best_F0_range

# check version compatibility
version$ = praatVersion$
if left$(version$, 1) != "6"
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This script is designed to run on Praat version 6.0.31 or later.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
	exit
endif

### create directory path names
outputPath$ = directory$ + "/" + output_dir$
imagePath$ = directory$ + "/" + image_dir$
resynthPath$ =  directory$ + "/" + resynth_dir$
segmentalFxPath$ =  directory$ + "/" +  segmentalFx_dir$
pitchPath$ = directory$ + "/" + pitch_dir$
createDirectory: outputPath$
createDirectory: imagePath$
createDirectory: resynthPath$
createDirectory: segmentalFxPath$
createDirectory: pitchPath$
outputPath$ = outputPath$ + "/"
imagePath$ = imagePath$ + "/"
resynthPath$ = resynthPath$ + "/"
segmentalFxPath$ = segmentalFxPath$ + "/"
pitchPath$ = pitchPath$ + "/"
reportFilePath$ = outputPath$ + reportName$
genF0FilePath$ = outputPath$ + "generalF0_data.Table"

text$ = "==================================================="
writeInfoLine: text$
writeFileLine: reportFilePath$, text$
text$ = "AUTOMATIC/INTERACTIVE F0 TRACKING ANNOTATION SCRIPT"
  ... + newline$ + text$ + newline$ + date$ ( ) + newline$
@reportUpdate: reportFilePath$, text$

# correct invalid input
### output errors related to user input on form
if min_fo > max_fo
    temp_fo = min_fo
    min_fo = max_fo
    max_fo = temp_fo
    text$ = "ERROR: min_fo was greater than max_fo. The values have been reversed."
    @reportUpdate: reportFilePath$, text$
elsif min_fo = max_fo
    max_fo = max_fo * 1.5
    min_fo = min_fo / 1.5
    text$ = "ERROR: max fo was equal to min fo. The value of max fo has been "
        ... + newline$ + "       increased by 50% and min fo decreased by a third"
    @reportUpdate: reportFilePath$, text$
endif

#########################################################
### get list of .wav and .TextGrid files in directory ###
#########################################################
if directory$ = ""
    text$ = "Target files and  script in same directory." + newline$
    @reportUpdate: reportFilePath$, text$
else
    if right$(directory$, 1) <> "/"
        directory$ = directory$ + "/"
    endif
    text$ = "Directory: " + directory$
    @reportUpdate: reportFilePath$, text$
endif
sound_file_list = Create Strings as file list: "sounds",  directory$ + "*.wav"
sound_list_temp = selected ()
Replace all: ".wav", "", 0, "literals"
Rename: "sounds"
sound_list = selected ()
numberOfSounds = Get number of strings
### stop script if there are no sounds
if numberOfSounds = 0
    text$ = "ERROR: There are no sound files in the target directory." + newline$
    @reportUpdate: reportFilePath$, text$
    exit
endif
selectObject: sound_list_temp
Remove
textgrid_file_list = Create Strings as file list: "textgrids", directory$
    ... + "*.textgrid"
textgrid_list_temp1 = selected ()
Replace all: ".TextGrid", "", 0, "literals"
textgrid_list_temp2 = selected ()
Rename: "textgrids"
textgrid_list = To WordList
selectObject: textgrid_list_temp1
plusObject: textgrid_list_temp2
Remove
### update report

text$ = "PROCESSING SOUND AND TEXTGRID FILES" + newline$
  ... + "-----------------------------------"
@reportUpdate: reportFilePath$, text$

# Get general F0 (median,  mean, max and min) for all wave files in folder
#Use genF0 stats table if it exists, otherwise get the stats and create the table.
if fileReadable(genF0FilePath$)
    text$ = "RETRIEVING general F0 stats Table for all utterances in directory."
    @reportUpdate: reportFilePath$, text$
    Read from file: (genF0FilePath$)
    maxF0dir = Get value: 1, "maxF0"
    minF0dir = Get value: 1, "minF0"
    medianF0dir = Get value: 1, "medianF0"
    meanF0dir = Get value: 1, "meanF0"
    text$ = "General F0 data already in "
    Remove
else
    text$ = "CALCULATING general F0 stats from all utterances in directory."
    @reportUpdate: reportFilePath$, text$
    @getF0statsAll
    gentext$ = "meanF0"  + tab$
     ... + "medianF0" + tab$
     ... + "maxF0" + tab$
     ... + "minF0" + newline$
     ... + string$(meanF0dir)  + tab$
     ... + string$(medianF0dir) + tab$
     ... + string$(maxF0dir) + tab$
     ... + string$(minF0dir)
    writeFileLine: genF0FilePath$, gentext$
endif
if adjust_fo_range
    max_fo = maxF0dir + 15
    min_fo = minF0dir - 5
endif

text$ = tab$ + "Mean F0: " + string$(meanF0dir) + newline$
    ... + tab$ + "Median F0: " + string$(medianF0dir) + newline$
    ... + tab$ + "Maximum F0: " + string$(maxF0dir) + newline$
    ... + tab$ + "Minimun F0: " + string$(minF0dir) + newline$
    ...  + "min F0 and max F0 for analysis changed to: " + newline$
    ... + tab$ + "min fo = " + string$ (min_fo) + newline$
    ... + tab$ + "max fo = " + string$ (max_fo) + newline$
@reportUpdate: reportFilePath$, text$

text$ = "RUNNING PROCESS FOR EACH SOUND/TEXTGRID" + newline$
  ... + "---------------------------------------"
@reportUpdate: reportFilePath$, text$

###Run main analysis routine for sound-textgrid pairs
for cur_sound to numberOfSounds
    selectObject: sound_list
    soundName$ = Get string: cur_sound
    text$ = "current sound (" + string$(cur_sound) +
        ... "/" + string$(numberOfSounds) +
        ... "): " + soundName$
    @reportUpdate: reportFilePath$, text$
    selectObject: textgrid_list
    textgridExists = Has word: soundName$
    if textgridExists
        soundobject = Read from file: directory$ + soundName$ + ".wav"
        gridName$  = directory$ +  soundName$ + ".TextGrid"
        textgrid = Read from file: gridName$
        @check_grid: textgrid, reference_tier$
        reference_tier = check_grid.num
        ### call main analysis routine
        if check_grid.num
            @main_routine
        else
            text$ = "   - There is no reference tier associated with this filename."
            @reportUpdate: reportFilePath$, text$
            text$ =  "   - It is being ignored."
            @reportUpdate: reportFilePath$, text$
            selectObject: soundobject
            plusObject: textgrid
            Remove
        endif
    else
        text$ = "   - There is no textgrid associated with this filename."
        @reportUpdate: reportFilePath$, text$
        text$ =  "   - It is being ignored."
        @reportUpdate: reportFilePath$, text$
    endif
    text$ = ""
    @reportUpdate: reportFilePath$, text$
endfor

##########################################
### Remove remaining surplus artifacts ###
##########################################
selectObject: textgrid_list
plusObject: sound_list
Remove
text$ = newline$ + "Automatic Annotations Script complete."  + newline$
             ... + "======================================"
@reportUpdate: reportFilePath$, text$

#####################
#### MAIN ROUTINE ###
#####################
procedure main_routine
    selectObject: textgrid
    # get zoom values for viewing waveform based on reference tier
    selectObject: textgrid
    is_int_tier = Is interval tier: reference_tier
    if is_int_tier
        ref_ints = Get number of intervals: reference_tier
        zoom_start = Get end time of interval:  reference_tier, 1
        zoom_end = Get end time of interval:  reference_tier, ref_ints - 1
    else
        ref_pts = Get number of points: reference_tier
        zoom_start = Get time of point:  reference_tier, 1
        zoom_end = Get time of point:  reference_tier, ref_pts
    endif

    ##########################
    ### create pitch objects #
    ##########################
    selectObject: soundobject
    pitchTrackOrig = To Pitch (ac): 0.75/min_fo, min_fo, candidates, "no",
        ... s_threshold, v_threshold, oct_cost, oct_j_cost, vuv_cost, max_fo
    selectObject: soundobject
    temp_manip = To Manipulation: time_step, min_fo, max_fo

    ###########################
    # get temp reference tier #
    selectObject: textgrid
    segmentalFx = Extract one tier: reference_tier
    Insert interval tier: 2, "segmentalFx"
    Rename: soundName$ + "_segmentalFX"
    plusObject: soundobject
    Edit
    editor: segmentalFx
    Zoom: zoom_start, zoom_end
    endeditor
    pause_text$ = "Remove segmental effects"
    beginPause: pause_text$
        comment: "Mark the sections you want remove for segmental effects in tier two."
    edit_choice = endPause: "Skip", "Fix", 2

    if edit_choice = 2
        #remove points highlighted in segmental effects tier
        selectObject: segmentalFx
        segmentalFxOnly = Extract one tier: 2
        segmentalFxTable = Down to Table: "no", 3, "no", "no"
        numRows = Get number of rows
        for i to numRows
            fxStart[i] = Get value: i, "tmin"
            fxEnd[i] = Get value: i, "tmax"
        endfor

        #Edit pitch tier using Manipulate sound
        selectObject: temp_manip
        Edit
        editor: temp_manip
            Zoom: zoom_start, zoom_end
            #Remove segmental effects
            for i to numRows
                failSafe = (fxStart[i] + fxEnd[i])/2
                Add pitch point at: failSafe, 100
                Move cursor to: fxStart[i]
                Move end of selection by: fxEnd[i] - fxStart[i]
                Remove pitch point(s)
            endfor
        endeditor
        pause_text$ = "Checking the pitch tracking."
        beginPause: pause_text$
            comment: "Showing the pitch track for your current sound."
            comment: "Remove or stylise the pitch tracker to remove errors."
            comment: ""
        endPause: "Continue", 1

        #Create and interpolate edited pitch object
        selectObject: temp_manip
        tempPitchTier = Extract pitch tier
        plusObject: pitchTrackOrig
        pitchTrackTemp = To Pitch
        selectObject: tempPitchTier
        Remove

        if interpolate_pitch = 2
            selectObject: pitchTrackTemp
            pitchTrackInterpolated = Interpolate
            selectObject: pitchTrackTemp
            Remove
            selectObject: pitchTrackInterpolated
            pitchTrackTemp = selected ()
        endif
        ### smooth
        if use_smoothing = 4
            ## Xu Smoothing
            selectObject: pitchTrackTemp
            pitchTierSmooth = Down to PitchTier
            npulses = 3
            capture_consonant_perturbation = 0
            @Trimf0
            plusObject: pitchTrackTemp
            pitchSmooth = To Pitch
            ### remove old pitchtrack and replace it
            selectObject: pitchTrackTemp
            plusObject: pitchTierSmooth
            Remove
            pitchTrackTemp = selectObject: pitchSmooth
        elsif use_smoothing
            bw = use_smoothing * 9 - 8
            selectObject: pitchTrackTemp
            pitchSmooth = Smooth: bw
            ### remove old pitchtrack and replace it
            selectObject: pitchTrackTemp
            Remove
            selectObject: pitchSmooth
            pitchTrackTemp = selected ()
        endif

        # SAVE OBJECTS AND SOUNDS
        #  create and save Resynthesized sound file
        selectObject: pitchTrackTemp
        pitchTierSmooth = Down to PitchTier
        plusObject: temp_manip
        Replace pitch tier
        selectObject: temp_manip
        rs_sound = Get resynthesis (overlap-add)
        ### Save resynthesised file
        Save as WAV file: resynthPath$ + "RS_" + soundName$ + ".wav"
        selectObject: pitchTrackTemp
        Save as text file: pitchPath$ + "PF_" + soundName$ + ".Pitch"
        selectObject: pitchTrackOrig
        Save as text file: pitchPath$ + "PO_" + soundName$ + ".Pitch"
        #Save segmentalFx grid
        selectObject: segmentalFx
        Save as text file: segmentalFxPath$ + "FX_" + soundName$ + ".TextGrid"
        Remove tier: 2

        # fix start and end times for image
        zoom_start -= 0.01
        zoom_end += 0.01
        selectObject: soundobject
        abs_start = Get start time
        abs_end = Get end time
        if zoom_start < abs_start
            zoom_start = abs_start
        endif
        if zoom_end > abs_end
            zoom_end = abs_end
        endif

        # draw image
        @drawPitchPic: soundobject,
        ... segmentalFx,
        ... 1,
        ... pitchTrackTemp,
        ... min_fo,
        ... max_fo,
        ... zoom_start,
        ... zoom_end,
        ... 6,
        ... 1,
        ... pitchTrackOrig
        if drawLegend = 1
            @draw_legend
        endif
        full_image_path$ = imagePath$ + "ACT_" + soundName$ + ".png"
        Save as 600-dpi PNG file: full_image_path$
        ########################################
        ### Remove current surplus artifacts ###
        ########################################
        selectObject: segmentalFx
        plusObject: temp_manip
        plusObject: pitchTrackOrig
        plusObject: pitchTrackTemp
        plusObject: pitchTierSmooth
        plusObject: soundobject
        plusObject: rs_sound
        plusObject: textgrid
        plusObject: segmentalFx
        plusObject: segmentalFxTable
        plusObject: segmentalFxOnly
    else
        selectObject: soundobject
        plusObject: segmentalFx
        plusObject: textgrid
        plusObject: pitchTrackOrig
        plusObject: temp_manip
    endif
    Remove
endproc

#########################
###  Other Procedures ###
#########################

procedure hz2ST: .hz_act, .hz_ref
    #hertz to semitones re ref hz
    .st = 12*log2(.hz_act/.hz_ref)
endproc

procedure getF0statsAll
    #load all sounds in the current folder
    for cur_sound to numberOfSounds
        selectObject: sound_list
        soundName$ = Get string: cur_sound
        soundobject = Read from file: directory$ + soundName$ + ".wav"
    endfor

    #select all sounds
    lastSound = selected()
    firstSound = lastSound - numberOfSounds + 1
    for i from firstSound to lastSound - 1
    plusObject: i
    endfor

    #concatenate sounds, extract pitch track, and get median F0
    soundChain = Concatenate
    pitchChain = To Pitch (ac): 0, min_fo, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, max_fo
    medianF0dir = Get quantile: 0, 0, 0.5, "Hertz"
    medianF0dir = round(medianF0dir * 10)/10
    meanF0dir = Get mean: 0, 0, "Hertz"
    meanF0dir = round(meanF0dir * 10)/10
    minF0dir = Get minimum: 0, 0, "Hertz", "Parabolic"
    minF0dir = round(minF0dir * 10)/10
    maxF0dir = Get maximum: 0, 0, "Hertz", "Parabolic"
    maxF0dir = round(maxF0dir * 10)/10
    #select and remove all sounds
    plusObject: soundChain
    for i from firstSound to lastSound
    plusObject: i
    endfor
Remove
endproc

#######################################
### Graphical and Output Procedures ###
#######################################
procedure check_grid: .textgrid, .tier_name$
    ### Check that relevant tier exists in text grid
    selectObject: .textgrid
    .num = 0
    ### get information about existing tiers
    .num_tiers = Get number of tiers
    for .i to .num_tiers
        .tier_name$[.i] = Get tier name: .i
        if .tier_name$[.i] =  .tier_name$
           .num = .i
        endif
    endfor
endproc

procedure reportUpdate: .reportFile$, .lineText$
    appendInfoLine: .lineText$
    appendFileLine: .reportFile$, .lineText$
endproc

procedure drawPitchPic: .sound,
        ... .text_grid,
        ... .grid_tier,
        ... .pitch_object,
        ... .minimum_F0,
        ... .maximum_F0,
        ... .start_time,
        ... .end_time,
        ... .image_width,
        ... .f0_measurement
        ... .pitch_object_orig

    # set tick mark size
    .range = .maximum_F0 - .minimum_F0
    .markDistance = round(.range/10)

    # reset picture window and settings
    Erase all
    Black
    10
    Line width: 1
    Select outer viewport: 0, .image_width, 0, 3.35

    # extract and draw epectrogram
    selectObject: .sound
    .sGram = To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
    Paint: .start_time, .end_time, 0, 5000, 100, "no", 50, 6, 0, "no"
    Marks right every: 1000, 0.500, "yes", "yes", "no"
    Text right: "yes", "Spectral Frequency (kHz)"

    # extract and draw textgrid tier
    selectObject: .text_grid
    .singleTier = Extract one tier: .grid_tier
    plusObject: .pitch_object
    Select outer viewport: 0, .image_width, 0, 4
    if .f0_measurement = 1
        .markDistance = round(round(.range/10)/10)*10
        Draw separately: .start_time, .end_time, .minimum_F0, .maximum_F0, "yes", "no", "no"
    else
        Draw separately (semitones): .start_time, .end_time, .minimum_F0, .maximum_F0, "yes", "no", "no"
    endif

    # draw underlying pitch contour
   if .pitch_object_orig != 0 and .pitch_object_orig != .pitch_object

        White
        Line width: 5
        selectObject: .pitch_object_orig
        Select outer viewport: 0, .image_width, 0, 3.35
        if .f0_measurement = 1
            Draw: .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
            Black
            Line width: 3
            Dotted line
            Draw: .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        else
            Draw semitones (re 100 Hz): .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
            Black
            Line width: 3
            Dotted line
            Draw semitones (re 100 Hz): .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        endif
        Solid line
    endif

    # draw pitch contour
    White
    Line width: 5
    selectObject: .pitch_object
    Select outer viewport: 0, .image_width, 0, 3.35
    if .f0_measurement = 1
        Draw: .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        Blue
        Line width: 3
        Draw: .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        Line width: 1
        Black
        Marks left every: 1, .markDistance, "yes", "yes", "no"
        Text left: "yes", "Fundamental Frequency (Hz)"
    else
        Draw semitones (re 100 Hz): .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        Blue
        Line width: 3
        Draw semitones (re 100 Hz): .start_time, .end_time, .minimum_F0, .maximum_F0, "no"
        Line width: 1
        Black
        Marks left every: 1, .markDistance, "yes", "yes", "no"
        Text left: "yes", "Fundamental Frequency (semtines re 100 Hz)"
    endif

    # draw remaining image elements
    Draw inner box
    Select outer viewport: 0, .image_width, 0, 4
    Marks bottom every: 0.001, 200, "yes", "yes", "no"
    Marks bottom every: 0.001, 100, "no", "yes", "no"
    Text bottom: "yes", "Time (ms)"
    .title$ = selected$()
    .title$ = replace$(.title$, "Pitch ", "", 1)
    .title$ = replace$(.title$, "_stylized", "", 1)
    .saveName$ = .title$ + ".png"
    .title$ = replace$(.title$, "_", "\_ ", 0)
    12
    Text top: "yes", "##%f_0 contour for " + .title$
    10

    # remove objects
    selectObject: .sGram
    plusObject: .singleTier
    Remove
endproc

procedure draw_legend
    ### Draw Legend
    text_width = Text width (world coordinates): "corrected f_o"
    x_gap = Horizontal mm to world coordinates: 4
    y_gap  = Vertical mm to world coordinates: 4
    x_end = zoom_start + 4.5 * x_gap + text_width
    Paint rectangle: "white", zoom_start + x_gap, x_end,
                 ... max_fo - y_gap,  max_fo - y_gap * 4
    Draw rectangle: zoom_start + x_gap, x_end,
                 ... max_fo - y_gap,  max_fo - y_gap * 4
    Text: zoom_start + 3.5 * x_gap, "Left", max_fo - y_gap * 2, "Half", "original f_o"
    Text: zoom_start + 3.5 * x_gap, "Left", max_fo - y_gap * 3, "Half", "corrected f_o"
    #original fo trace
    Line width: 3
    Dotted line
    Colour: "Black"
    Draw line: zoom_start + x_gap * 2, max_fo - y_gap * 2, zoom_start + x_gap * 3, max_fo - y_gap * 2
    # corrected fo trace
    Line width: 3
    Solid line
    Colour: "blue"
    Draw line: zoom_start + x_gap * 2, max_fo - y_gap * 3, zoom_start + x_gap * 3, max_fo - y_gap * 3
    # stylized intonation contour
endproc

#####################################
### PROCEDURES FROM OTHER SOURCES ###
#####################################
# include _ProsodyPro.praat