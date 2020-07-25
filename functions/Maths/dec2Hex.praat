# DECIMAL TO HEXADECIMAL
# ======================
# Written for Praat 6.1.08
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 25, 2020
#
#   This procedure converts a positive decimal integer to a hexadeximal string.
#   The input decimal value is ".in" and the output variable is the literal
#   value of the string ".out$" .

procedure dec2hex: .in, .out$
    if right$(.out$) != "$"
        .out$ = .out$ + "$"
    endif
    .hex$[0] = "0"
    .hex$[1] = "1"
    .hex$[2] = "2"
    .hex$[3] = "3"
    .hex$[4] = "4"
    .hex$[5] = "5"
    .hex$[6] = "6"
    .hex$[7] = "7"
    .hex$[8] = "8"
    .hex$[9] = "9"
    .hex$[10] = "A"
    .hex$[11] = "B"
    .hex$[12] = "C"
    .hex$[13] = "D"
    .hex$[14] = "E"
    .hex$[15] = "F"
    .q = .in
    '.out$' = ""
    while .q > 0
        .q = floor(.in / 16)
        .r = .in - .q * 16
        '.out$' =  .hex$[.r] + '.out$'
        .in = .q
    endwhile
endproc
