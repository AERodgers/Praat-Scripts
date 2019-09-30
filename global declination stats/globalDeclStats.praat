# Utterance Global F0 and Intensity Declination Calculation (basic) 1.3.2
# =======================================================================
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
    #        3. user specified min and max dB (Hz) for intensity
    #        4. image title
    #        5. contour prefereces
    #        6. legend preferences
    #
    # Main Procedure:
    # This simply calcuates mean values and linear slopes of the contours. It
    # then projects the values of the slopes onto the start and end times of the
    # utterance. There are more sophisticated ways to implement such analyses,
    # but this script was written for very basic analysis purposes.
    #
    # Output:
    #     1. Info window shows F0 and dB stats
    #     2. Graph with spectrogram, F0 and dB contours along with linear re-
    #        gression lines, and upper/lower F0 linear regression (as per input)
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
    # 1.3.1 - added option to draw upper and lower F0 regression lines as per
    #         Haan (2002)
    #       - created more intelligent legend legend_options
    #       - added option to include only F0 or dB contours in menu
    # 1.3.2 - improved text output
    #
    # REFERENCE
    # Haan, J. (2002) Speaking of Questions - An Exploration of Dutch
    #     Question Intonation. Utrecht: LOT.

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
    integer min_dB 30
    integer max_dB 90
    comment Graphics options
    sentence title
    choice contour_options 1
        button F0 only
        button F0 and intensity
        button Intensity only
    boolean draw_upper_and_lower_F0_regression 0
    choice legend_options 1
        button no legend
        button bottom left
        button bottom right
        button top left
        button top right
endform


haanLines = draw_upper_and_lower_F0_regression

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

@declin: textgrid_object, text_grid_tier, sound_object, minF0, maxF0,
    ... min_dB, max_dB,
    ... title$, draw_legend,
    ... haanLines, contour_options, hor, vert
@output
Font size: 10

### MAIN PROCEDURE
procedure declin: .grid, .tier, .sound, .minF0, .maxF0, .min_dB, .max_dB,
    ... .title$, .draw_legend, .haanLines, .contour_options, .hor, .vert
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
    @getPitchTable: .sound, .minF0, .maxF0, "declin"

    # calculate stats for Pitch
    @tableStats: "declin.pitch_", .pitchTable, "Time", "F0"
    @linearY: "declin.startF0", .pitch_slope, .pitch_intercept, .startT
    @linearY: "declin.endF0", .pitch_slope, .pitch_intercept, .endT
    if .haanLines
        @linHaan: .pitchTable, "Time", "F0"
    endif
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
        ... .title$, .draw_legend,
        ... .haanLines, .contour_options,
        ... .hor, .vert

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

### DEPENDENCIES
### input / output Procedure
procedure getPitchTable: .sound, .minF0, .maxF0, calledFrom$
    selectObject: .sound
    'calledFrom$'.pitchObj = To Pitch (ac):
        ... 0, .minF0, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, .maxF0
    'calledFrom$'.pitchTier = Down to PitchTier
    'calledFrom$'.pitchTableTemp = Down to TableOfReal: "Semitones"
    'calledFrom$'.pitchTable = To Table: "deleteMe"
    Rename: "pitch"
    Remove column: "deleteMe"
endproc

procedure drawStuff: .sound, .pitch, .dB, .startT, .endT,
    ... .minF0, .maxF0, .startF0, .endF0,
    ... .min_dB, .max_dB, .dBStart, .dBEnd,
    ... .title$, .draw_legend,
    ... .haanLines, .contour_options,
    ... .hor, .vert

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
        @draw_legend: .hor, .vert, .haanLines, .contour_options
    endif

    # draw white outlines
    White
    if .contour_options < 3
        # draw white F0 lines
        selectObject: .pitch
        Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
        Line width: 6
        @draw_table_line: .pitch, "Time", "F0", .startT, .endT, 1
        Line width: 4
        Draw line: .startT, .startF0, .endT, .endF0
    endif
    if .contour_options > 1
        # draw white dB lines
        Axes: .startT, .endT, .min_dB, .max_dB
        Line width: 6
        @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 1
        Line width: 4
        Draw line: .startT, .dBStart, .endT, .dBEnd
    endif

    # draw coloured contours
    if .contour_options > 1
        # draw coloured dB lines
        Axes: .startT, .endT, .min_dB, .max_dB
        Solid line
        Line width: 4
        Green
        @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 0
        Lime
        Line width: 1
        Solid line
        @draw_table_line: .dB, "Time", "Intensity", .startT, .endT, 0
        Solid line
        Green
        Line width: 2
        Draw line: .startT, .dBStart, .endT, .dBEnd
    endif

    if .contour_options < 3
        # draw coloured F0 lines
        Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
        Solid line
        Line width: 4
        Blue
        @draw_table_line: .pitch, "Time", "F0", .startT, .endT, 0
        #Cyan
        #Dotted line
        #@draw_table_line: .pitch, "Time", "F0", .startT, .endT, 0
        Solid line
        Cyan
        Line width: 2
        Draw line: .startT, .startF0, .endT, .endF0

        if .haanLines
            White
            Solid line
            Line width: 1
            .uLineStF0 = .startT *  linHaan.slope_upper + linHaan.intercept_upper
            .uLineEndF0 = .endT *  linHaan.slope_upper + linHaan.intercept_upper
            Draw line: .startT, .uLineStF0, .endT, .uLineEndF0
            .lLineStF0 = .startT *  linHaan.slope_lower + linHaan.intercept_lower
            .lLineEndF0 = .endT *  linHaan.slope_lower + linHaan.intercept_lower
            Draw line: .startT, .lLineStF0, .endT, .lLineEndF0
            Blue
            Dotted line
            Line width: 1
            @linHaan: .pitch, "Time", "F0"
            .uLineStF0 = .startT *  linHaan.slope_upper + linHaan.intercept_upper
            .uLineEndF0 = .endT *  linHaan.slope_upper + linHaan.intercept_upper
            Draw line: .startT, .uLineStF0, .endT, .uLineEndF0
            .lLineStF0 = .startT *  linHaan.slope_lower + linHaan.intercept_lower
            .lLineEndF0 = .endT *  linHaan.slope_lower + linHaan.intercept_lower
            Draw line: .startT, .lLineStF0, .endT, .lLineEndF0
            Solid line
        endif
    endif

    if .contour_options < 3
        # mark F0 frequency axis
        Axes: .startT, .endT, log2(.minF0/100)*12, log2(.maxF0/100)*12
        Line width: 2
        Marks left every: 1, 5, "yes", "yes", "no"
        Line width: 1
        Marks left every: 1, 1, "no", "yes", "no"
        Text left: "yes", "Frequency (ST re 100 Hz)"
    endif

    if .contour_options > 1
        # mark dB Frequency axis
        Axes: .startT, .endT, .min_dB, .max_dB
        Line width: 2
        Marks right every: 1, 5, "yes", "yes", "no"
        Line width: 1
        Marks right every: 1, 1, "no", "yes", "no"
        Text right: "yes", "Intensity (dB)"
    endif

    # mark time axis
    Axes: 0, .endT - .startT, 0, 1
    Draw inner box
    Line width: 2
    Marks bottom every: 1, 0.1, "yes", "yes", "no"
    Line width: 1
    Marks bottom every: 1, 0.02, "no", "yes", "no"
    Text bottom: "yes", "Time (secs)"

    # add title
    Font size: 14
    Text top: "yes", "##" + .title$
endproc

procedure draw_legend: .hor, .vert, .haanLines, .contour_options
    #calculate legend contents
    .legendLines = 0
    if .contour_options < 3
        if .haanLines
            .legendLines = .legendLines + 1
            .legendText$[.legendLines] = "Upper/Lower F0 regression"
            .whiteSize[.legendLines] = 1
            .colour1$[.legendLines] = "Blue"
            .colour2$[.legendLines] = "Blue"
            .colour1Size[.legendLines] = 1
            .colour2Size[.legendLines] = 1
            .line1Type$[.legendLines] = "Dotted line"
            .line2Type$[.legendLines] = "Dotted line"
        endif

        .legendLines = .legendLines + 1
        .legendText$[.legendLines] = "F0 linear regression"
        .whiteSize[.legendLines] = 4
        .colour1$[.legendLines] = "Cyan"
        .colour2$[.legendLines] = "Cyan"
        .colour1Size[.legendLines] = 2
        .colour2Size[.legendLines] = 2
        .line1Type$[.legendLines] = "Solid line"
        .line2Type$[.legendLines] = "Solid line"

        .legendLines = .legendLines + 1
        .legendText$[.legendLines] = "F0 contour"
        .whiteSize[.legendLines] = 6
        .colour1$[.legendLines] = "Blue"
        .colour2$[.legendLines] = "Blue"
        .colour1Size[.legendLines] = 4
        .colour2Size[.legendLines] = 2
        .line1Type$[.legendLines] = "Solid line"
        .line2Type$[.legendLines] = "Solid line"
    endif

    if .contour_options > 1
        .legendLines = .legendLines + 1
        .legendText$[.legendLines] = "dB linear regression"
        .whiteSize[.legendLines] = 4
        .colour1$[.legendLines] = "Green"
        .colour2$[.legendLines] = "Green"
        .colour1Size[.legendLines] = 2
        .colour2Size[.legendLines] = 2
        .line1Type$[.legendLines] = "Solid line"
        .line2Type$[.legendLines] = "Solid line"

        .legendLines = .legendLines + 1
        .legendText$[.legendLines] = "dB contour"
        .whiteSize[.legendLines] = 6
        .colour1$[.legendLines] = "Green"
        .colour2$[.legendLines] = "Lime"
        .colour1Size[.legendLines] = 4
        .colour2Size[.legendLines] = 1
        .line1Type$[.legendLines] = "Solid line"
        .line2Type$[.legendLines] = "Solid line"
    endif

    # calculate legend width
    .legendWidth = 0
    .legendWidth$ = ""
    for .i to .legendLines
        .len = length(.legendText$[.i])
        if .len > .legendWidth
            .legendWidth = .len
            .legendWidth$ =  .legendText$[.i]
        endif
    endfor

    ### Draw Legend
    Axes: 0, 1, 0, 1
    .text_width = Text width (world coordinates): .legendWidth$
    .x_unit = Horizontal mm to world coordinates: 4
    .x_start = .x_unit
    .x_end = 4.5 * .x_unit + .text_width
    .y_unit  = Vertical mm to world coordinates: 4
    y_start = .y_unit
    .y_end = .y_unit * (.legendLines + 2)

    if .hor
        .x_end = 1 - .x_unit
        .x_start = 1 - (4.5 * .x_unit + .text_width)
    endif
    if .vert
        y_start = 1 - (.y_unit * (.legendLines + 2))
        .y_end = 1 - .y_unit
    endif

    # Draw legend background
    Paint rectangle: 0.8, .x_start, .x_end,
                 ... y_start,  .y_end
    Black
    Draw rectangle: .x_start, .x_end,
                 ... y_start,  .y_end


    for .i to .legendLines
        Font size: 10
        Solid line
        Black
        Text: .x_start + 2.5 * .x_unit , "Left", y_start + .y_unit * .i,
            ... "Half", .legendText$[.i]

        Line width: .whiteSize[.i]
        Colour: "White"
        Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * .i,
                ... .x_start + 2 * .x_unit, y_start + .y_unit * .i

        Line width: .colour1Size[.i]
        Colour: .colour1$[.i]
        .curLineType$ = .line1Type$[.i]
        '.curLineType$'
        Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * .i,
                    ... .x_start + 2 * .x_unit, y_start + .y_unit * .i

        Line width: .colour2Size[.i]
        Colour: .colour2$[.i]
        .curLineType$ = .line2Type$[.i]
        '.curLineType$'
        Draw line: .x_start + 0.5 * .x_unit, y_start + .y_unit * .i,
                    ... .x_start + 2 * .x_unit, y_start + .y_unit * .i

    endfor
endproc

procedure output
    # output Pitch info
    declin.pitch_min = round(declin.pitch_min * 10) / 10
    declin.pitch_max = round(declin.pitch_max * 10) / 10
    declin.dB_min = round(declin.dB_min * 10) / 10
    declin.dB_max = round(declin.dB_max * 10) / 10
    writeInfoLine: "STATS FOR SOUND WAVEFORM"
    appendInfoLine: "========================", newline$
    if contour_options < 3
        appendInfoLine: "Pitch Info", newline$,
            ... "-----------------------------------------------"
        appendInfoLine: "Mean F0 (ST re 100 Hz).................... ",
            ... declin.pitch_yMean
        appendInfoLine: "Minimum F0 (ST re 100 Hz)................. ",
            ... declin.pitch_min
        appendInfoLine: "Maximum F0 (ST re 100 Hz)................. ",
            ... declin.pitch_max
        appendInfo: newline$
        appendInfoLine: "Linear F0 slope (ST/sec).................. ",
            ... declin.pitch_slope
        appendInfoLine: "Linear F0 intercept (ST re 100 Hz)........ ",
            ... declin.pitch_intercept
        appendInfoLine: "Linear F0 at start (projection, ST)....... ",
            ... declin.startF0
        appendInfoLine: "Linear F0 at end (projection, ST)......... ",
            ... declin.endF0

        if haanLines
            appendInfoLine: newline$,
                ... "Upper and Lower F0 Regression Lines",
                ... newline$, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            appendInfoLine: "Upper Linear F0 slope (ST/sec)............ ",
                ... linHaan.slope_upper
            appendInfoLine: "Upper Linear F0 intercept (ST re 100 Hz).. ",
                ... linHaan.intercept_upper
            appendInfoLine: "Lower Linear F0 slope (ST/sec)............ ",
                ... linHaan.slope_lower
            appendInfoLine: "Lower Linear F0 intercept (ST re 100 Hz).. ",
                ... linHaan.intercept_lower
        endif
    endif

    if contour_options > 1
        # output Intensity info
        appendInfoLine: newline$
        appendInfoLine: "Intensity Info", newline$,
            ... "---------------------------------------"
        appendInfoLine: "Mean dB........................... ", declin.dB_yMean
        appendInfoLine: "Minimum dB........................ ", declin.dB_min
        appendInfoLine: "Maximum dB........................ ", declin.dB_max
        appendInfo: newline$
        appendInfoLine: "Linear intensity slope: (dB/sec).. ", declin.dB_slope
        appendInfoLine: "Linear intensity intercept (dB)... ",
            ... declin.dB_intercept
        appendInfoLine: "Linear dB at start (projection)... ", declin.dBStart
        appendInfoLine: "Linear dB at end (projection)..... ", declin.dBEnd
    endif

endproc
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

procedure linHaan: .table, .xCol$, .yCol$
    # Return linear regression lines of a contour from table form.
    # This procedure will return the upper and lower regression line for contour
    # (converted to table form) based on the overall linear regression line.
    # This is based on Haan's (2002) approach to getting an approximation
    # of upper and lower slopes / regresion lines of an F0 contour.
    #
    # input: table, xCol$ [e.g. "Time"], yCol$ [e.g. "F0"]
    # output: linHaan.slope, linHaan.intercept
    #         linHaan_lower.slope, linHaan_lower.intercept
    #         linHaan_upper.slope, linHaan_upper.intercept

    @tableStats: "linHaan.", .table, .xCol$, .yCol$
    .slopeGen = .slope
    .interceptGen = .intercept

    # Get suffix for output variable
    .sign$[1] = "<"
    .sign$[2] = ">"

    for .i to 2
        # Create temporary table
        selectObject: .table
        .tempTable = Copy: "TempTable"
        # Get table metadata
        .numRows = Get number of rows

        .direction$ = .sign$[.i]
        .ending$ = "_lower"
        if .direction$ = "<"
            .ending$ = "_upper"
        endif

        # Remove rows above / below the linear regression value
        for .row from 0 to .numRows - 1
            selectObject: .tempTable
            .x = .numRows - .row
            .yAct = Get value: .x, .yCol$
            .xAct = Get value: .x, .xCol$
            .yLinear = .slope * .xAct + .intercept
            if .yAct '.direction$' .yLinear
                Remove row: .x
            endif
        endfor

        # Get linear regression for values above / below main regression line
        @tableStats: "linHaan.", .tempTable, .xCol$, .yCol$
        .slope'.ending$' = .slope
        .intercept'.ending$' = .intercept

        # Remove surplus objects
        selectObject: .tempTable
        Remove
    endfor
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
