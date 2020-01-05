# CONVERT TABLE COLUMN TO ARRAY
# =============================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# converts '.col$' of '.table' to an '.array$'
# '.array$'N [excluding $ sign if string array] = number of elements in array

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
