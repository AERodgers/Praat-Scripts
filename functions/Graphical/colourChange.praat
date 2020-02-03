# K-MAX: COLOUR CHANGE
# ========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin

# Changes colour vector string (.curCol$) using command in .change$
# Examples:
#     .change$ =  "+ 0.1" will lighten the colour
#     .change$ = " * 0.5" will halve the brightness of the colour
#     .change$ = " * {0.5,1,0.5} will enhance the greenness of the colour

procedure colourChange: .curCol$, .newCol$, .change$
    .newCol# = '.curCol$' '.change$'
    for .i to 3
        if .newCol#[.i] > 1
            .newCol#[.i] = 1
        elsif .newCol#[.i] < 0
            .newCol#[.i] = 0
        endif
    endfor
    '.newCol$' = "{" + string$(.newCol#[1])
        ... + ", " + string$(.newCol#[2])
        ... + ", " + string$(.newCol#[3]) + "}"
endproc
