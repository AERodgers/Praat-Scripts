# GET TABLE STATS
# ===============
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Uses the Info function of Praat to get statistics for '.colX$' and '.colY$'
# in '.table'.
#
# It outputs the following variables (all with the header 'tableStats')
#             standard deviation of x: .stDevX
#             standard deviation of y: .stDevY
#                               slope: .slope
#                           intercept: .intercept
#     pearson correlation coefficient: .r
#                           mean of x: .xMean
#                        .median of x: .xMed
#                           mean of y: .yMean
#                         median of y: .yMed
#                Info function output: .Info$
#
# Undefined values are also returned.
#
# dependencies: @keepCols, @table2array, @list2array

procedure tableStats: .table, .colX$, .colY$
    @keepCols: .table, "'.colX$' '.colY$'", "tableStats.shortTable"

    .numRows = Get number of rows
    .factor$ = Get column label: 1
    if .colX$ != .factor$
        @table2array: .shortTable, .colY$, "tableStats.colTemp$"
        Remove column: .colY$
        Append column: .colY$
        for .i to table2array.n
            Set string value: .i, .colY$, .colTemp$[.i]
        endfor
    endif

    if .numRows > 1
        .stDevY = Get standard deviation: .colY$
        .stDevY = number(fixed$(.stDevY, 3))
        .stDevX = Get standard deviation: .colX$
        noprogress To linear regression
        .linear_regression = selected()
        .linear_regression$ = Info
        .slope = extractNumber (.linear_regression$,
            ... "Coefficient of factor '.colX$': ")
        .slope = number(fixed$(.slope, 3))
        .intercept = extractNumber (.linear_regression$, "Intercept: ")
        .intercept = number(fixed$(.intercept, 3))
        .r = number(fixed$(.slope * .stDevX / .stDevY, 3))
        selectObject: .linear_regression
        .info$ = Info
        Remove
    else
        .stDevY = undefined
        .stDevX = undefined
        .linear_regression = undefined
        .linear_regression$ = "N/A"
        .slope = undefined
        .intercept = Get value: 1, .colY$
        .r = undefined
        .info$ = "N/A"
    endif

    selectObject: .shortTable
    .xMean = Get mean: .colX$
    .xMed = Get quantile: .colX$, 0.5
    .yMean = Get mean: .colY$
    .yMed = Get quantile: .colY$, 0.5
    Remove
endproc

### dependencies
procedure keepCols: .table, .keep_cols$, .new_table$
    @list2array: .keep_cols$, ".keep$"
    '.new_table$' = Copy: .new_table$
    selectObject: .table
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

procedure list2array: .list$, .array$
    .list_len = length(.list$)
    .n = 1
    .prev_start = 1
    for .i to .list_len
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
        '.array$'[.n] = mid$(.list$, .prev_start, .list_len - .prev_start + 1)
    endif
    .origIndex[.n] = .prev_start
endproc

procedure table2array: .table, .col$, .array$
    # Procedure dependencies: none
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
    .arrayN$ = replace$(.array$, "$", "", 1) + "N"
    '.arrayN$' = .n
endproc
