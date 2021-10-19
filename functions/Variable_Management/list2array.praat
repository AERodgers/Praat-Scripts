# CONVERT SPACE-SEPARATED LIST TO ARRAY
# =====================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin

procedure list2array: .list$, .array$
    # Ouputs space-separated items in .list$ as a string array called '.array$'.

    .list_len = length(.list$)
    .n = 1
    .prev_start = 1
    for .i to .list_len
        .char$ = mid$(.list$, .i, 1)
        if .char$ = " "
            '.array$'[.n] = mid$(.list$, .prev_start, .i - .prev_start)
            .origIndex[.n] = .prev_start
            .n += 1
            .prev_start = .i + 1
        endif
    endfor
    if .n = 1
        '.array$'[.n] = .list$
    else
        '.array$'[.n] = mid$(.list$, .prev_start, .list_len - .prev_start + 1)
    endif
    .origIndex[.n] = .prev_start
endproc
