# LEGEND 2.1
# ==========
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# This is a vastly improved and more flexible pair of legend procedures
# than the original.

# The following procedures are required for @drawLegendLayer to work.
#     @csvLine2Array
#     @modifyColVectr
#     @drawOblong

# @legend
# =======
# This is now a callable function to which you can add legend elements.
#
# It takes the following arguments:
#     .addStyle$  : "L"   = A line
#                   "R"   = Rectangle with solid block of colour
#                   "0-8" = oblong with cross hatching
#                          (See "drawOblong.praat" for details)
#     .addColour$ : Colour of legend item as a string name or string vector
#     .addText$   : Text for legend item
#     .addSize    : Size of legend object (line width or oblong in 10ths #                   of millimetres)

# @drawLegendLayer
# ================
# This will find a corner of the plot interior where the legend will cover the
# least proportion (.threshold) of data points. If the .compromise flag is set
# to 0 and the .threshold is exceeded, the legend will not be drawn. However,
# of .compromise is set to 1, it will draw the legend in the outer corner of
# the legend which is least likely to have text and where the legend will
# cover the smallest number of data points in the plot interier.
#
# The procedure takes the following arguments:
#     .xLeft      \
#     .xRight      | values at edge of plot interior. (NOTE: not min and
#     .yBottom     | max, but left, right, top, and bottom.)
#     .yTop       /
#     .fontSize   -> font size
#     .viewPort$  -> string of inner viewport parameters
#     .xyTable    -> name of table containing plot data
#     .xCol$      -> CSV strings of table headers containing x-axis and y-axis
#     .yCol$      -> plot data
#     .threshold  -> proportion (0-1) of data points which can be hidden by the
#                    legend. If the proportion the legend will not be drawn.
#                    (See compromise below.)
#     .bufferZone -> size of buffer zone (in mm) around the legend.
#                    The buffer zone is used in calculating the threshold.
#     .compromise -> 0 or 1 - If ".compromise" is set to 1, a legend will be
#                    drawn outside the plot interior in such a way as to
#                    minimise the likelihood of it covering data points,
#                    the title, or axis text. Results may not be reliable.
#     .innerChange \ Parameters which darker (-) or lighten (+) the fill colour
#     .frameChange | and border colour of rectangles. Set to 0 to ignore them.
#                  / (Not sure why I added these TBH.)

procedure legend: .addStyle$, .addColour$, .addText$, .addSize
    if variableExists ("legend.items")
        .items += 1
    else
        .items = 1
    endif
    .style$[.items] =  .addStyle$
    .colour$[.items] = .addColour$
    .text$[.items] = .addText$
    .size[.items] = .addSize
endproc

procedure drawLegendLayer: .xLeft, .xRight, .yBottom, .yTop,
                       ... .fontSize, .viewPort$,
                       ... .xyTable, .xCol$, .yCol$,
                       ... .threshold, .bufferZone, .compromise
                       ... .innerChange, .frameChange
   # @drawLegendLayer v.3.0 - copes with CSV string of x and ycols, is much
   # better optimised for chosing an appropriate draw space, and has several
   # new legend shape options.

    @csvLine2Array: .yCol$, "drawLegendLayer.yCols", "drawLegendLayer.yCols$"
    @csvLine2Array: .xCol$, "drawLegendLayer.xCols", "drawLegendLayer.xCols$"

    Line width: 1
    Font size: .fontSize
    Solid line
    Colour: "Black"
    Select inner viewport: '.viewPort$'

    if .xLeft < .xRight
        .horDir$ = "rising"
    else
        .horDir$ = "falling"
    endif
    if .yBottom < .yTop
        .vertDir$ = "rising"
    else
        .vertDir$ = "falling"
    endif

    # calculate legend width
    .legendWidth = 0
    .legendWidth$ = ""
    for .i to legend.items
        .len = length(legend.text$[.i])
        if .len > .legendWidth
            .legendWidth = .len
            .legendWidth$ =  legend.text$[.i]
        endif
    endfor

    # calculate box dimensions
    Axes: .xLeft, .xRight, .yBottom, .yTop
    .text_width = Text width (world coordinates): .legendWidth$
    .sign = (((.xLeft > .xRight) == (.yBottom < .yTop)) - 0.5) * 2
    .x_unit = Text width (world coordinates): "W"
    .x_start = .xLeft + .x_unit * 0.25
    .x_width = 3.5 * .x_unit + .text_width
    .x_end = .xLeft + .x_width
    .x_buffer = Horizontal mm to world coordinates: .bufferZone
    .y_unit = Text width (world coordinates): "W"
    .y_unit = Horizontal world coordinates to mm: .y_unit
    .y_unit = Vertical mm to world coordinates: .y_unit
    .y_unit = .y_unit
    .y_start = .yBottom + .y_unit * 0.25
    .y_height = .y_unit * (legend.items + 0.6)
    .y_end = .yBottom + .y_height
    .y_buffer  = Vertical mm to world coordinates: .bufferZone

    # calculate  .hor, .vert, (hor = 0 = left; vert = 0 = bottom)
    # Get stats for coordinates
    .horS[1] = .x_start
    .horE[1] = .x_end
    .horS[2] = .xRight - .x_width
    .horE[2] = .xRight - .x_unit * 0.25
    .vertS[1] = .y_start
    .vertE[1] = .y_end
    .vertS[2] = .yTop - .y_height
    .vertE[2] = .yTop - .y_unit * 0.25

    .inZone## = {{0, 0}, {0, 0}}
    selectObject: .xyTable
    .numRows = Get number of rows
    .total = .numRows * .xCols * .yCols

    for .curXCol to .xCols
        .curXCol$ = .xCols$[.curXCol]
        for .curYCol to .yCols
            .curYCol$ = .yCols$[.curYCol]
            for .lr to 2
                for .bt to 2
                    for .i to .numRows
                        .curX = Get value: .i, .curXCol$
                        .curY = Get value: .i, .curYCol$
                        if .horDir$  ="rising"
                            .insideHor = .curX >= .horS[.lr] - .x_buffer and
                            ... .curX <= .horE[.lr] + .x_buffer
                        else
                            .insideHor = .curX <= .horS[.lr] - .x_buffer and
                            ... .curX >= .horE[.lr] + .x_buffer
                        endif
                        if .vertDir$  ="rising"
                            .insideVert = .curY >= .vertS[.bt] - .y_buffer and
                            ... .curY <= .vertE[.bt] + .y_buffer
                        else
                            .insideVert = .curY <= .vertS[.bt] - .y_buffer and
                            ... .curY >= .vertE[.bt] + .y_buffer
                        endif
                        if .insideVert and .insideHor
                            .inZone##[.bt, .lr] = .inZone##[.bt, .lr] + 1
                        endif
                    endfor

                endfor
            endfor
        endfor
    endfor

    .least# = {0,0}
    .least = 10^10
    for .lr to 2
        for .bt to 2
            if .inZone##[.bt, .lr] < .least
                .least = .inZone##[.bt, .lr]
                .least# = {.lr, .bt}
            endif
        endfor
    endfor

    # adjust coordinates to match horizontal and vertical alignment
    .x_end = .horE[.least#[1]]
    .x_start = .horS[.least#[1]]
    .y_start = .vertS[.least#[2]]
    .y_end = .vertE[.least#[2]]
     if .least / .total > .threshold
        Axes: .xLeft, .xRight, .yBottom, .yTop
        .outerX = Horizontal mm to world coordinates: .fontSize * 1.25
        .outerY = Vertical mm to world coordinates: .fontSize * 0.75

        if .xRight > .xLeft
            .x_end = .xRight + .outerX
            .x_start = .x_end - .x_width
        else
            .x_start = .xLeft - .outerX
            .x_end = .x_start + .x_width
        endif

        if .yTop > .yBottom
            .y_end = .yTop + .outerY / 2
            .y_start = .y_end - .y_height
        else
            .y_start = .yBottom - .outerY
            .y_end = .y_start + .y_height
        endif
     endif

    # Draw main legend only if percentage of data points hidden < threshold
    # or .compromise flag is set
    if .least / .total <= .threshold or .compromise
        ### Draw box and frame
        Paint rectangle:
        ... 0.9,
        ....x_start, .x_end,
        ... .y_start,  .y_end
        Colour: "Black"
        Draw rectangle:
        ... .x_start, .x_end,
        ... .y_start,  .y_end

        # Draw Text Lines and icons
        for .order to legend.items
            .i = legend.items - .order + 1
            .i = .order

            Font size: .fontSize
            Colour: "Black"
            nowarn Text:
            ... .x_start + 2.5 * .x_unit, "Left", .y_end - .y_unit * (.i - 0.3),
            ... "Half", "##" + legend.text$[.i]
            Helvetica

            if left$(legend.style$[.i], 1) =
                ... "L" or left$(legend.style$[.i], 1) = "l"
                Line width: legend.size[.i] + 2
                Colour: "White"
                Draw line:
                ... .x_start + 0.5 * .x_unit, .y_end  - .y_unit * (.i - 0.3),
                ... .x_start + 2 * .x_unit, .y_end  - .y_unit * (.i - 0.3)
                Line width: legend.size[.i]
                Colour: legend.colour$[.i]
                Draw line:
                ... .x_start + 0.5 * .x_unit, .y_end  - .y_unit * (.i - 0.3),
                ... .x_start + 2 * .x_unit, .y_end  - .y_unit * (.i - 0.3)
            elsif left$(legend.style$[.i], 1) =
                    ... "R" or left$(legend.style$[.i], 1) = "r"
                Line width: legend.size[.i]
                @modifyColVectr: legend.colour$[.i],
                ... "drawLegendLayer.innerColour$",
                ... "+ drawLegendLayer.innerChange"
                @modifyColVectr: legend.colour$[.i],
                ... "drawLegendLayer.frameColour$",
                ... "+ drawLegendLayer.frameChange"
                Colour: .innerColour$
                Paint rectangle: .innerColour$,
                ... .x_start + 0.5 * .x_unit,
                ... .x_start + 2 * .x_unit,
                ... .y_end  - .y_unit * (.i - 0.3) + .y_unit / 3,
                ... .y_end  - .y_unit * (.i - 0.3) - .y_unit / 3
                Line width: legend.size[.i]
                Colour: .frameColour$
                Draw rectangle:
                ... .x_start + 0.5 * .x_unit,
                ... .x_start + 2 * .x_unit,
                ... .y_end  - .y_unit * (.i - 0.3) + .y_unit / 3,
                ... .y_end  - .y_unit * (.i - 0.3) - .y_unit / 3
            elsif number(legend.style$[.i]) != undefined
                Line width: legend.size[.i]
                .lineType = number(left$(legend.style$[.i], 1))
                .scarcity = number(mid$(legend.style$[.i], 2, 1))
                .lineWidth = number(right$(legend.style$[.i], 1))
                if variableExists("bulletSize")
                    .obWidth = pi^0.5 * bulletSize / 1.1
                    .obHeight = pi^0.5 * bulletSize / 4
                else
                    .obWidth = legend.size[.i] * 2
                    .obHeight = legend.size[.i]
                endif
                @drawOblong:
                ... .x_start + 1.25 * .x_unit, .y_end  - .y_unit * (.i - 0.3),
                ... .obWidth, .obHeight,
                ... legend.colour$[.i], .lineType, .scarcity, .lineWidth
            else
                .temp = Create Table with column names:
                ... "table", 1, "X Y Mrk Xs Ys"
                .xS = Horizontal mm to world coordinates: 0.2
                .yS = Vertical mm to world coordinates: 0.2
                Set numeric value: 1, "X", .x_start + 1.25 * .x_unit
                Set numeric value: 1, "Y", .y_end  - .y_unit * (.i - 0.3)
                Set numeric value: 1, "Xs", .x_start + 1.25 * .x_unit + .xS
                Set numeric value: 1, "Ys" , .y_end - .y_unit * (.i - 0.3) - .yS
                Set string value: 1, "Mrk", legend.style$[.i]
                Line width: 4
                Colour: legend.colour$[.i]
                nowarn Scatter plot (mark):
                ... "X", .xLeft, .xRight, "Y",
                ... .yBottom, .yTop, 2,
                ... "no", "left$(legend.style$[.i], 1)"
                Remove
            endif
        endfor
    endif
    # purge legend.items
    legend.items = 0
endproc
