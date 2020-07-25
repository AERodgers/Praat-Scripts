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
#     .size$   -> a string with the literal name of an out variable
#                 stating the size the array.
#     .array$  -> a string with the literal name of the output array

procedure line2Array: .string$, .sep$, .size$, .array$
    # correct variable name Strings
    .size$ = replace$(.size$, "$", "", 0)
    if right$(.array$, 1) != "$"
        .array$ += "$"
    endif
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
        '.array$'['.size$'] = left$(.string$, .nextElementEnds)
        .string$ = replace$(.string$, '.array$'['.size$'], "", 1)
        '.array$'['.size$'] = replace$('.array$'['.size$'], .sep$, "", 1)
        if '.array$'['.size$'] = ""
            '.size$' -= 1
        endif
    endwhile
endproc
