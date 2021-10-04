# LINE FUNCTION
# =============
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# November 11, 2019
# October 04, 2021 -- added .root return.
#
# Calculates the slope, intercept and function (in string form) of a line
# function based on two input points, {.x1, .y1} and {.x2, .y2}.
#
#      y2 - y1
#  a = -------- ,    b = y1  - a * x1
#      x2 - x1
#
# outputs: slope     = myVariable.a
#          intercept = myVariable.b
#          root      = myVariable.root
#          equation  = myVariable.text$
#
# The ouput text is rounded to '.rounding' decimal point, with 'myVariable$'
#
# Example:
# input: @lineFn: "myFunction", 1, 3, 9, 20, 1
# output: myFunction.a = 2.125
#         myFunction.b = 0.875
#         myFunction.text$ = "f(x) = 2.1x + 0.9"
#
# The text output is useful if you want to display the line function on a graph.

procedure lineFn: .ans$, .x1, .y1, .x2, .y2, .rounding
    '.ans$'.a = (.y2 - .y1) / (.x2 - .x1)
    '.ans$'.b = .y1 - '.ans$'.a * .x1
    '.ans$'.root = - '.ans$'.b / '.ans$'.a

    if '.ans$'.a = 0
        .slope$ = ""
    else
        .slope$ = string$(round('.ans$'.a*10^.rounding)/10^.rounding) + "x"
    endif

    if '.ans$'.b = 0 or ('.ans$'.a = 0 and '.ans$'.b > 0)
        .sign$ = ""
    elsif '.ans$'.b > 0
         .sign$ = "+"
    else
         .sign$ = "-"
    endif

    if '.ans$'.b = 0
        .absIntercept$ = ""
    else
        .absIntercept$ = string$(round(abs('.ans$'.b)*10^.rounding)/10^.rounding)
    endif

    '.ans$'.text$ = "f(x) = "

    if '.ans$'.a * '.ans$'.b = undefined
        '.ans$'.text$ += "undefined"
    else
        '.ans$'.text$ += .slope$ + " " + .sign$ + " " + .absIntercept$
    endif
endproc
