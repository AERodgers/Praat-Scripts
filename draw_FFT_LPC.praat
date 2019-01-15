# Draw LPC and FFT slice in Praat
# ===============================
# Written for Praat 6.0.36
#
# Antoin Eoin Rodgers
# rodgeran at tcd dot ie
# Phonetics and Speech Laboratory, Trinity College Dublin
# December 4 2018

# This script draws an FFT and LPC slice in the same frame.
# For the sake of simplicity, there are not options to modify the picture format.
# y-axis are set to the Praat defaults to that the FFT and LPC are easily comparible.
# To save file, uncheck the "suppress save" option in the UI form.

##############
# USER INPUT #
##############
form Draw LPC and FFT slice in Praat
    comment MAKE SURE YOUR SOUND FILE IS ALREADY LOADED
    natural soundfile 1
    positive window_length 0.025
    natural coefficients 1 (=decide via sampling rate)
    natural max_hertz 5000
    positive time_slice 0.5
    boolean draw_vertical_lines 0
	boolean supress_save 1
endform

# process UI
if draw_vertical_lines = 1
    vertical_lines$ = "yes"
else
    vertical_lines$ = "no"
endif
if coefficients = 1
    selectObject: soundfile
    coefficients = Get sampling frequency
    coefficients = round(coefficients/1000) + 2
endif

###########################
# CREATE SPECTRAL OBJECTS #
###########################
# create fft spectrum (spectrogram) and LPC analysis objects
selectObject: soundfile
spectrogram = To Spectrogram: window_length, max_hertz, 0.002, 20, "Gaussian"
selectObject: soundfile
lpc_analysis = To LPC (autocorrelation): coefficients, window_length, 0.005, 50

# Get LPC and FFT slices at time
selectObject: spectrogram
fftSlice = To Spectrum (slice): time_slice
selectObject: lpc_analysis
lpcSlice = To Spectrum (slice): time_slice, 20, 0, 50

##############
# DRAW IMAGE #
##############
# Set up drawing window
Erase all
Black
Line width: 1
Solid line
Font size: 10
Select outer viewport: 0, 6, 0, 4
Draw inner box

# Draw FFT
selectObject: fftSlice
Black
Line width: 2
Draw: 0, max_hertz, 0, 0, "no"
Line width: 1
Marks left every: 1, 10, "yes", "yes", "no"
Text left: "yes", "FFT (dB)"

# Draw FFT
selectObject: lpcSlice
Blue
Line width: 2
Draw: 0, max_hertz, 0, 0, "no"
Line width: 1
Marks right every: 1, 10, "yes", "yes", "no"
Text right: "yes", "LPC (dB)"

# Draw X axis and title
Marks bottom every: 1000, 0.5, "yes", "yes", vertical_lines$
Text bottom: "yes", "Frequency (kHz)"
selectObject: soundfile
title$ = selected$()
saveName$ = replace$(title$, "Sound ", "",1) + " " + fixed$(time_slice * 1000, 0) + " ms.png"
title$ = replace$(title$, "_", "\_ ", 0) + 
    ... " (" + fixed$(time_slice * 1000, 0) + " ms)"
Text top: "yes", title$

# Save image
if not supress_save
    fileName$ = chooseWriteFile$: "Save as PNG file", saveName$
   Save as 300-dpi PNG file: fileName$
endif

###########
# TIDY UP #
###########
# Remove objects
selectObject: lpc_analysis
plusObject: spectrogram
plusObject: lpcSlice
plusObject: fftSlice
Remove
