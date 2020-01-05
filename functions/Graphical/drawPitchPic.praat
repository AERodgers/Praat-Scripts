# DRAW SPECTROGRAM, PITCH, AND TEXTGRID TIER
# ==========================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Jan 13, 2019

# Draws an image showing a spectrogram, pitch contour, and single textgrid tier.
#
# The script takes the following arguments:
    # .sound
    # .text_grid
    # .grid_tier
    # .pitch_object
    # .minimum_F0
    # .maximum_F0
    # .start_time
    # .end_time
    # .image_width  - in inches
    # .drawHz       - if .drawHz = 1 then use Hertz,
    #                 if .drawHz = 0 then use semitones

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
        ... .drawHz

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
    if .drawHz = 1
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
    if .drawHz = 1
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
