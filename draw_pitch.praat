# DRAW SPECTROGRAM, PITCH, AND TEXTGRID TIER
# ==========================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Jan 13, 2019

# This script draws an image showing a spectrogram, pitch contour, and single textgrid tier.

# Running the script calls a UI form before running the drawPitchPic procedure.
# The UI allows the user to choose the following:
#     - image width in inches (default 6")
#     - sound and pitch object index
#     - textgrid index and tier to draw
#     - start and end time (seconds)
#     - F0 draw type (hertz or semitrones re 100 Hz)
#     - minimum and maximum F0 (in hertz or semitrones)
#
# UPDATES
# 27/06/2019 Added version control to provide warning and stop script
#            if running version of Praat earlier than 6.x.

###############
# USER INPUTS #
###############
form Draw spectrogram with single tier and pitch_object track
    comment Picture size (width)
    natural image_width 6 (=inches)
    comment Sound and pitch objects
    integer sound 2 (=object number)
    integer pitch_object 3 (=object number)
    comment Textgrid information
    integer text_grid 1 (=object number)
    integer grid_tier 2 (=tier to display)
    comment Time and F0 settings
    real start_time 0 (=all)
    real end_time 0 (=all)
    choice f0_measurement 1
        option hertz
        option semitones re 100 Hz
    real minimum_F0 75
    real maximum_F0 500
endform

# check version compatibility
version$ = praatVersion$
if left$(version$, 1) != "6"
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This script is designed to run on Praat version 6.0.40 or later.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
	exit
endif

### correct F0 and time errors
if minimum_F0 > maximum_F0
    temp = minimum_F0
    minimum_F0 = maximum_F0
    maximum_F0 = temp
endif
if start_time > end_time
    temp = start_time
    start_time = end_time
    end_time = temp
endif

#######################
# DRAW AND SAVE IMAGE #
#######################
@drawPitchPic: sound,
        ... text_grid,
        ... grid_tier,
        ... pitch_object,
        ... minimum_F0,
        ... maximum_F0,
        ... start_time,
        ... end_time,
        ... image_width,
        ... f0_measurement
fileName$ = chooseWriteFile$: "Save as PNG file", "pitch_"  + drawPitchPic.saveName$
Save as 300-dpi PNG file: fileName$

##############
# PROCEDURES #
##############
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
        Draw separately: .start_time, .end_time, .minimum_F0, .maximum_F0, "yes", "yes", "no"
    else
        Draw separately (semitones): .start_time, .end_time, .minimum_F0, .maximum_F0, "yes", "yes", "no"
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
        Text left: "yes", "Fundamental Frequency (semitones re 100 Hz)"
    endif

    # draw remaining image elements
    Draw inner box
    Select outer viewport: 0, .image_width, 0, 4
    Marks bottom every: 0.001, 200, "yes", "yes", "no"
    Marks bottom every: 0.001, 100, "no", "yes", "no"
    Text bottom: "yes", "Time (ms)"
    .title$ = selected$()
    .title$ = replace$(.title$, "Pitch ", "", 1)
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
