# DOUBLE INTEGRAL OF A DISCRETE CONTOUR
# =========================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# October 10 - December 18, 2019

# Calculates the double integral of a discrete contour. Assuming the input is
# the second derivative of an original discrete contour, and the output is its
# double integral, the function can be defined as:
#
#    N
#  ------
#  \         /   \      2       /     \        /     \       /      \
#   |     f | x   | = dx  * f" | x     | + 2f | x     | - f | x      |
#  /         \ n /              \ n-1 /        \ n-1 /       \  n-2 /
#  ------
#   n = 1
#
# NB 1: Undefined values are set to 0 and n[0]=0 and [-1]=0 are effectively
#       added to the beginning of the array to generate value from n[1] to n[N]
# NB 2: If @secondDerivative has not been run, make .i_fx = 0, .i_dydx = 0
#

procedure doubleIntegral: .table, .x$, .y$, .sum$, .i_fx, .i_dydx
    selectObject: .table
    .x1 = Get value: 1, .x$
    .x2 = Get value: 2, .x$
	.dx = .x2 - .x1
    Insert row: 1
    Insert row: 1
    Append column: "TempY"
    Formula: "TempY", "(if self[.y$] = undefined then 0 else self[.y$] endif)"

    #add .sum$ if necessary and set all values to 0

    .sumExists = Get column index: .sum$
    if not .sumExists
        Append column: .sum$
    endif
    Formula: .sum$, "0"

    .numRows = Get number of rows
    for  .i from 3 to numRows
        .yMin1 = Get value: .i-1, "TempY"
        .sumMin1 = Get value: .i-1, .sum$
        .sumMin2 = Get value: .i-2, .sum$
        Set numeric value: .i, .sum$, .dx^2 * .yMin1 + 2 * .sumMin1  - .sumMin2
    endfor
    Remove row: 1
    Remove row: 1
    Remove column: "TempY"
	.numRows = Get number of rows
    # reintroduce interfecto of f(x) and f'(x)
	Formula: .sum$, "self + .i_fx + (.i_dydx) * (self[.x$]-(.x1))"
endproc
