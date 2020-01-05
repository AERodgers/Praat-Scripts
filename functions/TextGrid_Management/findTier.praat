# FIND TIER NUMBER
# ================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Output index of '.tier$' in '.textgrid'
# to variable declared in string .outputVar$
# 0 = tier not found

procedure findTier: .outputVar$, .textgrid, .tier$
    '.outputVar$' = 0
    selectObject: .textgrid
    .numTiers = Get number of tiers
    for .i to .numTiers
        .curTier$ = Get tier name: .i
        if .curTier$ = .tier$
            '.outputVar$' = .i
            .i = .numTiers
        endif
    endfor
endproc
