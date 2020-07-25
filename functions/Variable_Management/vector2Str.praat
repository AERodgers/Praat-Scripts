# VECTOR 2 STRING
# ================
# Written for Praat 6.1.08

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020
#
# converts a vector to a string with the same variable name, where # --> $,
# in which the string still maintains the vector structure of "{0,0,0}".

procedure vector2Str: .vectorVar$

    .stringVar$ = replace$(.vectorVar$, "#", "$", 0)
    .vector# = '.vectorVar$'
    '.stringVar$' = "{"
    for .i to size(.vector#)
        '.stringVar$' += string$(.vector#[.i]) + ","
    endfor
    '.stringVar$' = left$('.stringVar$', length('.stringVar$') - 1) + "}"
endproc
