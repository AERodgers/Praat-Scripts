# Utterance Global F0 and Intensity Declination Calculation (basic) 1.2.2
# =================================================================
# Written for Praat 6.x.x
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Sept 13 2019 - Sept 27 2019

# INFO
    # This script is designed to get some global F0 and intensity parameters
    # from a sound file containing a single utterence.
    #
    # The main procedure calculates slope, mean, linear max and min values for
    # pitch and intensity across a complete utterance.
    #
    # Input: 1. sound waveform and textgrid with specifier tier for analysis.
    #        2. user specified min and max F0 (Hz) for pitch estimation (AC)
    #        3. image title
    #        3. legend preferences
    #
    # Main Procedure:
    # This simply calcuates mean values and linear slopes of the contours. It
    # then projects the values of the slopes onto the start and end times of the
    # utterance. There are more sophisticated ways to implement such analyses,
    # but this script was written for very basic analysis purposes.
    #
    # Output:
    #     1. Info window shows F0 and dB stats
    #     2. Graph with spectrogram, F0 and dB contours along with linear
    #       regression lines
    #
    # Caveats:
    # The code assumes that there is only one utterance per sound file.
    # It takes the start time as the beginning of the first interval containing
    # text, and the end time as the offset as the end of the last segment
    # containing text.
    #
    # The UI is also quite crude as is the output procedure.
    #
    # If adapting the procedure, the main procedure will also not run without
    # the other procedures listed below the "DEPENDENCIES" section.
    # The script can be adapted to make this more useful (e.g. batch analysis
    # and table-form output), but I was feeling too lazy to do that at the time.
    # Maybe later!
    # 1.2   - added graphical output
    # 1.2.2 - contour will now correctly (I hope) not draw contour across un-
    #         voiced sections of the F0 (or intensity) contour
    #         dB range now user specified

### Praat version checker
if number(left$(praatVersion$, 1)) < 6
    echo You are running Praat 'praatVersion$'.
    ... 'newline$'This version of Praat is out of date.
    ... 'newline$'To run this script, update to the latest
    ... version at praat.org
    exit
endif

### UI
form F0 and Intensity global declination analysis
    natural textgrid_object 1
    natural text_grid_tier 1
    natural sound_object 2
    comment F0 parameters (in Hertz)
    natural minF0 75
    natural maxF0 450
    comment Intensity parameters (in dB)
    natural min_dB 30
    natural max_dB 90
    comment Graphics options
    sentence title

    choice legend_options 1
        button no legend
        button bottom left
        button bottom right
        button top left
        button top right
endform

# fix legend options
Font size: 10
draw_legend = 1
if legend_options = 1
    draw_legend = 0
    hor = 0
    vert = 0
elsif legend_options = 2
    hor = 0
    vert = 0
elsif legend_options = 3
    hor = 1
    vert = 0
elsif legend_options = 4
    hor = 0
    vert = 1
else
    legend_options = 5
    hor = 1
    vert = 1
endif

@declin: textgrid_object, text_grid_tier, sound_object,  minF0, maxF0,
    ... min_dB, max_dB,
    ... title$, draw_legend
@output
Font size: 10

### Main Procedure
procedure declin: .grid, .tier, .sound, .minF0, .maxF0, .min_dB, .max_dB,
    ... .title$, .draw_legend
    # Get phrase start and end times
    selectObject: .grid
    .num_tiers = Get number of tiers
    if .num_tiers > 1
        .temp_grid = Extract one tier: .tier
    else
        .temp_grid = Copy: "tempTier"
    endif
    .gridTable = Down to Table: "no", 3, "no", "no"
    .num_rows = Get number of rows
    .startT = Get value: 1, "tmin"
    .endT = Get value: .num_rows, "tmax"
    plusObject: .temp_grid
    Remove

    # Get pitch Table
    selectObject: .sound
    .pitchObj = To Pitch (ac):
        ... 0, .minF0, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, .maxF0
    .pitchTier = Down to PitchTier
    .pitchTableTemp = Down to TableOfReal: "Semitones"
    .pitchTable = To Table: "deleteMe"
    Rename: "pitch"
    Remove column: "deleteMe"

    # calculate stats for Pitch
    @tableStats: "declin.pitch_", .pitchTable, "Time", "F0"
    @linearY: "declin.startF0", .pitch_slope, .pitch_intercept, .startT
    @linearY: "declin.endF0", .pitch_slope, .pitch_intercept, .endT
    # round values
    .startF0 = round(.startF0*10)/10
    .endF0 = round(.endF0*10)/10

    # Get intensity table
    selectObject: .sound
    .dB = To Intensity: .minF0, 0, "yes"
    .dBTier= Down to IntensityTier
    .dBTableTemp = Down to TableOfReal
    .dBTable = To Table: "deleteMe"
    Rename: "intensity"
    Remove column: "deleteMe"
    @removeRowsWhere: .dBTable, "Time (s)",
        ... " < '.startT'"
    @removeRowsWhere: .dBTable, "Time (s)",
        ... " > '.endT'"
    Set column label (label): "Intensity (dB)", "Intensity"
    Set column label (label): "Time (s)", "Time"

    # calculate stats for Intensity
    @tableStats: "declin.dB_", .dBTable, "Time", "Intensity"
    @linearY: "declin.dBStart", .dB_slope, .dB_intercept, .startT
    @linearY: "declin.dBEnd", .dB_slope, .dB_intercept, .endT
    # round values
    .dBStart = round(.dBStart*10)/10
    .dBEnd = round(.dBEnd*10)/10

    @drawStuff: .sound, .pitchTable, .dBTable, .startT, .endT,
        ... .minF0, .maxF0, .startF0, .endF0,
        ... .min_dB, .max_dB, .dBStart, .dBEnd,
        ... .title$, .draw_legend

    # remove surplus objects
    selectObject: .pitchObj
    plusObject: .pitchTier
    plusObject: .pitchTableTemp
    plusObject: .pitchTable
    plusObject: .dB
    plusObject: .dBTier
    plusObject: .dBTableTemp
    plusObject: .dBTable
    Remove
endproc

### output Procedure
procedure drawStuff: .sound, .pitch, .dB, .startT, .endT,
    ... .minF0, .maxF0, .startF0, .endF0,
    ... .min_dB, .max_dB, .dBStart, .dBEnd,
    ... .title$, .draw_legend

    # set viewport and ink
    Erase all

    Black
    Line width: 1
    Select outer viewport: 0, 6, 0, 4

    selectObject: .sound
    To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
    Paint: .startT, .endT, 0, 5000, 100, "yes", 50, 6, 0, "no"
    Remove

    if .draw_legend
        @draw_legend: hor, vert
    endif

    # draw white F0 lines
    selectObject: .pitch
    Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
    White
    Line width: 6
    @draw_table_line: .pitch, "Time", "F0", .startT, .endT, 1
    Line width: 4
    Draw line: .startT, .startF0, .endT, .endF0

    # draw white dB lines
    Axes: .startT, .endT, .min_dB, .max_dB
    Line width: 6
    @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 1
    Line width: 4
    Draw line: .startT, .dBStart, .endT, .dBEnd

    # draw coloured F0 lines
    Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
    Solid line
    Line width: 4
    Cyan
    @draw_table_line: .pitch, "Time", "F0", .startT, .endT, 0
    Black
    Dotted line
    @draw_table_line: .pitch, "Time", "F0", .startT, .endT, 0
    Solid line
    Cyan
    Line width: 2
    Draw line: .startT, .startF0, .endT, .endF0

    # draw coloured dB lines
    Axes: .startT, .endT, .min_dB, .max_dB
    Solid line
    Line width: 4
    Green
    @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 0
    Black
    Dotted line
    @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 0
    Solid line
    Green
    Line width: 2
    Draw line: .startT, .dBStart, .endT, .dBEnd

    Line width: 1
    Select outer viewport: 0, 6, 0, 4
    Draw inner box
    # mark F0 Frequencies
    Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
    Line width: 2
    Marks left every: 1, 5, "yes", "yes", "no"
    Line width: 1
    Marks left every: 1, 1, "no", "yes", "no"
    Text left: "yes", "Frequency (ST re 100 Hz)"

    # mark dB Frequencies
    Axes: .startT, .endT, .min_dB, .max_dB
    Line width: 2
    Marks right every: 1, 5, "yes", "yes", "no"
    Line width: 1
    Marks right every: 1, 1, "no", "yes", "no"
    Text right: "yes", "Intensity (dB)"

    Axes: 0, .endT - .startT, .min_dB, .max_dB

    Line width: 2
    Marks bottom every: 1, 0.1, "yes", "yes", "no"
    Line width: 1
    Marks bottom every: 1, 0.02, "no", "yes", "no"
    Text bottom: "yes", "Time (secs)"
    Font size: 14
    Text top: "yes", "##" + .title$

endproc

procedure draw_legend: .hor, .vert
    ### Draw Legend
    Axes: 0, 1, 0, 1
    .text_width = Text width (world coordinates): "intensity contour (dB)"
    .x_unit = Horizontal mm to world coordinates: 4
    .x_start = .x_unit
    .x_end = 4.5 * .x_unit + .text_width
    .y_unit  = Vertical mm to world coordinates: 4
    y_start = .y_unit
    .y_end = .y_unit * 6

    if .hor
        .x_end = 1 - .x_unit
        .x_start = 1 - (4.5 * .x_unit + .text_width)
    endif
    if .vert
        y_start = 1 - (.y_unit * 6)
        .y_end = 1 - .y_unit
    endif

    # Draw legend background
    Paint rectangle: 0.8, .x_start, .x_end,
                 ... y_start,  .y_end
    Black
    Draw rectangle: .x_start, .x_end,
                 ... y_start,  .y_end

    # Draw legend text
    Text: .x_start + 2.5 * .x_unit , "Left", y_start + .y_unit,
        ... "Half", "intensity contour (dB)"
    Text: .x_start + 2.5 * .x_unit, "Left", y_start + .y_unit * 2, "Half",
        ... "F0 contour (ST)"
    Text: .x_start + 2.5 * .x_unit, "Left", y_start + .y_unit * 3,
        ... "Half", "F0 Linear regression"
    Text: .x_start + 2.5 * .x_unit, "Left", y_start + .y_unit * 4,
        ... "Half", "dB Linear regression"

    #F0 contour
    Solid line
    Line width: 6
    Colour: "White"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit,
        ... .x_start + 2 * .x_unit, y_start + .y_unit
    Line width: 4
    Colour: "Cyan"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit,
        ... .x_start + 2 * .x_unit, y_start + .y_unit
    Line width: 2
    Dotted line
    Colour: "Black"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit,
        ... .x_start + 2 * .x_unit, y_start + .y_unit

    # dB contour
    Line width: 6
    Solid line
    Colour: "White"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 2,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 2
    Line width: 4
    Colour: "Green"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 2,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 2
    Line width: 2
    Dotted line
    Colour: "Black"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 2,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 2

    #F0 Linear
    Line width: 4
    Solid line
    Colour: "White"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 3,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 3
    Line width: 2
    Colour: "Cyan"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 3,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 3

    # dB contour
    Line width: 4
    Solid line
    Colour: "White"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 4,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 4
    Line width: 2
    Colour: "Green"
    Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * 4,
        ... .x_start + 2 * .x_unit, y_start + .y_unit * 4
endproc


procedure output
    # output Pitch info
    declin.pitch_min = round(declin.pitch_min * 10) / 10
    declin.pitch_max = round(declin.pitch_max * 10) / 10
    declin.dB_min = round(declin.dB_min * 10) / 10
    declin.dB_max = round(declin.dB_max * 10) / 10


    writeInfoLine: "Pitch Info", newline$, "=========="
    appendInfoLine: "Mean F0 (ST re 100 Hz)             ", declin.pitch_yMean
    appendInfoLine: "Minimum F0 (ST re 100 Hz)          ", declin.pitch_min
    appendInfoLine: "Maximum F0 (ST re 100 Hz)          ", declin.pitch_max
    appendInfoLine: "Linear F0 slope (ST/sec):          ", declin.pitch_slope
    appendInfoLine: "Linear F0 at start (ST re 100 Hz): ", declin.startF0
    appendInfoLine: "Linear F0 at end (ST re 100 Hz):   ", declin.endF0

    # output Intensity info
    appendInfoLine: ""
    appendInfoLine: "Intensity Info", newline$, "=============="
    appendInfoLine: "Mean dB:                         ", declin.dB_yMean
    appendInfoLine: "Minimum dB:                      ", declin.dB_min
    appendInfoLine: "Maximum dB:                      ", declin.dB_max
    appendInfoLine: "Linear intensity slope: (dB/sec) ", declin.dB_slope
    appendInfoLine: "Linear dB at start:              ", declin.dBStart
    appendInfoLine: "Linear dB at end:                ", declin.dBEnd
endproc

### DEPENDENCIES

### mathematical procedures
procedure linearY: .ans$, .slope, .intercept, .x
    '.ans$' = .slope * .x + .intercept
endproc

procedure tableStats: .var$, .table, .colX$, .colY$
    @keepCols: .table, "'.colX$' '.colY$'", "tableStats.shortTable"
    .numRows = Get number of rows
    .factor$ = Get column label: 1
    if .colX$ != .factor$
        appendInfoLine: .colX$, " != ", .factor$
    @table2array: .shortTable, .colY$, "tableStats.colTemp$"
    Remove column: .colY$
    Append column: .colY$
    for .i to table2array.n
        Set string value: .i, .colY$, .colTemp$[.i]
    endfor
    endif

    if .numRows > 1
    '.var$'stDevY = Get standard deviation: .colY$
    '.var$'stDevX = Get standard deviation: .colX$
        '.var$'min = Get minimum: .colY$
    '.var$'max = Get maximum: .colY$
    .linear_regression = To linear regression
    .linear_regression$ = Info
    '.var$'slope = extractNumber (.linear_regression$,
            ... "Coefficient of factor '.colX$': ")
    '.var$'intercept = extractNumber (.linear_regression$, "Intercept: ")
    '.var$'r = round('.var$'slope * '.var$'stDevX / '.var$'stDevY * 1000)
            ... / 1000
    selectObject: .linear_regression
    .info$ = Info
    Remove
    else
    '.var$'stDevY = undefined
    '.var$'stDevX = undefined
        '.var$'min = undefined
    '.var$'max = undefined
    '.var$'linear_regression = undefined
    '.var$'linear_regression$ = "N/A"
    '.var$'slope = undefined
    '.var$'intercept = Get value: 1, .colY$
    '.var$'r = undefined
    .info$ = "N/A"
    endif

    selectObject: .shortTable

    '.var$'xMean = Get mean: .colX$
    '.var$'xMed = Get quantile: .colX$, 0.5
    '.var$'yMean = Get mean: .colY$
    '.var$'yMed = Get quantile: .colY$, 0.5

    # round values
    '.var$'stDevY = round('.var$'stDevY*10)/10
    '.var$'stDevX = round('.var$'stDevX*10)/10
    '.var$'slope = round('.var$'slope*10)/10
    '.var$'intercept = round('.var$'intercept*10)/10

    '.var$'xMean = round('.var$'xMean*10)/10
    '.var$'xMed = round('.var$'xMed*10)/10
    '.var$'yMean = round('.var$'yMean*10)/10
    '.var$'yMed = round('.var$'yMed*10)/10
    Remove
endproc

### Table management procedures
procedure removeRowsWhere: .table, .col$, .criteria$
    selectObject: .table
    .num_rows = Get number of rows
    for .i to .num_rows
        .cur_row = .num_rows + 1 - .i
        .cur_value$ = Get value: .cur_row, .col$
        if number(.cur_value$) '.criteria$'
            Remove row: .cur_row
        endif
    endfor
endproc

procedure keepCols: .table, .keep_cols$, .new_table$
    @list2array: .keep_cols$, ".keep$"
    selectObject: .table
    '.new_table$' = Copy: .new_table$
    .num_cols = Get number of columns
    for .i to .num_cols
        .col_cur = .num_cols + 1 - .i
        .label_cur$ = Get column label: .col_cur
        .keep_me = 0
        for .j to list2array.n
            if .label_cur$ = list2array.keep$[.j]
                .keep_me = 1
            endif
        endfor
        if .keep_me = 0
            Remove column: .label_cur$
        endif
    endfor
endproc

procedure table2array: .table, .col$, .array$
    .string = right$(.array$, 1) = "$"
    selectObject: .table
    .n = Get number of rows
    for .i to .n
        if .string
            .cur_val$ = Get value: .i, .col$
            '.array$'[.i] = .cur_val$
        else
            .cur_val = Get value: .i, .col$
            '.array$'[.i] = .cur_val
        endif
    endfor
endproc

procedure list2array: .list$, .array$
    .list_length = length(.list$)
    .n = 1
    .prev_start = 1
    for .i to .list_length
        .char$ = mid$(.list$, .i, 1)
        if .char$ = " "
            '.array$'[.n] = mid$(.list$, .prev_start, .i - .prev_start)
            .origIndex[.n] = .prev_start
            .n += 1
            .prev_start = .i + 1
        endif
    endfor
    if .n = 1
        '.array$'[.n] = .list$
    else
        '.array$'[.n] = mid$(.list$, .prev_start, .list_length -
            ... .prev_start + 1)
    endif
    .origIndex[.n] = .prev_start
endproc


procedure draw_table_line: .tableObj, .xCol$, .yCol$, .x_axis_min, .x_axis_max,
        ... .ignore_zeros
    selectObject: .tableObj
    .rows_tot = Get number of rows
    @delta: .tableObj
    for .i to .rows_tot - 1
        .x  = Get value: .i, .xCol$
        .y = Get value: .i, .yCol$
        .x_next  = Get value: .i+1, .xCol$
        .y_next = Get value: .i+1, .yCol$
    allDefined = .x != undefined and .x_next != undefined
         ... and .y != undefined and .y_next != undefined
        if not .ignore_zeros or (.y != 0 and .y_next != 0)
            if .x >= .x_axis_min and .x_next <= .x_axis_max
                    ... and allDefined
                    ... and round((.x_next - .x)*100)/100 = delta.x
                 Draw line: .x, .y, .x_next, .y_next
            endif
        endif
    endfor
endproc

procedure delta: .table
    selectObject: .table
    Append column: "deltaX"

    .num_rows = Get number of rows

    for .i to .num_rows - 1
        .val1 = Get value: .i, "Time"
        .val2 = Get value: .i+1, "Time"
        Set numeric value: .i, "deltaX", .val2 - .val1
    endfor
    Set numeric value: .num_rows, "deltaX", .val2 - .val1
    .deltaXMean = Get mean: "deltaX"
    @find_nearest_table: .deltaXMean, .table, "deltaX"
    .x = round(find_nearest_table.val*100)/100
    Remove column: "deltaX"
endproc

procedure find_nearest_table: .input_var, .input_table, .input_col$
    # NB: .input_array$ is the name of the input array as a string without the index references
    .diff = 1e+100
    selectObject: .input_table
    .num_rows = Get number of rows
    for .i to .num_rows
        .val_cur = Get value: .i, .input_col$
        .diff_cur = abs(.input_var - .val_cur)
        if .diff_cur < .diff
            .diff = .diff_cur
            .val = .val_cur
            .index = .i
        endif
    endfor
endproc
