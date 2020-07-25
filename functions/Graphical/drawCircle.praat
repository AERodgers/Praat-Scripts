#
# Draws a filled circle with a black boarder and very light outline.
# Circle radius = 0.1 mm * bullet size

procedure drawCircle: .x, .y, .colour$, .bulletSize
    .x10thmm = Horizontal mm to world coordinates: 0.1
    .radius = abs(.x10thmm * .bulletSize)
    Paint circle: "{0.9,0.9,0.9}", .x, .y, .radius * 1.05
    Paint circle: "Black", .x, .y, .radius
    Paint circle: .colour$, .x, .y, .radius / 1.4
endproc
