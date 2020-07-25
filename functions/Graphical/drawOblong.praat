# DRAW OBLONG
# ===========
# Written for Praat 6.0.40
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020

# Draws an oblong with a filled colour and optional (black) cross-hatching
#
# .x, .y     : plot co-ordinates for centre of oblong.
# .width     : width of oblong in 10ths of millimetres
# .height    : height of oblong in 10ths of millimetres
# .colour$   : string name or vector of fill colour
# .lines     : type of cross-hatching:
#                   0 = none
#                   1 = upward-right diagonal lines
#                   2 = vertical lines
#                   3 = criss-cross diagonal lines
#                   4 = downward-right diagonal lines
#                   5 = criss-cross horizontal and vertical lines
#                   6 = horizontal lines
#                   7 = criss-cross diagonal lines with vertical lines
#                   8 = criss-cross diagonal, vertical, and horizontal lines
# .scarcity  : perpendicular space between each line in 10ths of millimetres
# .lineWidth : width of crosshatching lines re Praat "Line width" parameter

procedure drawOblong: .x, .y, .width, .height,
    ... .colour$, .lines, .scarcity, .lineWidth
    # draws an oblong with optional cross hatching
    .x10thmm = Horizontal mm to world coordinates: 0.1
    .y10thmm = Vertical mm to world coordinates: 0.1
    .width =  .width * .x10thmm
    .height = .height * .y10thmm

    Paint rectangle: "{0.9,0.9,0.9}",
    ... .x - (.width + .x10thmm * 2), .x + (.width + .x10thmm * 2),
    ... .y - (.height + .y10thmm * 2), .y + (.height + .y10thmm * 2)
    Paint rectangle:
    ...  "Black",
    ... .x - .width, .x + .width,
    ... .y - .height, .y + .height
    Paint rectangle:
    ... .colour$,
    ... .x - (.width - .x10thmm * 5), .x + (.width - .x10thmm * 5),
    ... .y - (.height - .y10thmm * 5), .y + (.height - .y10thmm * 5)

    # draw inner lines
    .yLength = (.height - .y10thmm * 5)
    .xLength = Vertical world coordinates to mm: .yLength
    .xLength = Horizontal mm to world coordinates: .xLength
    .xLength = abs(.xLength * 2)
    .yLength = abs(.yLength * 2)
    .xMin = .x - (.width - .x10thmm * 5)
    .xMax = .x + (.width - .x10thmm * 5)
    .yMin = .y - (.height - .y10thmm * 5)
    .yMax = .y + (.height - .y10thmm * 5)

    Line width: .lineWidth
    Colour: '.colour$' * 0.0

    # DOWN-LEFTWARD DIAGONAL LINES
    if .lines = 1 or .lines = 3 or .lines = 7 or .lines = 8
        .xStart = .xMin
        .yStart = .yMax
        .xEnd = .xStart - .xLength
        while .yStart > .yMin and .xEnd < .xMax
            .yStart = .yMax
            .yEnd = .yMin
            if .xEnd <= .xMin
                .xEnd = .xMin
                .yStart = .yMax
                .yEnd = .yMax + .yLength * (.xEnd - .xStart) / .xLength
            endif
            if .xStart >= .xMax
                .xStart = .xMax
                .yStart = .yMin - .yLength * (.xEnd - .xStart) / .xLength
                .yEnd = .yMin
            endif
            Draw line:
            ... .xStart, .yStart,
            ... .xEnd, .yEnd
            if .xStart < .xMax
                .xStart += .x10thmm * .scarcity * 2^0.5
                .xEnd = .xStart - .xLength
            else
                .xEnd += .x10thmm * .scarcity * 2^0.5
                .xStart = .xStart + .xLength
            endif
        endwhile
    endif

    # DOWN-RIGHTWARD DIAGONAL LINES
    if .lines = 3 or .lines = 4 or .lines = 7 or .lines = 8
        .xStart = .xMax
        .yStart = .yMax
        .xEnd = .xStart + .xLength
        while .yStart > .yMin and .xEnd > .xMin
            .yStart = .yMax
            .yEnd = .yMin
            if .xEnd >= .xMax
                .xEnd = .xMax
                .yStart = .yMax
                .yEnd = .yMax - .yLength * (.xEnd - .xStart) / .xLength
            endif
            if .xStart <= .xMin
                .xStart = .xMin
                .yStart = .yMin + .yLength * (.xEnd - .xStart) / .xLength
                .yEnd = .yMin
            endif
            Draw line:
            ... .xStart, .yStart,
            ... .xEnd, .yEnd
            if .xStart > .xMin
                .xStart -= .x10thmm * .scarcity * 2^0.5
                .xEnd = .xStart + .xLength
            else
                .xEnd -= .x10thmm * .scarcity * 2^0.5
                .xStart = .xEnd - .xLength
            endif
        endwhile
    endif

    # VERTICAL LINES
    if .lines = 2 or .lines = 5 or .lines = 7 or .lines = 8
        .curX = .xMin
        while .curX < .xMax
            Draw line: .curX, .yMax, .curX, .yMin
            .curX += .x10thmm * .scarcity
        endwhile
    endif

    # HORIZONTAL LINES
    if .lines = 5 or .lines = 6 or .lines = 8
        .curY = .yMin
        while .curY <= .yMax
            Draw line: .xMin, .curY, .xMax, .curY
            .curY += .y10thmm * .scarcity
        endwhile
    endif
endproc
