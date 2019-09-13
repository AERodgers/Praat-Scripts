# Utterance Global F0 and Intensity Declination Calculation (basic)
# =================================================================
# Written for Praat 6.x.x
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Sept 13 2019

# INFO
    # This script is designed to get some global F0 and intensity parameters
    # from an sound file containing a single utterence.
    #
    # The main procedure calculates slope, mean, linear max and min values for
    # pitch and intensity across a complete utterance.
    #
    # Input: 1. sound waveform and textgrid with single interval tier showing
    #           start and end of the utterance (enter number on object window)
    #        2. User specified min and max F0 (Hz) for pitch estimation (AC)
    #
    # Main Procedure:
    # This simply calcuates mean values and linear slopes of the contours. It
    # then projects the values of the slopes onto the start and end times of the
    # utterance. There are more sophisticated ways to implement such analyses,
    # but this script was written for very basic analysis purposes.
    #
    # Caveats:
    # The UI is also quite crude and as is the output procedure.
    # The main procedure will also not run without the other procedures listed
    # under "### DEPENDENCIES".
    # The script can be adapted to make this more useful (e.g. batch analysis
    # and table-form output), but I was feeling too lazy to do that at the time.
    # Maybe later!