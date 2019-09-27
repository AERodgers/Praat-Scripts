# Utterance Global F0 and Intensity Declination Calculation (basic)
# =================================================================
# Written for Praat 6.x.x
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Sept 13 2019

# INFO
    # This script is designed to get some global F0 and intensity parameters
    # from an sound file containing a single utterence.
    #
    # The main procedure calculates slope, mean, linear max and min values for
    # pitch and intensity across a complete utterance.
    #
    # Input: 1. sound waveform and textgrid with single interval tier showing
    #           start and end of the utterance (enter number on object window)
    #        2. User specified min and max F0 (Hz) for pitch estimation (AC)
    #
    # Main Procedure:
    # This simply calcuates mean values and linear slopes of the contours. It
    # then projects the values of the slopes onto the start and end times of the
    # utterance. There are more sophisticated ways to implement such analyses,
    # but this script was written for very basic analysis purposes.
    #
    # Caveats:
    # The UI is also quite crude and as is the output procedure.
    # The main procedure will also not run without the other procedures listed
    # under "### DEPENDENCIES".
    # The script can be adapted to make this more useful (e.g. batch analysis
    # and table-form output), but I was feeling too lazy to do that at the time.
    # Maybe later!

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
    natural sound_object 2
    comment F0 parameters (in Hertz)
    natural minF0 50
    natural maxF0 450
endform

@declin: textgrid_object, sound_object,  minF0, maxF0
@output

### Main Procedure
procedure declin: .grid, .sound, .minF0, .maxF0
    # Get phrase start and end times
    selectObject: .grid
    .gridTable = Down to Table: "no", 3, "no", "no"
    .startT = Get value: 1, "tmin"
    .endT = Get value: 1, "tmax"
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
procedure output
    # output Pitch info
    writeInfoLine: "Pitch Info", newline$, "=========="
    appendInfoLine: "Linear F0 slope:    ", declin.pitch_slope, " ST/sec"
    appendInfoLine: "Linear F0 at start: ", declin.startF0, " ST re 100 Hz"
    appendInfoLine: "Linear F0 at end:   ", declin.endF0, " ST re 100 Hz"
    appendInfoLine: "Mean F0:            ", declin.pitch_yMean, " ST re 100 Hz"

    # output Intensity info
    appendInfoLine: ""
    appendInfoLine: "Intensity Info", newline$, "=============="
    appendInfoLine: "Linear intensity slope:", declin.dB_slope," dB/sec"
    appendInfoLine: "Linear dB at start:    ", declin.dBStart, " dB"
    appendInfoLine: "Linear dB at end:      ", declin.dBEnd, " dB"
    appendInfoLine: "Mean dB:               ", declin.dB_yMean, " dB"

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
		.linear_regression = To linear regression
		.linear_regression$ = Info
		'.var$'slope = extractNumber (.linear_regression$, "Coefficient of factor '.colX$': ")
		'.var$'intercept = extractNumber (.linear_regression$, "Intercept: ")
		'.var$'r = round('.var$'slope * '.var$'stDevX / '.var$'stDevY * 1000) / 1000
		selectObject: .linear_regression
		.info$ = Info
		Remove
	else
		'.var$'stDevY = undefined
		'.var$'stDevX = undefined
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
        '.array$'[.n] = mid$(.list$, .prev_start, .list_length - .prev_start + 1)
    endif
    .origIndex[.n] = .prev_start
endproc