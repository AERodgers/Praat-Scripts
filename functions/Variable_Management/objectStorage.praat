# VARIABLE STORAGE FUNCTIONS
# ==========================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# The two functions here (@hideObjs and @retrieveObjs) allow you to hide a set
# of objects in the objects window and then retrieve them later. This is useful
# if the script pauses for user interaction as it prevents the use from
# accidentally deleting or modifying important objects in your script.
#
# NOTE: you need to initialise the file elsewhere.
#       Basically: writeFileLine: file$, "variable'tab$'value"
#                  appendFileLine: file$, ".varName1$" + tab$ + .varValue1
#                  appendFileLine: file$, ".varName2$" + tab$ + ".varValue2"
#                  appendFileLine: file$, ".varName3$" + tab$ + .varValue3
#                  ... etc.

# The following procedures are also required for the procedures to work:
#     @csvLine2Array
#     @date
#
# @hideVars: .objects$, .dir$, .root$
# ========================
# This procedure take the folowing arguments as input:
#     .objects$ -> a CSV string of variables containing object numbers to be
#                  hidden.
#         .dir$ -> a directary where the objects will be stored temporarily
#        .root$ -> the literal root of some variables which the procedure will
#                  generate to facilitate @retrieveVars
#
# The procedure stores all the objects listed in .objects$ as a binary
# praat collection file in .dir$ with a unique name.
# It then deletes then removes the objects from the objects window.
#
# @retrieveVars: .root$
# =========================
# This procedure retrieves the objects hidden with the reference ".root$".
# It then updates the object variables to their current object window values.

procedure hideObjs: .objects$, .dir$, .root$
    # fix variable name and directory
    .root$ = replace$(.root$, "$", "", 1)

    if !(right$(.dir$) = "/" or right$(.dir$) = "\")
            ... and .dir$ != ""
        .dir$ = .dir$ +  "/"
    endif
    '.root$'Dir$ = .dir$

    @csvLine2Array: .objects$, "hideObjs.numObjects", "hideObjs.varList$"
    @date
    '.root$'$ = string$(date.index) + fixed$(randomUniform (0, 1) * 10e5, 0)
    '.root$'numObjects = .numObjects

    .curObj$ = .varList$[1]
    selectObject: '.curObj$'

    '.root$'objName$[1] =
    ... replace$(
    ... selected$(),
    ... left$(selected$(), index(selected$(), " ")),
    ... "",
    ... 1)
    '.root$'Var$[1] = .varList$[1]
    for .i from 2 to .numObjects
        .curObj$ = .varList$[.i]
        plusObject: '.curObj$'
        '.root$'objName$[.i] = selected$(-1)
        '.root$'Var$[.i] = .varList$[.i]
    endfor
    Save as binary file: .dir$ + '.root$'$ + ".bin"
    Remove
endproc

procedure retrieveObjs: .root$
    Read from file: '.root$'Dir$ + '.root$'$ + ".bin"
    deleteFile: '.root$'Dir$ + '.root$'$ + ".bin"
    for .i to '.root$'numObjects
        .curVar$ = '.root$'Var$[.i]
        '.curVar$' = selected(.i)
    endfor
    for .i to '.root$'numObjects
        .curVar$ = '.root$'Var$[.i]
        selectObject: '.curVar$'
        Rename: '.root$'objName$[.i]
    endfor
endproc
