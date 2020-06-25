# Convert Hertz to Bark scale
# =============
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# June 24, 2020
#
# Converts a constant, a scalar variable, or a range of table columns from Hertz
# to bark scale. Constants are output in the variable hz2bark.ans

# Uses the formula:
#     bark = 13 * arctan(7.6e-4 * f) + 3.5 * ((f / 7500)^2),
#         where f = frequency in Hz.

# If input object is a table, write the start and end columns to be processed
# in the dummy parameter column with a single space between each,
# e.g., "F1 F4", or just "F1" if only one column will be processed

procedure hz2bark: .inputObject$, .dummyParam$
    if .inputObject$ = string$(number(.inputObject$)) and .dummyParam$ = ""
           .ans = 13 * arctan(7.6e-4 *'.inputObject$') +
              ... 3.5 * (('.inputObject$' / 7500)^2)
           if variableExists(.inputObject$)
               '.inputObject$' = .ans
           endif
    elsif .dummyParam$ != ""
        .inputVar = '.inputObject$'
        selectObject: .inputVar

        .leftMost$ = left$(.dummyParam$, index(.dummyParam$, " ") - 1)
        .rightMost$ = right$(.dummyParam$,
                         ... length(.dummyParam$) - rindex(.dummyParam$, " "))

        if .leftMost$ = ""
            .leftMost$ = .rightMost$
        endif
        Formula (column range): .leftMost$, .rightMost$,
            ... "fixed$(13 * arctan(7.6e-4 * self) + 3.5 * ((self / 7500)^2), 3)"
    elsif variableExists(.inputObject$)
        '.inputObject$' = 13 * arctan(7.6e-4 * '.inputObject$') +
                    ... 3.5 * (('.inputObject$' / 7500)^2)
    endif
endproc
