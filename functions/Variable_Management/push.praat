# PUSH
# ========================
# Written for Praat 6.1.08
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 25, 2020
#
#   This procedure takes a numeric or string array as its input.
#   It shifts all values from '.array$'[.index] to the array end
#   up one index. It then assigns '.value$' to the original .index.
#   The new array size is returned as '.array$'_N, minus "$" if the input
#   was a string array.
#
#   NOTE: * Empty strings and undefined array values are are dummy values to
#           be ignored.
#         * .value$ must be entered as a string EVEN for numeric arrays

procedure push: .array$, .index, .value$

    # Second loop condition depends on whether input a string or numeric array.
    if right$(.array$) = "$"
        .condition2$ = """"""
    else
        .condition2$ = "undefined"
    endif

    # Get array of values after .index
    .i = .index
    while variableExists("'.array$'['.i']") and '.array$'[.i] != '.condition2$'
        .pushed'.array$'[.i - .index + 1] = '.array$'[.i]
        .i += 1
    endwhile

    # insert '.value$' at .index
    if right$(.array$) = "$"
        '.array$'[.index] = .value$
    else
        '.array$'[.index] = '.value$'
    endif

    # push all values from .index to array end up one value
    for .j from .index + 1 to .i
        '.array$'[.j] = .pushed'.array$'[.j - .index]
    endfor

    # get size of new array
    .size$ = replace$("'.array$'_N", "$", "", 1)
    '.size$' = .i
endproc
