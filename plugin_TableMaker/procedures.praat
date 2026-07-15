# General Procedures for Table Maker
#
# Written by Antoin Rodgers
# Trinity College Dublin
# antoin dot rodgers at tcd dot ie


## OBJECT PROCESSING
procedure getObject: .objID$, .type$, .sourceProc$
    if fileReadable (.objID$)
        '.sourceProc$'.'.type$' = Read from file: .objID$
    elsif number(.objID$) == round(number(.objID$))
        selectObject: number(.objID$)
        '.sourceProc$'.'.type$' = Copy: "temporaryTable"
    else
        exitScript: "Cannot find valid '.type$':" + newline$ +
        ... .objID$ + newline$
    endif
endproc

## CONVERSION OF NESTED TEXTGRID TO TABLE
procedure tiers2Table:
    ... .textGrid,
    ... .hierarchySSL$,
    ... .output$
    .output$ = replace$(.output$, "$", "", 1)

    # Get array showing order in which to process tiers
    @csvLine2Array: .hierarchySSL$,
    ... "tiers2Table.hierArray_N",
    ... "tiers2Table.hierArray$"

    selectObject: .textGrid
    .numTiers = Get number of tiers

    for .curTier to .numTiers
        # get Tier info
        .tierName$[.curTier] = Get tier name: .curTier
        .curIsIntTier = Is interval tier: .curTier
        .tierCode[.tierName$[.curTier]] = .curTier
        for .i to .hierArray_N
            if .tierName$[.curTier] = .hierArray$[.i]
                .tier[.i] = .curTier
                .isIntTier[.i] = .curIsIntTier
            endif
        endfor
    endfor

    # Create database table with innermost factor in tier hierarchy
    selectObject: .textGrid
    .gridTable = Down to Table: "no", 3, "yes", "no"
    '.output$' = Extract rows where column (text):
        ... "tier",
        ... "is equal to",
        ... .hierArray$[1]
    Rename: .output$
    Remove column: "tier"

    if .isIntTier[1]
        Set column label (label): "tmin", "'.hierArray$[1]'_tmin"
        Set column label (label): "tmax", "'.hierArray$[1]'_tmax"
        .tempIndex = Get column index: "'.hierArray$[1]'_tmax"
        Insert column: .tempIndex, "temp"
        Formula: "temp", "self[""'.hierArray$[1]'_tmin""]"
        Remove column: "'.hierArray$[1]'_tmin"
        Set column label (label): "temp", "'.hierArray$[1]'_tmin"
        .main_tmin$ = "'.hierArray$[1]'_tmin"
        .main_tmax$ = "'.hierArray$[1]'_tmax"
        .newColSt = -1
    else
        Remove column: "tmin"
        Set column label (label): "tmax", "'.hierArray$[1]'_t"
        .main_tmin$ = "'.hierArray$[1]'_t"
        .main_tmax$ = "'.hierArray$[1]'_t"
        .newColSt = 0
    endif
    Set column label (label): "text", .hierArray$[1]

    # create subtable for each tier in hierarchy
    for .i from 2 to .hierArray_N
        .curFactor$ = .hierArray$[.i]

        selectObject: .gridTable
        .tempTable = Extract rows where column (text):
            ... "tier",
            ... "is equal to",
            ... .curFactor$
        Remove column: "tier"

        .curNumRows = Get number of rows
        selectObject: '.output$'
       .curNumCols = Get number of columns
       Insert column: .curNumCols + .newColSt - 1, .curFactor$

        Insert column: .curNumCols + .newColSt, "'.curFactor$'_tmin"
        Insert column: .curNumCols + .newColSt + 1, "'.curFactor$'_tmax"
        for .j to .curNumRows
            selectObject: .tempTable
            .curTmin = Get value: .j, "tmin"
            .curText$ = Get value: .j, "text"
            .curTmax = Get value: .j, "tmax"
            selectObject: '.output$'
            Formula:
            ... .curFactor$,
            ... "if " +
            ...     "self[.main_tmin$] >= .curTmin  and " +
            ...     "self[.main_tmax$] <= .curTmax " +
            ... "then " +
            ...     ".curText$ " +
            ... "else " +
            ...     "self$ " +
            ... "endif"


            Formula:
            ... "'.curFactor$'_tmax",
            ... "if " +
            ...     "self[.main_tmin$] >= .curTmin  and " +
            ...     "self[.main_tmax$] <= .curTmax " +
            ... "then " +
            ...     "self[.main_tmax$] " +
            ... "else " +
            ...     "self$ " +
            ... "endif"


            Formula:
            ... "'.curFactor$'_tmin",
            ... "if " +
            ...     "self[.main_tmin$] >= .curTmin  and " +
            ...     "self[.main_tmax$] <= .curTmax " +
            ... "then " +
            ...     "self[.main_tmin$] " +
            ... "else " +
            ...     "self$ " +
            ... "endif"
        endfor

        selectObject: '.output$'
        if (.curNumRows = 1) or (ui.baseTierTimeOnly)
            Remove column: "'.curFactor$'_tmin"
            Remove column: "'.curFactor$'_tmax"
        elsif .isIntTier[.i]
            Insert column: .curNumCols + .newColSt + 1, "temp"
            Formula: "temp", "self[""'.curFactor$'_tmin""]"
            Remove column: "'.curFactor$'_tmin"
            Set column label (label): "temp", "'.curFactor$'_tmin"
        else
            Remove column: "'.curFactor$'_tmin"
            Set column label (label): "'.curFactor$'_tmax", "'.curFactor$'_t"
        endif
        removeObject: .tempTable
    endfor



    if (ui.vowelDur$ != "") and (ui.formantTier$ != "") and (ui.formants2tabulate)
        selectObject: .gridTable

        .vowelTable = Extract rows where column (text):
        ... "tier",
        ... "is equal to",
        ... ui.vowelDur$

        .num_rows = Get number of rows
        for .i to .num_rows 
            .v_t_min[.i] = Get value: .i, "tmin"
            .v_t_max[.i] = Get value: .i, "tmax"
            .v_t_dur[.i] = number(fixed$((.v_t_max[.i] - .v_t_min[.i]), 3))*1000
        endfor

        .t_name$ = "'.hierArray$[1]'_t"
        selectObject: '.output$'
        Append column: "Vowel.dur"
        for .i to .num_rows 
        Formula: "Vowel.dur",
            ... "if (self[.t_name$] >= .v_t_min[.i]) and " +
            ...    "(self[.t_name$] <= .v_t_max[.i])" +
            ... "then .v_t_dur[.i] " +
            ... "else self " +
            ... "endif"    
        endfor
    removeObject: .vowelTable
    endif

    removeObject: .gridTable
endproc

## FORMANT ESTIMATION
procedure formantsSought:
        ... .sound, .table, .timeCols$, .timeStep,
        ....maxFormantsSought, .maxFormantHz, .numFormants,
        ... .windowLen, .preEmph,
        ... .scale$

    if .timeStep = 0
        .timeStep = .windowLen * 0.25
    endif

    @csvLine2Array: .timeCols$,
                ... "formantsSought.numCols",
                ..."formantsSought.colArray$"
    .firstT$ = .colArray$[1]
    if .numCols = 1
        .lastT$ = .firstT$
    else
        .lastT$ = .colArray$[2]
    endif

    selectObject: .sound
    noprogress To Formant (burg):
    ... .timeStep,
    ... .numFormants,
    ... .maxFormantHz,
    ... .windowLen,
    ... .preEmph
    .formantObj = selected()

    selectObject: .table
    for .f to .maxFormantsSought
        Append column: "F'.f'"
    endfor

    .numRows = Get number of rows
    for .curRow to .numRows
        selectObject: .table
        .startTP = Get value: .curRow, .firstT$
        .endTP = Get value: .curRow, .lastT$

        for .f to .maxFormantsSought
            selectObject: .formantObj

            # Formant extraction must work for both point and interval tiers.
            .curTotTPs = 0
            .curTotF = 0
            .curTP = .startTP
            .keepon = 100
            while .curTP <= .endTP and .keepon
                .curF = Get value at time: .f, .curTP, .scale$, "Linear"
                if .curF != undefined
                    .curTotF += .curF
                    .curTotTPs += 1
                endif
                .curTP += .timeStep
                .keepon -= 1
            endwhile
            if .curF != undefined
                .meanF = .curTotF / .curTotTPs
            else
                .meanF = undefined
            endif

            selectObject: .table
            if .scale$ = "Bark"
                .decPlaces  = 3
            else
                .decPlaces  = 0
            endif
            Set string value: .curRow, "F'.f'", fixed$(.meanF, .decPlaces)
        endfor
    endfor

    removeObject:  .formantObj
endproc

## VARIABLE / PROCEDURE INTITIALISATION
procedure defineVars
    createFolder: preferencesDirectory$ + "/plugin_AERoPlot/data/"
    createFolder: preferencesDirectory$ + "/plugin_AERoPlot/data/vars"

    main.scale$[1] = "Hertz"
    main.scale$[2] = "Bark"
    if !fileReadable(preferencesDirectory$ +
        ... "/plugin_AERoPlot/data/vars/tier2Table.var")
        @initialiseVars: preferencesDirectory$ +
        ... "/plugin_AERoPlot/data/vars/tier2Table.var"
    endif
    @readVars: preferencesDirectory$ +
    ... "/plugin_AERoPlot/data/vars/", "tier2Table.var"
    if main.version$ != main.curVersion$
        @initialiseVars: preferencesDirectory$ +
        ... "/plugin_AERoPlot/data/vars/tier2Table.var"
    endif
    @readVars: preferencesDirectory$ +
    ... "/plugin_AERoPlot/data/vars/", "tier2Table.var"
    @overwriteVars

    if (ui.soundID$ != x_ui.soundID$) or (ui.gridID$ != x_ui.gridID$)
        ui.output$ = ""
        ui.lowestTier$ = ""
        ui.otherTiers$ = ""
    endif

endproc

procedure initialiseVars: .address$
    writeFileLine: .address$, "variable", tab$, "value"
    appendFileLine: .address$, "main.version$", tab$, main.curVersion$
    appendFileLine: .address$, "ui.gridID$", tab$,
    ... preferencesDirectory$ + "/plugin_AERoPlot/example/AER_NI_I.textgrid"
    appendFileLine: .address$, "ui.lowestTier$", tab$, "Comparible.target.int"
    appendFileLine: .address$, "ui.otherTiers$", tab$,
    ... "Speaker,Section,Phenomenon,Broad,Narrow,Comment"
    appendFileLine: .address$, "ui.baseTierTimeOnly", tab$, 1
       appendFileLine: .address$, "ui.output$", tab$, "aer_ni_i"
    appendFileLine: .address$, "ui.soundID$", tab$, preferencesDirectory$ +
    ... "/plugin_AERoPlot/example/AER_NI_I.wav"
    appendFileLine: .address$, "ui.formants2tabulate", tab$, 4
    appendFileLine: .address$, "ui.numFormants", tab$, 5
    appendFileLine: .address$, "ui.formantTier$", tab$, "Vowel.duration"
    appendFileLine: .address$, "ui.vowelDur$", tab$, "5"
    appendFileLine: .address$, "ui.scale", tab$, 1
    appendFileLine: .address$, "ui.timeStep", tab$, 0
    appendFileLine: .address$, "ui.maxFormantHz", tab$, 5000
    appendFileLine: .address$, "ui.windowLen", tab$, 0.025
    appendFileLine: .address$, "ui.preEmph", tab$, 50
    appendFileLine: .address$, "firstPass", tab$, 1
endproc


procedure check4ExampleObjs: .gridID$, .soundID$
    # Set UI menu elements if user has selected example objects.
    selectObject: '.gridID$'
    plusObject: '.soundID$'
    if extractLine$ (selected$(1), " ") = "AER_NI_I" and
        ... extractLine$ (selected$(2), " ") = "AER_NI_I"
        ui.output$ = "aer_ni_i"
        ui.lowestTier$ = "Element"
        ui.otherTiers$ = "Speaker,Sex,Type,Context,Rep,IPA,Segment"
        ui.formants2tabulate = 4

    endif

endproc

# Functions to Check for Dynamic Menu Object Numbers
# NB: These procedure will only work if there is one instance of each object
#     type in the selected objects list.

procedure objsSelected: .types$, .vars$
    # .types$ = csv list of object types
    # .vars$ = csv list of object variables (as string)
    @csvLine2Array:
    ... .types$,
    ... "objsSelected.typeSize",
    ... "objsSelected.typeArray$"
    @csvLine2Array:
    ... .vars$,
    ... "objsSelected.varSize",
    ... "objsSelected.varArray$"


    .curSelected# = selected#()
    .check = size(.curSelected#) == .typeSize

    # populate override array with dummy values
    for .i to .typeSize
        .override$[.i] = ""
    endfor

    if .check
        .check = 0
        for .i to .typeSize
            for .j to .typeSize
                if .typeArray$[.i] = extractWord$(selected$(.j), "")
                    .override$[.i] = string$(selected(.j))
                    .check = 1
                endif
            endfor
        endfor
    endif
endproc

procedure overwriteVars
    .sameSelection = 1
    #check that @objsSelected has been run already.
    if variableExists("objsSelected.check")
        .all = objsSelected.check
        for .i to objsSelected.typeSize * objsSelected.check
            if objsSelected.override$[.i] != ""
                .curVar$ = objsSelected.varArray$ [.i]
                .sameSelection = .sameSelection * ('.curVar$' == x_'.curVar$')
                '.curVar$' = objsSelected.override$[.i]
            else
                .all = 0
            endif
        endfor
    else
        .all = 0
    endif

    if (.all and firstPass) or !.sameSelection
        title$ = ""
        oFactor$ = ""
        iFactor$ = ""
    endif
endproc

procedure isExampleTable: .tableID$, .oFactorName$, .iFactorName$
    # Set UI menu elements if user has selected example objects.
    selectObject: '.tableID$'
    .true = extractLine$ (selected$(1), " ") == "aer_ni_i"
    if .true
        oFactor$ =.oFactorName$
        iFactor$ = .iFactorName$
        title$ = "Example nIE vowel and dipthongs"
    endif
endproc

# General Functions 
procedure checkPraatVersion
    .version$ = praatVersion$
    if number(left$(.version$, 1)) < 6
        echo You are running Praat 'praatVersion$'.
        ... 'newline$'This script runs on Praat version 6.0.60 or later.
        ... 'newline$'To run this script, update to the latest
        ... version at praat.org
        exit
    endif
endproc

# file and variable handling
procedure csvLine2Array: .csvLine$, .size$, .array$
    # correct variable name Strings
    .size$ = replace$(.size$, "$", "", 0)
    if right$(.array$, 1) != "$"
        .array$ += "$"
    endif
    # fix input csvLine array
    .csvLine$ = replace$(.csvLine$, ", ", ",", 0)
    while index(.csvLine$, "  ")
        .csvLine$ = replace$(.csvLine$, "  ", " ", 0)
    endwhile
    .csvLine$ = replace_regex$ (.csvLine$, "^[ \t\r\n]+|[ \t\r\n]+$", "", 0)
    .csvLine$ += ","
    # generate output array
    '.size$' = 0
    while length(.csvLine$) > 0
        '.size$' += 1
        .nextElementEnds = index(.csvLine$, ",")
        '.array$'['.size$'] = left$(.csvLine$, .nextElementEnds)
        .csvLine$ = replace$(.csvLine$, '.array$'['.size$'], "", 1)
        '.array$'['.size$'] = replace$('.array$'['.size$'], ",", "", 1)
        if '.array$'['.size$'] = "" or '.array$'['.size$'] = "?"
            '.size$' -= 1
        endif
    endwhile
endproc

procedure vector2Str: .vectorVar$
    # converts a vector to a string with the same variable where # --> $

    .stringVar$ = replace$(.vectorVar$, "#", "$", 0)
    .vector# = '.vectorVar$'
    '.stringVar$' = "{"
    for .i to size(.vector#)
        '.stringVar$' += string$(.vector#[.i]) + ","
    endfor
    '.stringVar$' = left$('.stringVar$', length('.stringVar$') - 1) + "}"
endproc

procedure purgeDirFiles: .dir$
    # check .dir$
    if (right$(.dir$) != "/" or right$(.dir$) != "\") and .dir$ != ""
        .dir$ = .dir$ + "/"
    endif

    # purge temporary file
    temp = Create Strings as file list: "purgeList", .dir$
    numStr = Get number of strings
    for i to numStr
        curStr$ = Get string: i
        deleteFile: "'.dir$''curStr$'"
    endfor
    Remove
endproc

# Data Storage and retrieval functionsL
    # - Accepts scalar, string, vector, and matrix variables.
    # - stores variables in a TSV file with the headers "variable" and "value"
procedure readVars: .dir$, .file$
    # reads list of variables from TSV .file$ (headers, "variable, "value")
    .vars = Read Table from tab-separated file: "'.dir$''.file$'"
    .prefix$ = left$(.file$, rindex(.file$, ".") - 1)
    '.prefix$'NumVars = Get number of rows
    for .i to '.prefix$'NumVars
        '.prefix$'Var$[.i] = Get value: .i, "variable"
        .curVar$ = '.prefix$'Var$[.i]
        .curValue$ = Get value: .i, "value"
        if .curValue$ = "?"
            .curValue$ = ""
        endif
        if right$(.curVar$, 1) = "]"
            # extract array
            .leftBracket = index(.curVar$, "[")
            .curArray$ = left$(.curVar$, .leftBracket - 1)
            .index$ = mid$(
            ... .curVar$,
            ... .leftBracket + 1,
            ... length(.curVar$) - .leftBracket - 1
            ... )
            .curVar$ = .curArray$ + "[" + .index$ + "]"
            if right$(.curArray$, 1) = "$"
                # cope with string array value
                '.curVar$' = .curValue$
            else
                # cope with number array value
                '.curVar$' = number(.curValue$)
            endif
        elsif right$(.curVar$, 1) = "$"
            # extract string
            '.curVar$' = .curValue$
        elsif right$(.curVar$, 1) = "#"
            # extract vector
            '.curVar$' = '.curValue$'
        else
            # extract number
            '.curVar$' = number(.curValue$)
        endif
        x_'.curVar$' = '.curVar$'
    endfor
    Remove
endproc

# Data Storage and retrieval functionsL
    # - Accepts scalar, string, vector, and matrix variables.
    # - stores variables in a TSV file with the headers "variable" and "value"

procedure writeVars: .dir$, .file$
    # Writes list of variables to TSV .file$ (headers, "variable, "value")

    if variableExists("sorting")
        sorting = 1
    endif
    if variableExists("changeAddColSch")
        changeAddColSch = 0
    endif
    .prefix$ = left$(.file$, rindex(.file$, ".") - 1)
    .vars = Read Table from tab-separated file: .dir$ + .file$
    for i to '.prefix$'NumVars
        .curVar$ = '.prefix$'Var$[i]
        if right$(.curVar$, 1) = "$"
            # set string or string array value
            Set string value: i, "value", '.curVar$'
        elsif right$(.curVar$, 1) = "#"
            # set vector
            @vector2Str: .curVar$
            .curVar$ = replace$(.curVar$, "#", "$", 1)
            Set string value: i, "value", '.curVar$'
        else
            # set number or numeric array value
            Set numeric value: i, "value", '.curVar$'
        endif
    endfor
    Save as tab-separated file: "'.dir$''.file$'"
    Remove
endproc

# select table before exiting
procedure selectTableID
    if variableExists("tableID$")
        if string$(number(tableID$)) = tableID$
            selectObject: 'tableID$'
        endif
    endif
endproc