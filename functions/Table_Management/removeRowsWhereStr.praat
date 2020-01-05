# Remove rows containing string values in a table with criteria .criteria$
# ========================================================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Removes rows with strings in '.col$' in '.table' which meet '.criteria$'

procedure removeRowsWhereStr: .table, .col$, .criteria$
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
