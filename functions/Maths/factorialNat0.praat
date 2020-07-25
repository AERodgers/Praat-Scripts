# FACTORIAL OF NATURAL NUMBERS (INCLUDING 0)
# ==========================================
# Written for Praat 6.1.08
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 25, 2020
#
#   This procedure returns the factorial of a natural number (including 0).
#   The input value is ".in" and the output variable is the literal value
#   of the string ".out$" .

procedure factorialNat0: .in, .out$
    # '.out$' = .in!, where .in is a natural number (including 0)
    if .in != abs(round(.in))
        '.out$' = undefined
    elsif .in = 0
        '.out$' = 1
    else
        '.out$' = .in
        for .i from 2 to .in - 1
            '.out$' = '.out$' * .i
        endfor
    endif
endproc
