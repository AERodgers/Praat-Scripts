# CONVERT PITCH OBECT TO TABLE
# ============================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# Converts '.pitchobject' to table 'pitch2Table.table' with columns "Frame",
# "Time", and "F0"
# If '.interpolate' = 0 then pitch is not interpolated

procedure pitch2Table: .pitchObject, .interpolate
    selectObject: .pitchObject
    .originalObject = .pitchObject
    if .interpolate
        .pitchObject = Interpolate
    endif

    # Get key pitch data
    .frameTimeFirst = Get time from frame number: 1
    .timeStep = Get time step

    #create pitch Table (remove temp objects)
    noprogress Down to PitchTier
    .pitchTier = selected()
    .tableofReal = Down to TableOfReal: "Hertz"
    noprogress To Table: "rowLabel"
    .pitchTable = selected()
    selectObject: .pitchTier
    plusObject: .tableofReal
    Remove

    # Get key pitchTable data
    selectObject: .pitchTable
    .rows = Get number of rows
    .rowTimeFirst = Get value: 1, "Time"

    # estimate frame of first row
    Set column label (index): 1, "Frame"
    for .n to .rows
        .rowTimeN = Get value: .n, "Time"
        .tableFrameN = round((.rowTimeN - .frameTimeFirst) / .timeStep + 1)
        Set numeric value: .n, "Frame", .tableFrameN
    endfor

    # removeInterpolated pitch
    if  .originalObject != .pitchObject
        selectObject: .pitchObject
        Remove
    endif
    .table = .pitchTable
endproc
