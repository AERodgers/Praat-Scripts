# PRAAT VERSION COMPATIBILITY CHECK
# =================================
# Written for Praat 6.0.40

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
#
# This procedure will automatically check if the Praat version is 6.0.0 or
# or later and exit if it is not.
#
# Earlier versions of Praat may not be able to run scripts written using Praat
# script grammar in version 6 and later.)

procedure versionCheck
    version$ = praatVersion$
    if number(left$(version$, 1)) < 6
        echo You are running Praat 'praatVersion$'.
        ... 'newline$'This script runs on Praat version 6.0.40 or later.
        ... 'newline$'To run this script, update to the latest
        ... version at praat.org
        exit
    endif
endproc
