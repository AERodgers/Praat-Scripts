# CREATE TEMPORARY TEXTGRID / REMERGE
# =========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# @textgridTemp: .original$, .keep_list$
#     - Create a temporary textgrid called textgridTemp.object which keeps only
#       tiers listed in a space-separated .keep_list$ string. (NB: textgrid tiers
#        must NOT have spaces in them.)
#     - .original$ should contain the variable name of the original textgrid,
#       (e.g. @textgridTemp: "myTextgrid, "Mary John bell")
#
# @textgridMerge
#     - Merges textgridTemp.object with original textgrid, replacing original
#       tiers with any changes in .keep_list$ tiers
#
# This is very useful if you have a script and only want to display a sub-set
# of the tiers during editing to avoid textgrid crowding in the textgrid window.

procedure textgridTemp: .original$, .keep_list$
    if not variableExists("textgridTemp.mergeNow")
        .mergeNow = 1
    else
        .mergeNow = 1
    endif

    if .mergeNow

    # convert .keep_list$ to array of tiers to be kept
    # (.keep$[.n] with .n elements)
    .list_length = length(.keep_list$)
    .n = 1
    .prev_start = 1
    for .i to .list_length
        .char$ = mid$(.keep_list$, .i, 1)
        if .char$ = " "
            .keep$[.n] = mid$(.keep_list$, .prev_start, .i - .prev_start)
            .n += 1
            .prev_start = .i + 1
        endif

        if .n = 1
            .keep$[.n] = .keep_list$
        else
            .keep$[.n] = mid$
                ... (.keep_list$, .prev_start, .list_length - .prev_start + 1)
        endif
    endfor

    # create a copy of '.original$' and keep target tiers
    selectObject: '.original$'
    .num_tiers = Get number of tiers
    .name$ = selected$("TextGrid")
    .name$ += "_temp"
    .object = Copy: .name$
    for .i to .num_tiers
        .cur_tier = .num_tiers + 1 - .i
        .tiersInTemp = Get number of tiers
        .name_cur$ = Get tier name: .cur_tier
        .keepMe = 0
        for .j to .n
            if .keep$[.j] = .name_cur$
                .keepMe = 1
            endif
        endfor
        if not .keepMe
            Remove tier: .cur_tier
        endif
    endfor
endproc

procedure textgridMerge
    # get number of and list of original and temporary tiers
    selectObject: textgridTemp.object
    .temp_n_tiers = Get number of tiers
    for .i to .temp_n_tiers
        .temp_tier$[.i] = Get tier name: .i
    endfor
    selectObject: 'textgridTemp.original$'
    .orig_n_tiers = Get number of tiers
    .name$ = selected$("TextGrid")
    for .i to .orig_n_tiers
        .orig_tier$[.i] = Get tier name: .i
    endfor

    # create 1st tier of merged tier
    selectObject: 'textgridTemp.original$'
    Extract one tier: 1
    .new = selected()
    if .orig_tier$[1] = .temp_tier$[1]
        selectObject: textgridTemp.object
        Extract one tier: 1
        .temp_single_tier = selected ()
        plusObject: .new
        Merge
        .newNew =selected()
        Remove tier: 1
        selectObject: .temp_single_tier
        plusObject: .new
        Remove
        .new = .newNew
    endif

    # merge tiers 2 to .orig_n_tiers
    for .i from 2 to .orig_n_tiers
        .useTemp = 0
        for .j to .temp_n_tiers
            if .orig_tier$[.i] =  .temp_tier$[.j]
                .useTemp = .j
            endif
        endfor
        if .useTemp
            selectObject: textgridTemp.object
            Extract one tier: .useTemp
        else
            selectObject: 'textgridTemp.original$'
            Extract one tier: .i
        endif
        .temp_single_tier = selected ()
        plusObject: .new
        Merge
        .newNew =selected()
        selectObject: .temp_single_tier
        plusObject: .new
        Remove
        .new = .newNew
    endfor
    selectObject: 'textgridTemp.original$'
    plusObject: textgridTemp.object
    Remove
    'textgridTemp.original$' = .new
    selectObject: 'textgridTemp.original$'
    Rename: .name$
endproc
