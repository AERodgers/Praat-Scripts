# Draws a filled square with a black boarder and very light outline.
# Square width = 0.1 mm * bullet size * pi^0.5
# The pi^0.5 co-efficient maintains area balance between circles of diameter
# of bulletsize and squares

procedure drawSquare: .x, .y, .colour$, .bulletSize
    .x10thmm = Horizontal mm to world coordinates: 0.1
    .y10thmm = Vertical mm to world coordinates: 0.1
    .width = pi^0.5 * .x10thmm * .bulletSize / 2
    .height = pi^0.5 * .y10thmm * .bulletSize / 2
    Paint rectangle:
    ... "{0.9,0.9,0.9}",
    ... .x - .width * 1.05, .x + .width * 1.05,
    ... .y - .height * 1.05, .y + .height * 1.05
    Paint rectangle:
    ... "Black",
    ... .x - .width, .x + .width,
    ... .y - .height, .y + .height
    Paint rectangle:
    ... .colour$,
    ... .x -.width / 1.4, .x + .width / 1.4,
    ... .y - .height / 1.4, .y + .height / 1.4
endproc
