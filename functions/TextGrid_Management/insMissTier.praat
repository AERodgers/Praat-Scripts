# INSERT MISSING TIER
# ===================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Insert tier named '.tierName$' after tier '.after$'  in '.textgrid' if it
# does not already exist in the textgrid.
#     '.isInterval' = 1    ==> insert interval tier
#     '.isInterval' = 0    ==> insert point tier
 
procedure insMissTier: .textgrid, .tierName$, .after$, .isInterval
    selectObject: .textgrid
    .numTiers = Get number of tiers
    .tierNum = 0
    .existsAsInt = 0
    .tierExists = 0
    .after = 0
    for .curTier to .numTiers
        .curIsInt = Is interval tier: .curTier
        .curTier$ = Get tier name: .curTier
        if .curTier$ = .tierName$
            .tierExists  = 1
            .tierNum = .curTier
            .existsAsInt = .curIsInt
        elsif .curTier$ = .after$
            .after = .curTier
        endif
    endfor

    if .tierExists and .isInterval != .existsAsInt
        Remove tier: .tierNum
        .numTiers -= 1
        .tierExists = 0
    endif

    if not .tierExists
        if .isInterval
            Insert interval tier: .after + 1, .tierName$
        else
            Insert point tier: .after + 1, .tierName$
        endif
    endif
endproc
