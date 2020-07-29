# GET LOCATION
# ============
# Written for Praat 6.1.08
#
# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020
#
# A pair of scripts (@getLoc and @find) with a user interface to locate any
# specified file on the local computer (Windows only for now).
#
# Required fuctions: @line2Array
#
# Input arguments:
#     .dir$      -> directory for storing and retrieving data files.
#     .file$     -> filename (include extensions)
#     .update    -> a flag (0, 1) stating if the r.version needs updating
#     .moreArgs$ -> not yet implemented; input as ""
#
# Output:
#     * [.dir$]/[.file$].version -> data file with path to .file$
#     * find.loc$                -> string containing path to .file$
#
#
#  To do:
#   .moreArgs$  -> This wil be able to contain a string of input arguments to
#                  replace the UI. If the string is empty or invalid, it will
#                  run the UI menus instead.
#   Other       -> as this script runs OS command lines, it needs slightly
#   Operating      different _CMD$ strings for each OS. Currently, the script
#   Systems        only works with Windows and will return a warning if run from
#                  MacOS or Linux.
#
#
# ~ Sample script (remove # symbols): ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   tempDir$ = ""
#   @getLoc: tempDir$, "R.exe", 1, ""
#   if find.loc$ = ""
#       exitScript:
#       ... """R.exe"" not found on the drive(s) selected. " + newline$ +
#       ... "Search again on a different drive or visit: " + newline$ +
#       ... "https://www.r-project.org/." + newline$
#   else
#       writeInfoLine: "Running: ", find.loc$
#   endif
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure getLoc: .dir$, .file$, .update
    # correct last character of .dir$
    if (right$(.dir$) != "/" or right$(.dir$) != "\") and
        ... .dir$ != ""
        .dir$ = .dir$ + "/"
    endif

    # see if path file exists already
    if fileReadable("'.dir$''.file$'.path")
        Read Strings from raw text file: "'.dir$''.file$'.path"
        find.loc$ = Get string: 1
        Remove
    endif
    # Try to find the file if there is no path file or the an update is sought.
    if !variableExists("find.loc$") or .update
        @find: .dir$, .file$
        if find.loc$ != ""
            writeFileLine: "'.dir$''.file$'.path", find.loc$
        endif
    endif
endproc

procedure find: .dir$, .file$

    # Get an array of the drives available on the local disk
    .tempFile$ = "drives.tmp"
    if windows
    .listDrives_CMD$ = "fsutil fsinfo drives > '.dir$''.tempFile$'"
    elsif macintosh
        exitScript: "Currently, @getLoc does not work on MacOS."
    else
        exitScript: "Currently, @getLoc does not work on a Unix OS."
    endif
    runSystem: .listDrives_CMD$
    .drives = Read Strings from raw text file: "'.dir$''.tempFile$'"
    .drives$ = Get string: 2
    deleteFile: "'.dir$''.tempFile$'"
    removeObject: .drives
    .drives$ = replace$(.drives$, "Drives: ", "", 1)
    @line2Array: .drives$, " ", "find.drives$"

    # if there is more than one drive, ask user to select drive(s) to search.
    if .drives_N > 1
        .done = 0
        while not .done
            beginPause: "Looking for ""'.file$'""..."
                comment: "Location of ""'.file$'"" is unknown. " +
                ... "Please choose which drive(s) to search:"
                for .i to .drives_N
                    .letter$[.i] = replace$(.drives$[.i], ":\", "", 1)
                    boolean: .letter$[.i] + " drive", 1
                    .letter$[.i] = replace_regex$(.letter$[.i], ".", "\L&", 1)
                endfor
            .myChoice = endPause: "Exit", "Continue", 2, 1
            if .myChoice = 1
                exit
            endif
            for .i to .drives_N
                .curLetter$ = .letter$[.i]
                .done += '.curLetter$'_drive
            endfor
        endwhile
    else
    # Otherwise, just use the only drive available
        .letter$[1] =
        ... replace_regex$(replace$(.drives$[1], ":\", "", 1), ".", "\L&", 1)
        '.letter$[1]'_drive = 1
    endif

    # Warn user that the search could take a while.
    writeInfoLine: "Looking for ""'.file$'"" on your computer.",
    ... newline$, "It may take while, so be patient..."

    .found = 0
    .curDrive = 0
    for .curDrive to .drives_N
        .curDrive$ = .drives$[.curDrive]
        .curDriveVar$ = .letter$[.curDrive] + "_drive"
        if '.curDriveVar$'
            .tempFile$ = "candidates.tmp"
            if windows
                # Get list of file locations and date/time from via WHERE
                # function in Windows Command Prompt.
                .find_CMD$ =
                ... "where /t /r '.curDrive$' '.file$' > '.dir$''.tempFile$'"
                runSystem: .find_CMD$
                .list = Read Strings from raw text file: "'.dir$''.tempFile$'"
                deleteFile: "'.dir$''.tempFile$'"
                .numStrings = Get number of strings

                # Extract relevant data from .find_CMD$ output strings.
                if .numStrings
                    for .i to .numStrings
                        .found += 1
                        .cs$ = Get string: .i
                        .posR$[.found] =
                        ... right$
                        ... (.cs$, length(.cs$) + 1 - index(.cs$, "'.curDrive$'"))
                        .cs$ = replace$ (.cs$, "  " + .posR$[.found], "", 1)
                        .time$[.i] = right$(.cs$, 8)
                        .cs$ = replace$ (.cs$, "      " + .time$[.i], "", 1)
                        .date$[.i] = right$(.cs$, 10)
                        .end1 = rindex(.posR$[.i], "/")
                        .end2 = rindex(.posR$[.i], "\")
                        .end = .end2 * (.end2 > .end1) + .end1 * (.end1 > .end2)
                        .choice$[.found] =
                        ... .date$[.i] + tab$ + left$(.posR$[.i], .end)
                    endfor
                endif
                removeObject: .list
            elsif macintosh
                # Get list of file locations from MacOS
                exitScript: "Currently, @getLoc does not work on MacOS."
            else
                # Get list of file locations from Unix OS
                exitScript: "Currently, @getLoc does not work on a Unix OS."
            endif
        endif
    endfor

    if .found > 1
        # User chooses from selection of files found
        beginPause: "Choose Version"
            comment: "Please choose the version of ""'.file$'"" you wish to " +
            ... "use from the list below."
            comment: "#" +  tab$ + "DATE    " + tab$ + "LOCATION"
            for .i to .found
                comment: string$(.i) + ": " + tab$ + .choice$[.i]
            endfor
            comment: ""
            optionMenu: "Choice", .found
            for .i to .found
                option: string$(.i)
            endfor
        .myChoice = endPause: "Exit", "Choose", 2, 1
        if .myChoice = 1
            exit
        endif
        .loc$ = .posR$[choice]
    elsif .found
        # Otherwise select the only file found
        .loc$ = .posR$[1]
    else
        # or leave the path blank if no file was found
        .loc$ = ""
    endif
endproc

procedure line2Array: .string$, .sep$, .out$
    # correct variable name Strings
    if right$(.out$, 1) != "$"
        .out$ += "$"
    endif
    .size$ = replace$(.out$, "$", "_N", 0)

    # fix input csvLine array
    .string$ = replace$(.string$, "'.sep$' ", .sep$, 0)
    while index(.string$, "  ")
        .string$ = replace$(.string$, "  ", " ", 0)
    endwhile
    .string$ = replace_regex$ (.string$, "^[ \t\r\n]+|[ \t\r\n]+$", "", 0)
    .string$ += .sep$
    # generate output array
    '.size$' = 0
    while length(.string$) > 0
        '.size$' += 1
        .nextElementEnds = index(.string$, .sep$)
        '.out$'['.size$'] = left$(.string$, .nextElementEnds)
        .string$ = replace$(.string$, '.out$'['.size$'], "", 1)
        '.out$'['.size$'] = replace$('.out$'['.size$'], .sep$, "", 1)
        if '.out$'['.size$'] = ""
            '.size$' -= 1
        endif
    endwhile
endproc
