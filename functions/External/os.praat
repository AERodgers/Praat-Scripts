# OS
# ========================
# Written for Praat 6.1.08

# script by Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# July 2020
#
# This script returns a string os.is$ naming the operating system
# and a numeric variable os.is with an OS code:
#     1 = "Windows"
#     2 = "Macintosh"
#     3 = "Linux"
#
# This script is largely superfluous. I just put it here to remind myself
# about the predefined variables "windows", "macintosh", and "unix"!

procedure os
    .is = windows + macintosh + unix
    if windows
        .is$ = "Windows"
    elsif macintosh
        .is$ = "Macintosh"
    else
        .is$ = "Unix"
    endif
endproc
