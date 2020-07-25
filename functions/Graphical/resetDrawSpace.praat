# Reset Draw Space
# ================
# Written for Praat 6.1.08

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020
#
# A short procedure to return draw space (excluding view port)
# to a default state with font size = .fontSize

procedure resetDrawSpace: .fontSize
    Erase all
    Font size: .fontSize
    Line width: 1
    Colour: "Black"
    Solid line
    Helvetica
endproc
