# COLOUR CHANGE
# ========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020

# Converts an array of colour vectors into a table for easier manipulation

procedure colArr2Tbl: .size, .vectorVar$
    # Converts an string array of colour vectors ('.vectorVar$'[]) of .size
    # and converts them into a table.

    .table = Create Table with column names:
    ... "colourTable", .size, "vector brightness"
    Append column: "R"
    Append column: "G"
    Append column: "B"
    for .clm to .size
        Set string value: .clm, "vector", '.vectorVar$'[.clm]
        .curVector$ = '.vectorVar$'[.clm]
        .curVector# = '.curVector$'
        Set numeric value: .clm, "brightness", mean(.curVector#)
        Set numeric value: .clm, "R",.curVector#[1]
        Set numeric value: .clm, "G",.curVector#[2]
        Set numeric value: .clm, "B",.curVector#[3]
    endfor
endproc
