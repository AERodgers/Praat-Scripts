# VARIABLE STORAGE FUNCTIONS
# ==========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# The two functions here (@readVars and @writeVars) allow you to read and
# write a set of variable used in a script. This is useful if the script has
# menus and you want the script to recall the variables between sessions.
# The script can cope with numeric variables, strings, string and numeric
# vectors and matrices, and arrays - but it's not very good with arrays!
#
# NOTE: you need to initialise the file elsewhere.
#       Basically: writeFileLine: file$, "variable'tab$'value"
#                  appendFileLine: file$, ".varName1$" + tab$ + .varValue1
#                  appendFileLine: file$, ".varName2$" + tab$ + ".varValue2"
#                  appendFileLine: file$, ".varName3$" + tab$ + .varValue3
#                  ... etc.

# Dependency:
# @vector2Str -->  required for the procedures to work properly.

procedure readVars: .dir$, .file$
    # Reads list of variables from TSV .file$ (headers, "variable, "value")
    #
    # Reads the table of variables found in '.dir$.''file$' and declares a set
    # of variables from it. It takes the following arguments:
    #
    #     .dir$  -> directory of file (include "/" at end if necessary)
    #     .file$ -> file name of variables table.
    #               NOTE: File name must begin with a lowercase letter.
    #
    # It also creates a copy of each variable prefixed with "x_". This allows
    # you to compare the current state of each variable with its state when it
    # was declared.
    #
    # Finally, it creates two variables for use in writeVars: each one is pre-
    # fixed with the filename (excluding filename extensions) plus "Var$[n]"
    # and "NumVars".

    .vars = Read Table from tab-separated file: "'.dir$''.file$'"
    .prefix$ = left$(.file$, rindex(.file$, ".") - 1)
    '.prefix$'NumVars = Get number of rows
    for .i to '.prefix$'NumVars
        '.prefix$'Var$[.i] = Get value: .i, "variable"
        .curVar$ = '.prefix$'Var$[.i]
        .curValue$ = Get value: .i, "value"
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

procedure writeVars: .dir$, .file$
    # Writes list of variables to TSV .file$ (headers, "variable, "value").
    #
    # Writes the variables read in from @readVars back to the original file.

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
