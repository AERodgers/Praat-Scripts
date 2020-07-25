# POP
# ========================
# Written for Praat 6.1.08
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 25, 2020
#
#   This procedure takes a numeric or string array as its input.
#   It returns the .value$ at .array$[.index]
#   It shifts all values from '.array$'[.index + 1] to the array end
#   down one index.
#   The new array size is returned as '.array$'_N, minus "$" if the input
#   was a string array.
#
#   NOTE: * Empty strings and undefined array values are are dummy values to
#           be ignored.
#         * .value$ must be entered as a string EVEN for numeric arrays

procedure pop: .array$, .index, .value$

    # Get '.value$' at .index to be popped.
    '.value$'  = '.array$'[.index]

    # Second loop condition depends on whether input a string or numeric array.
    if right$(.array$) = "$"
        .condition2$ = """"""
    else
        .condition2$ = "undefined"
    endif

    # Calculate array size.
    .i = .index
    while variableExists("'.array$'['.i']") and '.array$'[.i] != '.condition2$'
        .i += 1
    endwhile

    # Get new array size.
    .size$ = replace$("'.array$'_N", "$", "", 1)
    '.size$' = .i - 2

    # shift all values from .index + 1 to array end down one value
    for .j from .index to .i - 2
        '.array$'[.j] = '.array$'[.j + 1]
    endfor

    # Replace previous final index value with dummy value.
    if right$(.array$) = "$"
        '.array$'[.i - 1] = ""
    else
        '.array$'[.i - 1] = undefined
    endif

endproc
