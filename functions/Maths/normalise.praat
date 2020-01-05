# NORMALISE
# =========
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Normalises '.col$' in '.table' to its min and max values.
# NB: the function replaces the original values
#
# dependencies: @removeRowsWhere
#
#     N
#  ------           y   -  y
#  \                 n      min
#   |     y_norm  = -----------
#  /            n   y   -  y
#  ------            max    min
#   n = 1


procedure normalise: .table, .col$
    selectObject: .table
    .temp = Copy: "temp"
    @removeRowsWhere: normalise.temp, .col$, "= ""--undefined--"""
    .yMin = Get minimum: .col$
    .yMax = Get maximum: .col$
    Remove
    selectObject: .table
    Formula: .col$, "(self - .yMin)/(.yMax-.yMin)"
endproc

# dependency
procedure removeRowsWhere: .table, .col$, .criteria$
    selectObject: .table
    .num_rows = Get number of rows
    for .i to .num_rows
        .cur_row = .num_rows + 1 - .i
        .cur_value$ = Get value: .cur_row, .col$
        if .cur_value$ '.criteria$'
            Remove row: .cur_row
        endif
    endfor
endproc
