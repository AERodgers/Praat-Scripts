# SECOND DERIVATIVE OF A DISCRETE CONTOUR
# =========================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# October 10 - December 18, 2019

# Calculates the second time derivative of a discrete contour in columns
# .x$ and .y$ of .table$. .d2ydx2Col$ is the name of the output column.
#
#   N - 1
#  ------
#  \      d2y     1     /                    \
#   |     ---  = --- * |  y     + y    - 2y   | ,   n  = NaN , n  = NaN
#  /      dx^2   dx^2   \  n+1     n-1     n /       1          N
#  ------
#   n = 2
#
# NB 1: 1st and last rows columns will be undefined
# NB 2: procedure stores the intercept of f(x) and f'(x) in the variables
#       'secondDerivative.i_fx' and 'secondDerivative.i_dydx' respectively.
#       If these are used in the procedure @doubleIntegral with
#       .y$ = .d2ydx2Col$ of this procedure, it will return the orginal contour.
#
#       (This functionality may seem slightly odd, but it was implemented with
#       the idea of using the second derivative as a means of smoothing the
#       original contour, in which case it would be useful to know the
#       intercepts of the original contour and its first derivative)


procedure secondDerivative: .table, .x$, .y$, .d2ydx2Col$
    selectObject: .table
    .x1 = Get value: 1, .x$
    .x2 = Get value: 2, .x$
	.dx = .x2 - .x1

    # calculate intercepts of f(x) and f'(x)
    selectObject: .table
    .i_fx = Get value: 1, .y$
    .y2 = Get value: 2, .y$
    .i_dydx =  (.y2 - .i_fx) /( .dx)

    selectObject: .table
    Append row
    Insert row: 1
    .y0$ = .y$ + "0"
    .y2$ = .y$ + "2"
    Append column: .y0$
    Append column: .y2$

    .d2ydx2Exists = Get column index: .d2ydx2Col$
    if not .d2ydx2Exists
        Append column: .d2ydx2Col$
    endif
    numRows = Get number of rows
    for  .i from 2 to numRows - 1
        .curY = Get value: .i, .y$
        Set numeric value: .i + 1, .y0$ , .curY
        Set numeric value: .i - 1, .y2$ , .curY
    endfor
    Remove row: 1
    Remove row: numRows - 1
    Formula: .d2ydx2Col$, "(self[.y0$] + self[.y2$] - 2 * self[.y$]) / .dx ^ 2"
    Remove column: .y0$
    Remove column: .y2$
endproc
