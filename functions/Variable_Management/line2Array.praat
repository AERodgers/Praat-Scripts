# LINE 2 ARRAY
# ================
# Written for Praat 6.1.08

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020
#
# This is generalised version of @csvline2array and @list2Array.
# It converts a string with separators (.sep$) to an array of values.
#
# NOTE: * Single spaces after separators are removed.
#       * Multiple spaces are reduced to single spaces.
#       * Empty values (i.e. ",," or "'tab$''tab$'") are ignored.
#
# Arguments to the procedure:
#     .string$ -> the input string
#     .sep$    -> the separator used in the string$
#     .out$  -> a string with the literal name of the output array;
#               array size is stored as the variable "'.out$'_N"

procedure line2Array: .string$, .sep$, .out$
    # correct variable name Strings
    if right$(.out$, 1) != "$"
        .out$ += "$"
    endif
    .size$ = replace$(.out$, "$", "_N", 0)

    # fix input csvLine array
    .string$ = replace$(.string$, "'.sep$' ", .sep$, 0)
    while index(.string$, "  ")
        .string$ = replace$(.string$, "  ", " ", 0)
    endwhile
    .string$ = replace_regex$ (.string$, "^[ \t\r\n]+|[ \t\r\n]+$", "", 0)
    .string$ += .sep$
    # generate output array
    '.size$' = 0
    while length(.string$) > 0
        '.size$' += 1
        .nextElementEnds = index(.string$, .sep$)
        '.out$'['.size$'] = left$(.string$, .nextElementEnds)
        .string$ = replace$(.string$, '.out$'['.size$'], "", 1)
        '.out$'['.size$'] = replace$('.out$'['.size$'], .sep$, "", 1)
        if '.out$'['.size$'] = ""
            '.size$' -= 1
        endif
    endwhile
endproc
