### PLEASe NOTE THIS SCRIPT IS HERE FOR ARCIVAL PURPOSES ONLY.
### IT IS NOT RECOMMENDED FOR USE OTHERWISE
### IT HAS LARGELY BEEN SUPERCEDED BY THE K-MAX PRAAT PLUGIN

# Intonation Analysis Tools for Phonetics Research v 3.4b
# ======================================================
# written for Praat 6.0.31

# A. THE BASICS
#    Helps conduct analysis of IPs following the Autosegmental Metrical (AM) approach.
#    Reads wave and textgrid files with manually annotated syllable, orthogrpahic
#    and rhythmic tiers to perform (semi-)automated analysis of the pitch contour.
#
#    The script automatically checks all wavefiles in a specified folder.
#    Wavefiles without corresponding textgrid files are ignored.
#
#    The script is currently designed to analyse only one IP per wave file. It generates:
#      1. time-normalised point tier for alignment fo analysis
#          - includes marking of mid-points of syllables in anacrusis
#          - finds closest voiced portion to midpoint of anacrusis syllables
#          - smooths pitch trajectories using a centred moving point average
#      2. fo peak and valley point tiers
#          - identifies and marks first and final and measurable fo values (boundaries)
#          - identifies and marks mid-points for each syllable of anacrusis
#          - identifies and marks peaks and valleys for each foot
#      3. interval tiers for peak (plateaux) and valley durations for each foot
#          - calculates effective duration of peaks and valleys
#      4. tables with data for intonation, timing, and fo analysis
#      5. a graph showing syllable breaks along with original, corrected, and stylized
#         fo trace over time (non-normalized).
#
# B. THE PRE-ANNOTATED TEXTGRID
#    The script assumes that there are multiple repetitions of the same utterance by a speaker.
#    The expected format is "SpkrPhrase_Rep", e.g. "M2A02_1" (speaker M2, phrase A02,
#    repetition 1). If there is no "_re", the programme will crash when doing.
#
#    The script require four tiers to exist already and be annotated:
#      1. ORTHOGRAPHIC TIER: an interval tier and should be annotated per word.
#      2. SYLLABLIC TIER: an interval tier and should be annotated per syllable.
#      3. RHYTHMIC TIER: a point tier used to identify IP boundaries and lexically stressed
#                         syllables. This script assumes that all feet are left headeds. Any
#                         syllables before thefirst stressed syllable are read as anacrusis.
#                         The RHYTHMIC TIER should be annotated as follows:
#                           - Use a "%" symbol to mark the start and end of an IP.
#                           - Use "<" to mark the onset of a lexically stressed syllable and
#                             ">" to mark the offset. If the first syllable of the IP is also
#                             lexically stressed, you can type "%<" to show this, and,
#                             conversely, you can use ">%" for thelast syllable. Similarly, the
#                             combination "><" can be used when the offset of one stressed
#                             syllable is followed immediately by the onset of another.
#                           - Additional information can be added to the rhythmic tier, but it
#                             will be ignored by the script.
#      4. VOWEL TIER: a point tier used to identify time points in the vowel of the lexically
#                         stressed syllable.
#                           - "S" marks the vowel onset
#                           - "E" marks the end of the vowel
#                           - "C" marks the end of the first consonant in the rhyme. This is used
#                                 to allow the possibility of measuring tone alignment as a
#                                 function of durationally similar stretches of speech (long
#                                 vowel, short vowel + consonant) to make comparisons more valid.
#
#    It is advised that you make sure that points on the RHYTHMIC TIER are aligned closely
#    corresponding boundaries on the SYLLABIC and ORTHOGRAPHIC TIERS.
#
#    There is currently no error handling for textgrids which have not been properly annotated.
#    The names of the syllabic and rhythmic tiers in each textgrid in the containing folder
#    must be consistent.
#
# C. RUNNING THE SCRIPT: USER INPUT FORM
#       1. "directory"
#          This is the path directory for the sound and textgrid file. Leave blank is
#          script is in same folder as files.
#       2. Annotation tier names
#              - The syllabic and rhythmic tiers must already be annotated and named.
#                These tier names must match the original textgrid names consistently.
#              - The alignment, peaks and valleys, and tone durations tiers will be generated
#                by the script.
#                If tiers with these names already exist, they will be overwritten.
#       3. Variables for fundamental frequency analysis
#              - "min fo" and "max_fo"
#                These set the boundaries for fundamental frequency analysis
#              - "time_step"
#                The size of the time steps for fo analyis
#               - "normalised fo steps"
#                 This defines the number of time-normalised fo measurements to be taken:
#                    a. from the start to the end of each stressed syllable
#                    b. across the unstressed portion of the foot
#               - "duration fo threshold"
#                 This is a ratio of a peak or valley which is used to determine the effective
#                 duration of a tone.
#               - "mpa points"
#                 This is the number of points used in calculating the moving point average of
#                 the time-normalised fo trace. It should be set as an odd number, as the MPA
#                 is centred around the element being averaged.
#
# D. RUNNING THE SCRIPT: CORRECTING THE PITCH TRACE
#    The script uses the "To Manipulation" function and prompts the user to remove spurous
#    values or micro-prosodic effects in order to produce a more representative pitch trace.
#    At this point the user will be able to compare the spectrogram and pitch and remove any
#    unwanted points in the manipulation window.
#
# E. RUNNING THE SCRIPT: CURRECTING PEAK AND VALLEY LOCATIONS
#    The user also will be prompted to check and adjust peaks and valleys tier for each textgrid.
#    During this interactive component, the user will see two versions of the waveform:
#       1. The original waveform and the current textgrid
#
# F. OUTPUT
#       1. updated TEXTGRIDS with:
#            - alignment tier for time normalised fo measurements
#            - peaks and valleys tier with one H and L per foot, anacrusis midpoints for fo
#              measurement, and points idendifying initial (S) & final (E) analysable fo points
#            - effective duration tiers for high and low tones.
#       2. OUPUT folder:
#            - A table of time-normalised fo data for each wave file
#            - A data table for each set of repetitions containing:
#                 * phonological transcriptions from the phonological tier
#                 * phonetic information described in A
#                 * peak alignment ratios re stressed syllable, foot, and word boundaries
#                 * speech rate (syllables / second)
#            - A data table for each set of repetitions containing only general data & PNA data
#            - A report for the processed batch (same as info that appears in the Info window)
#       3. RESYNTH folder:
#            - each sound resynthesised with the corrected pitch track (see D. above)
#       4. IMAGE folder:
#            - fo trace for each utterance showing syllables and syllable boundaries. Includes
#              the original Praat pitch track, the corrected pitch track, and a sylized pitch
#               track.
#            - The stylised pitch track is generated using time and fo values for:
#                  * first and final measurable fo values
#                  * mid-point values in each anacrusis syllable
#                  * H and L points
#                  * beginning and end points of effective duration of plateaux and valleys.
#
# G. CHANGE LOG
#    3.2  includes the processing of the vowel tier
#    3.3  removed any calculations from output table so it can be processed in anpther script
#    3.4  fo values are determined by a pitch tier extracted from the manually corrected
#         manipulation object to get the most accurate fo values.
#    3.4b Corrected an error where tone durations were being projected into voiceless sections of
#         speech. Tone duration boundaries now also read the pitch track of the resynthesised
#         waveform to check that there is a defined fo in the waveform.
#    3.4  final and last syllable of word are now measured and saved in main table
#    3.4  added columns to table to record syllable number for H's and L's.
#
#      [NOTE: This script identifies a H and L for each foot. This does not mean that the foot
#       contains a pitch accent. The user should take this into account during analysis.]
#
# Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# Feb 14 2017

### default object indices and variables
soundobject = 2
textgrid = 1
remove_old_analysis_tiers = 1
### pitch track settings
candidates = 15
s_threshold = 0.03
v_threshold = 0.45
oct_cost = 0.01
oct_j_cost = 0.35
vuv_cost = 0.14
### Variables removed from UI form in V1.1
foot_boundary_evasion = 0.05
# ratio: fn of foot duration: tells  script not to measure fo close to the foot boundary.
flexibility = 0.05
# time around midpoint of syllables in anacrusis defined as a ratio of the whole syllable.
### default directory and file codes
output_dir$ = "output"
image_dir$ = "image"
resynth_dir$ = "resynth"
reportName$ = "Analysis_report.txt"

##########################
#### input procedures ####
##########################
form Automatic Annotation Script for fo tracking in Praat
    comment TARGET DIRECTORY AND TIER NAMES
    #sentence directory
    word orthographic ortho
    word syllabic syllable
    word rhythmic rhythmic
    word phonological phono
	word vowel_info vowel
    word alignment alignment
    word peaks_and_valleys tone
    word high_tone_duration HDur
    word low_tone_duration LDur
    word comments comments
    #boolean remove_old_analysis_tiers 1
	boolean drawLegend 0

    comment VARIABLES FOR FUNDAMENTAL FREQUENCY ANALYSIS
    natural min_fo 70
    natural max_fo 210
    positive time_step 0.01 (= fo analysis time step in secs)
    natural normalised_fo_steps 10 (= time normalised fo steps)
    positive duration_fo_threshold 0.04 (= effective tone duration ratio)
    natural mpa_points 5 (= an odd number)
endform
directory$ = chooseDirectory$: "Choose a directory with files for analysis"
### create directory path names
reportPath$ = directory$ + "\" + output_dir$
imagePath$ = directory$ + "\" + image_dir$
resynthDirectory$ =  directory$ + "\" + resynth_dir$
createDirectory: reportPath$
createDirectory: imagePath$
createDirectory: resynthDirectory$
resynthDirectory$ = resynthDirectory$ + "\"
reportPath$ = reportPath$ + "\"
imagePath$ = imagePath$ + "\"
reportFilePath$ = reportPath$ + reportName$

text$ = "======================================="
writeInfoLine: text$
writeFileLine: reportFilePath$, text$
text$ = "Automatic fo tracking Annotation Script"
@reportUpdate: reportFilePath$, text$
text$ = "---------------------------------------"
@reportUpdate: reportFilePath$, text$
# correct invalid input
text$ = newline$ + "Initialising"
@reportUpdate: reportFilePath$, text$
text$ = "-------------------"
@reportUpdate: reportFilePath$, text$

### output errors related to user input on form
if mpa_points/2 =round (mpa_points/2)
    mpa_points = mpa_points + 1
    text$ = "mpa_points was an even number and has been increased to "
        ... + string$(mpa_points) + "."
    @reportUpdate: reportFilePath$, text$
endif
if min_fo > max_fo
    temp_fo = min_fo
    min_fp = max_fo
    max_fo = temp_fo
    text$ = "min_fo was greater than max_fo. The values have been reversed."
    @reportUpdate: reportFilePath$, text$
elsif min_fo = max_fo
    max_fo = max_fo + 1
    text$ = "max_fo was equal to min_fo. The value of max_fo has been "
        ... + "increased by one."
    @reportUpdate: reportFilePath$, text$
endif

#########################################################
### get list of .wav and .TextGrid files in directory ###
#########################################################
if directory$ = ""
   text$ = "Target files and  script in same directory." + newline$
   @reportUpdate: reportFilePath$, text$
else
   if right$(directory$, 1) <> "\"
       directory$ = directory$ + "\"
   endif
   text$ = "Directory is: " + directory$ + newline$
   @reportUpdate: reportFilePath$, text$
endif
sound_file_list = Create Strings as file list: "sounds",  directory$ + "*.wav"
sound_list_temp = selected ()
Replace all: ".wav", "", 0, "literals"
Rename: "sounds"
sound_list = selected ()
numberOfSounds = Get number of strings
selectObject: sound_list_temp
Remove
textgrid_file_list = Create Strings as file list: "textgrids", directory$
    ... + "*.textgrid"
textgrid_list_temp1 = selected ()
Replace all: ".TextGrid", "", 0, "literals"
textgrid_list_temp2 = selected ()
Rename: "textgrids"
To WordList
textgrid_list = selected ()
selectObject: textgrid_list_temp1
plusObject: textgrid_list_temp2
Remove
### update report
text$ = "fo range is set from " + string$(min_fo) + " to " + string$(max_fo)
    ... + " Hz."
    ... + newline$ + "time step for fo analysis is set to "
    ... + string$(time_step) + " secs."
    ... + newline$ + "Foot time normalisation is set to "
    ... + string$(normalised_fo_steps)
    ... + " steps per stressed syllable and unstressed syllables per foot."
    ... + newline$ + "Effective tone duration has been set to "
    ... + string$(round(duration_fo_threshold*100))
    ... + "% of the maximum and minimum fo per foot." + newline$

@reportUpdate: reportFilePath$, text$
text$ = "Processing sound and textgrid files"
@reportUpdate: reportFilePath$, text$
text$ = "-----------------------------------"
@reportUpdate: reportFilePath$, text$
### cycle through all sound files with associated textgrid file and process them
for cur_sound to numberOfSounds
    selectObject: sound_list
    soundName$ = Get string: cur_sound
    text$ = "current sound (" + string$(cur_sound) +
        ... "/" + string$(numberOfSounds) +
        ... "): " + soundName$
    @reportUpdate: reportFilePath$, text$
    selectObject: textgrid_list
    textgridExists = Has word: soundName$
    if textgridExists
        Read from file: directory$ + soundName$ + ".wav"
        soundobject = selected()
        gridName$  = directory$ +  soundName$ + ".TextGrid"
        Read from file: gridName$
        textgrid = selected()
        ### remove old tiers if flag is set
        if remove_old_analysis_tiers = 1
        @remove_old_tiers
        endif
        ### call main analysis routine
        @main_routine
    else
        text$ = "   - There is no textgrid associated with this filename."
        @reportUpdate: reportFilePath$, text$
        text$ =  "   - It is being ignored."
        @reportUpdate: reportFilePath$, text$
    endif
    text$ = ""
    @reportUpdate: reportFilePath$, text$
endfor

##########################################
### Remove remaining surplus artifacts ###
##########################################
selectObject: textgrid_list
plusObject: sound_list
Remove
text$ = newline$ + "Automatic Annotations Script complete."
@reportUpdate: reportFilePath$, text$
text$ = "======================================"
@reportUpdate: reportFilePath$, text$

#####################
#### MAIN ROUTINE ###
#####################
procedure main_routine
    ### GET SOUND CODE AND REP CODE
    sound_code$ = left$(soundName$, rindex(soundName$, "_") - 1)
    rep$ = right$(soundName$, length(soundName$) - rindex(soundName$, "_"))

    ### GET INDEX VALUES FOR SYLLABLE AND RYTHYMIC TIERS
    selectObject: textgrid
    alignment_tier = 0
    hi_lo_tier = 0
    h_tone_dur = 0
    l_tone_dur = 0
    ### get information about existing tiers
    num_tiers = Get number of tiers
    for i to num_tiers
        tier_name$[i] = Get tier name: i
        if tier_name$[i] = syllabic$
            syllable_tier = i
        elsif tier_name$[i] = orthographic$
            ortho_tier = i
        elsif tier_name$[i] = rhythmic$
            rhythmic_tier = i
        elsif tier_name$[i] = phonological$
            phono_tier = i
		elsif tier_name$[i] = vowel_info$
            vowel_tier = i
        elsif tier_name$[i] = alignment$
            alignment_tier = i
        elsif tier_name$[i] = peaks_and_valleys$
            hi_lo_tier = i
        elsif tier_name$[i] = high_tone_duration$
            h_tone_dur = i
        elsif tier_name$[i] = low_tone_duration$
            l_tone_dur = i
        endif
    endfor


    ### process syllable tier to create text & syllable boundary table
    @create_syl_table: textgrid, syllable_tier
    syl_table = create_syl_table.syl_table
    ### add H and L tiers if they do not already exist.
    selectObject: textgrid
    if hi_lo_tier = 0
        num_tiers = Get number of tiers
        hi_lo_tier = num_tiers + 1
        Insert point tier: hi_lo_tier, peaks_and_valleys$
    else
        @clear_tier: textgrid, hi_lo_tier
    endif

    ### ADD TIERS FOR SELECTED ANALYSES
    selectObject: textgrid
    if alignment_tier = 0
        num_tiers = Get number of tiers
            alignment_tier = num_tiers + 1
            Insert point tier: alignment_tier, alignment$
    else
    ### delete current alignment tier if non-empty
    @clear_tier: textgrid, alignment_tier
    endif

    selectObject: textgrid
    # add duration tiers if they do not already exist.
    if h_tone_dur = 0
        num_tiers = Get number of tiers
        h_tone_dur = num_tiers + 1
        Insert interval tier: h_tone_dur, high_tone_duration$
    else
        @clear_tier: textgrid, h_tone_dur
    endif
    if l_tone_dur = 0
        num_tiers = Get number of tiers
        l_tone_dur = num_tiers + 1
        Insert interval tier: l_tone_dur, low_tone_duration$
    else
        @clear_tier: textgrid, l_tone_dur
    endif

    ### define time point variables
    rhythmic_points = Get number of points: rhythmic_tier
    syllable_intervals = Get number of intervals: syllable_tier
    # NOTE: "syllable_intervals" is currently unused

    ################################################################
    ### Process ortographic, syllable, rhythmic, and vowel tiers ###
    ################################################################
    selectObject: textgrid
    ###get sentence
    ortho_ints = Get number of intervals: ortho_tier
    sentence$ = Get label of interval: ortho_tier, 2
    for cur_int from 3 to ortho_ints - 1
        new_word$ = Get label of interval: ortho_tier, cur_int
        sentence$ = sentence$ + " " + new_word$
    endfor

    ### error flags and counters
    boundaries = 0
    stressed_syllables = 0
    stress_start = 0
    stress_end = 0
    error = 0
    syllable_parity = 0
    ### variable default settings
    phr_strt = 0
    phrase_end = 0
    anac_ends = 0
    feet = 0
    foot_start[1] = 0
    stress_syll_end[1] = 0
    foot_end[1] = 0
    foot_one_point = 0

    ### get labels and time points for ryhthmic tier
    selectObject: textgrid
    for i to rhythmic_points
        rhythm_label$[i] = Get label of point: rhythmic_tier, i
        rhythm_time[i] = Get time of point: rhythmic_tier, i
        ### check and process rhythmic labels with 'label_size' number of characters
        label_size = length (rhythm_label$[i])
        for j to label_size
            cur_char$ = mid$ (rhythm_label$[i], j, 1)
            ### identify where anacrusis ends and first foot starts
            if  cur_char$ = "<" and anac_ends = 0
                if foot_one_point = 0
                   foot_one_point = i
                endif
                stress_start = stress_start + 1
                syllable_parity = syllable_parity - 1
                anac_ends = rhythm_time[i]
                feet = feet + 1
                foot_start[feet] = rhythm_time[i]
            ### identify where a foot / stressed syllable starts
            elsif cur_char$ = "<"
                stress_start = stress_start + 1
                syllable_parity = syllable_parity - 1
                if foot_start[feet] > 0
                    foot_end[feet] = rhythm_time[i]
                    feet = feet + 1
                    foot_start[feet] = rhythm_time[i]
                endif
            ### identify where stressed syllable ends
            elsif  cur_char$ = ">"
                stress_syll_end[feet] = rhythm_time[i]
                stress_end = stress_end + 1
                syllable_parity = syllable_parity + 1
            ### identify initial and final boundaries
            elsif cur_char$ = "%"
                boundaries = boundaries + 1
                if phr_strt = 0
                    phr_strt = rhythm_time[i]
                    init_boundary$ = replace$(rhythm_label$[i], "<", "", 0)
                else
                    phrase_end = rhythm_time[i]
                    foot_end[feet] = rhythm_time[i]
                    final_boundary$ =  replace$(rhythm_label$[i], ">", "", 0)
                endif
            endif
            ### check for stressed-syllable annotation error
            if syllable_parity < -1 or syllable_parity > 0
                error = 1
            endif
        endfor
    endfor

    ### Get phonological structure
    phonology$ = init_boundary$
    selectObject: textgrid
    phono_intervals = Get number of intervals: phono_tier
    for i to phono_intervals
        cur_accent$ = Get label of interval: phono_tier, i
        phonology$ = phonology$ + " " + cur_accent$
    endfor
    phonology$ = phonology$ + " " + final_boundary$

    ### Get number of syllables
    selectObject: textgrid
    syl_ints = Get number of intervals: syllable_tier
    phr_syls = syl_ints - 2

    ### Get number of anacrusis syllables
    selectObject: textgrid
    ana_syls = 0
    ana_dur = anac_ends - phr_strt
    if phr_strt <> anac_ends
        cur_syllable = 1
        cur_time_point = phr_strt
        cur_interval = Get interval at time: syllable_tier, cur_time_point
        while ana_syls = 0
            cur_syll_end = Get end point: syllable_tier, cur_interval
            if cur_syll_end = anac_ends
                ana_syls = cur_syllable
            endif
            cur_interval = cur_interval + 1
            cur_syllable = cur_syllable + 1
        endwhile
    endif

    # report number of sylls of anacrusis
    plural$ = "s"
    if ana_syls = 1
        plural$ = ""
    endif
    text$ = "   - Phrase has " + string$(ana_syls)
        ... + " syllable" + plural$ + " of anacrusis."
    @reportUpdate: reportFilePath$, text$

    ### detect and highlight rhymthmic tier annotation errors
    if error = 1
        text$ = "You have mis-annotated your stressed-syllable boundaries in"
            ... + " the rhythmic tier of " + soundName$ + ".TextGrid"
            ... + ". It will create an error."
        @reportUpdate: reportFilePath$, text$
    endif
    if boundaries = 0 or boundaries/2 <> round(boundaries/2)
        if boundaries = 1
            sing_pl$ = "boundary"
        else
            sing_pl$ = "boundaries"
        endif
        text$ = "   * You have " + string$(boundaries) + " " + sing_pl$
        ... + " for " + soundName$ + ".TextGrid. "
        ... + "It may create an error."
        @reportUpdate: reportFilePath$, text$
        error = 1
    endif

    ##########################
	### Process vowel tier ###
	selectObject: textgrid
	Extract one tier: vowel_tier
	tempVTextGrid = selected()
	Down to Table: "no", 3, "yes", "no"
	tempVowelTable = selected()
	# set error check variable
	vTierOkay = 1
	numRows = Get number of rows
	totLetters = 0
	foot = 0
    oldFoot = 0

	for i to numRows
		vowelText$ = Get value: i, "text"
		curTime = Get value: i, "tmin"
		numLetters = length(vowelText$)
		totLetters = totLetters + numLetters
		for j to numLetters
			curLetter$ = mid$(vowelText$,j)

			test = oldFoot = 0 and (curLetter$ = "O" or curLetter$ = "S")
			if oldFoot = 0 and (curLetter$ = "O" or curLetter$ = "S")
				foot = foot + 1
				oldFoot = oldFoot + 1
			endif

			if curLetter$ = "S"
				vStart[foot] = curTime
			elif curLetter$ = "O"
			    voicingOnset[foot] = curTime
			elif curLetter$ = "E"
				vEnd[foot] = curTime
			elif curLetter$ = "C"
				vClose[foot] = curTime
				oldFoot = 0
			else
				vTierOkay = 0
			endif
		#appendInfoLine: "foot:", foot, " @ ", curTime, " - ", curLetter$
	    endfor

	endfor

	if totLetters/4 <> floor(totLetters/4)
		vTierOkay = 0
	endif
	# report error (NOTE: there is no error handling for this!)
        #   - solution: make above code a procedure that loops til corrected
	if vTierOkay = 0
        text$ = "   - There is an error in the marking of the vowel tier of this text grid."
        @reportUpdate: reportFilePath$, text$
	endif
	selectObject: tempVTextGrid
	plusObject: tempVowelTable
	Remove

    ##############################################################
	### process syllable tier to identify word-final syllables ###
	selectObject: textgrid
	Extract one tier: syllable_tier
	tempSylTier = selected()
	for foot to feet
		foundWordEnd = 0
		selectObject: tempSylTier
		Extract part: foot_start[foot] + 0.000001, foot_end[foot], "yes"
		tempFootTier = selected()
		Down to Table: "no", 3, "yes", "no"
		tempFootTable = selected()
		rows = Get number of rows
		for i to rows

			curSyll$ = Get value: i, "text"
			lastChar$ = right$(curSyll$, 1)
			if lastChar$ <> "-" and foundWordEnd = 0
				foundWordEnd = 1
				wordEndSylStart[foot] = Get value: i, "tmin"
				wordEndSylEnd[foot] = Get value: i, "tmax"
			endif
		endfor

		selectObject: tempFootTier
		plusObject: tempFootTable
		Remove
	endfor
	selectObject: tempSylTier
	Remove

    ###############################################################
    ### create pitch objects [currently praat pitch object (ac) ###
    ###############################################################
    ###   NOTE: Later, get pitch values from another source.    ###
    selectObject: soundobject
    To Pitch (ac): 0.75/min_fo, min_fo, candidates, "no",
        ... s_threshold, v_threshold, oct_cost, oct_j_cost, vuv_cost, max_fo
    orig_pitchtrack = selected ()

    selectObject: soundobject
    To Manipulation: time_step, min_fo, max_fo
    temp_manip = selected ()
    selectObject: soundobject
    Edit
        editor: soundobject
            Move cursor to: phr_strt
            Move end of selection by: phrase_end - phr_strt
            Zoom to selection
            Advanced pitch settings: 0, 0, "no", candidates, s_threshold,
                ...  v_threshold, oct_cost, oct_j_cost, vuv_cost
                Pitch settings: min_fo, max_fo,
                ... "Hertz", "autocorrelation", "automatic"

        endeditor
    selectObject: temp_manip
    Edit
	# stylize to 0.1 ST for easier manual correction
	editor: temp_manip
         Stylize pitch: 0.1, "semitones"
    endeditor
    pause_text$ = "Checking the pitch tracking."
    beginPause: pause_text$
        comment: "Currently showing the pitch track for your current sound."
        comment: "Remove or stylise the pitch tracker to remove errors."
        comment: ""
    endPause: "Continue", 1

    #### create and save resynthesised sound
	selectObject: temp_manip
	Extract pitch tier
	pitchTier = selected ()
	selectObject: temp_manip
    Get resynthesis (overlap-add)
    pitchsound = selected ()
    resynthSave$ = resynthDirectory$ + "RS_" + soundName$ + ".wav"
    Save as WAV file: resynthSave$
    To Pitch (ac): 0.75/min_fo, min_fo, candidates, "no",
    ... s_threshold, v_threshold, oct_cost, oct_j_cost, vuv_cost, max_fo
    pitchtrack = selected ()
    selectObject: temp_manip
    Remove


    ##############################################################################
    ### Generate H&L  tiers excursion size, duration, & H-to-syll association ###
    ##############################################################################
    ### Find H and L for each foot
    cur_row = 1
    selectObject: pitchtrack
    for i to feet
        cur_start = foot_start[i]
        cur_end = foot_end[i]
        trim_duration = (cur_end - cur_start) * foot_boundary_evasion
        cur_start = cur_start + trim_duration
        cur_end = cur_end - trim_duration
        foot_num[cur_row] = i
        min_t[cur_row] = Get time of minimum:
            ... cur_start, cur_end, "Hertz", "Parabolic"
        max_t[cur_row] = Get time of maximum:
            ... cur_start, cur_end, "Hertz", "Parabolic"
        if min_t[cur_row] = undefined
            min_val[cur_row] = undefined
        else
            min_val[cur_row] = Get value at time:
                ... min_t[cur_row], "Hertz", "Linear"
        endif
        if max_t[cur_row] = undefined
            max_val[cur_row] = undefined
        else
            max_val[cur_row] = Get value at time:
                ... max_t[cur_row], "Hertz", "Linear"
        endif
        start_t[cur_row] = cur_start
        end_t[cur_row] = cur_end
        cur_row = cur_row + 1
    endfor

    ### add H and L data to textgrid
    selectObject: textgrid
    for cur_row to feet
        if max_t[cur_row] <> undefined
            check_point = Get nearest index from time:
                ... hi_lo_tier, max_t[cur_row]
            if check_point > 0
                check_time = Get time of point: hi_lo_tier, check_point
            else
                check_time = 0
            endif
            if check_time <> max_t[cur_row]
                Insert point: hi_lo_tier, max_t[cur_row],
                ... "H" + string$(foot_num[cur_row])
            endif
        endif
        if min_t[cur_row] <> undefined
            check_point = Get nearest index from time:
                          ... hi_lo_tier, min_t[cur_row]
            if check_point > 0
                check_time = Get time of point:
                             ... hi_lo_tier, check_point
            else
                check_time = 0
            endif
            if check_time <> min_t[cur_row]
                Insert point: hi_lo_tier, min_t[cur_row],
                              ... "L" + string$(foot_num[cur_row])
            endif
        endif
    endfor

    ### get user to check and correct errors in H and L tier
    #selectObject: pitchsound
    selectObject: soundobject
    plusObject: textgrid
    Edit
    editor: textgrid
        Move cursor to: phr_strt
        Move end of selection by: phrase_end - phr_strt
        Zoom to selection
        Advanced pitch settings: 0, 0, "no",
            ... candidates, s_threshold, v_threshold,
            ... oct_cost, oct_j_cost, vuv_cost
            Pitch settings:
            ... min_fo, max_fo, "Hertz", "autocorrelation", "automatic"
    endeditor
	#original sound object no longer to be displayed, only resynth
    #selectObject: soundobject
    #plusObject: textgrid
    #Edit
    ### set editor window pitch settings to equal pitch object settings, fit window to IP
    ### pause for user input
    pause_text$ = "Checking the " + peaks_and_valleys$ + " tier."
    beginPause: pause_text$
        comment: "Currently showing spectrogram with smoothed pitch tier."
        comment: "If the H and L points are misaligned, you can move them."
        comment: ""
        comment: "Do not delete any intervals or points."
        comment: "CLOSE THE EDITOR WINDOW TO IMPROVE PROCESSING TIME."
    endPause: "Continue", 1
    ### adjust H and L t's based on user input
    selectObject: textgrid
    tot_points = Get number of points: hi_lo_tier
    for cur_point to tot_points
        cur_label$ = Get label of point: hi_lo_tier, cur_point
        cur_label_tone$ = left$(cur_label$, 1)
        if cur_label_tone$ = "H" or cur_label_tone$ = "L"
            cur_time = Get time of point: hi_lo_tier, cur_point
            cur_foot_num = number(right$(cur_label$, length(cur_label$)-1))
            ### find array index of current foot
            cur_row = 1
            while foot_num[cur_row] <> cur_foot_num
                cur_row = cur_row + 1
            endwhile
            if foot_num[cur_row] = cur_foot_num
                if cur_label_tone$ = "H"
                    max_t[cur_row] = cur_time
                elsif cur_label_tone$ = "L"
                    min_t[cur_row] = cur_time
                endif
            endif
        endif
    endfor

    ### adjust H and L vals based on user input
    selectObject: pitchtrack
	selectObject: pitchTier
    for cur_row to feet
        old_min_val = min_val[cur_row]
        old_max_val = max_val[cur_row]
        if min_val[cur_row] <> undefined
            #min_val[cur_row] = Get value at time: min_t[cur_row],
            #    ... "Hertz", "Linear"
            min_val[cur_row] = Get value at time: min_t[cur_row]
        else
            text$ = "   - L" + string$(foot_num[cur_row])
                ... + " is undefined."
            @reportUpdate: reportFilePath$, text$
        endif
        if max_val[cur_row] <> undefined
            #max_val[cur_row] = Get value at time: max_t[cur_row],
            #    ... "Hertz", "Linear"
            max_val[cur_row] = Get value at time: max_t[cur_row]
        else
            text$ = "   - H" + string$(foot_num[cur_row])
                ... + " is undefined."
            @reportUpdate: reportFilePath$, text$
        endif
        #### report manual changes
        if old_min_val <> min_val[cur_row]
            text$ = "   - L" + string$(foot_num[cur_row])
                ... + " has been manually adjusted."
            @reportUpdate: reportFilePath$, text$
        endif
        if old_max_val <> max_val[cur_row]
            text$ = "   - H" + string$(foot_num[cur_row])
                ... + " has been manually adjusted."
            @reportUpdate: reportFilePath$, text$
        endif
    endfor

    #########################
    ### analyse anacrusis ###
    #########################
    ### add midpoints to syllables in anacrusis
    if ana_syls > 0
        selectObject: textgrid
        # define key variables and defualt values
        cur_anac_syl = 1
        cur_syllable_interval =
            ... Get interval at time: syllable_tier, phr_strt
        while cur_anac_syl <= ana_syls
            cur_start =
                ... Get start point: syllable_tier, cur_syllable_interval
            cur_end = Get end point: syllable_tier, cur_syllable_interval
            mid_point = (cur_start + cur_end) / 2
            wiggle_room = (cur_end - cur_start) * flexibility / 2
            ### get nearest defined fo value and time re current interval midpoint
            @defined_fo: pitchtrack, mid_point, time_step, wiggle_room

            ### add current anacrusis syllable mid-point to alignment
            selectObject: textgrid

            align_text$ = "0." + string$(cur_anac_syl)
            Insert point: alignment_tier, defined_fo.time, align_text$

            ### add point on tone tier
            hi_lo_text$ = "A" + string$(cur_anac_syl)
            Insert point: hi_lo_tier, defined_fo.time, hi_lo_text$
            ana_t[cur_anac_syl] = defined_fo.time
			# ***
			selectObject: pitchTier
			#ana_fo[cur_anac_syl] = defined_fo.fo
            ana_fo[cur_anac_syl] = Get value at time: defined_fo.time
			selectObject: textgrid
            cur_syllable_interval = cur_syllable_interval + 1
            cur_anac_syl = cur_anac_syl + 1
        endwhile
    endif

    # add first fo point near initial boundary
    @boundary_fo: pitchtrack, phr_strt, time_step
    init_t = boundary_fo.time
    # ***
    #init_fo = boundary_fo.fo
	selectObject: pitchTier
	init_fo = Get value at time: init_t
	selectObject: textgrid

    @update_point_label: hi_lo_tier, init_t, "S", textgrid

    # add final fo point near end boundary
    @boundary_fo: pitchtrack, phrase_end, -time_step
    fin_t = boundary_fo.time
    #fin_fo = boundary_fo.fo
	selectObject: pitchTier
	fin_fo = Get value at time: fin_t
	selectObject: textgrid

    @update_point_label: hi_lo_tier, fin_t, "E", textgrid

    #####################################################################
    ### Generate alignment tier for time normalised acoustic analysis ###
    #####################################################################
    ### Add time-normalised measurement points for fo in each foot
    selectObject: textgrid
    foot = 0
    for current_point from foot_one_point to rhythmic_points - 1
        if index (rhythm_label$[current_point], "<") > 0
            foot = foot + 1
            cur_syll_num = 1
        endif
        cur_start = rhythm_time[current_point]
        cur_end = rhythm_time[current_point + 1]
        step_size = (cur_end - cur_start) / (normalised_fo_steps - 1)
        for current_mark from 1 to normalised_fo_steps - 1
            cur_text$ = string$(foot) + "." + string$(cur_syll_num)
            Insert point: alignment_tier,
                ... cur_start + step_size * (current_mark - 1), cur_text$
            cur_syll_num = cur_syll_num + 1
        endfor
    endfor
    # insert final point
    cur_text$ = string$(foot) + "." + string$(cur_syll_num)
    Insert point: alignment_tier, rhythm_time[rhythmic_points], cur_text$

    ##################################################################
    ### record and store time normalized alignment info in a table ###
    alignment_tier_points = Get number of points: alignment_tier
    tableName$ = soundName$ + "_normalised_time"
    Create Table with column names: tableName$,
        ... alignment_tier_points, "index foot point time fo"
    fo_alignment_table = selected ()
    for current_point to alignment_tier_points
        selectObject: textgrid
        cur_label$ = Get label of point: alignment_tier, current_point
        foot_num = number(left$(cur_label$, index(cur_label$, ".")-1))
        point_num = number(right$(cur_label$,
            ... length(cur_label$) - index(cur_label$, ".")))
        cur_time = Get time of point: alignment_tier, current_point
        selectObject: pitchtrack
        cur_fo = Get value at time: cur_time, "Hertz", "Linear"
        selectObject: fo_alignment_table
        Set numeric value: current_point, "index", current_point
        Set numeric value: current_point, "foot", foot_num
        Set numeric value: current_point, "point", point_num
        Set numeric value: current_point, "time",
            ... number(fixed$(cur_time, 3))
        Set numeric value: current_point, "fo", round(cur_fo)
    endfor
    ### Calculate moving point average for fo column
    @calc_mpa: mpa_points, fo_alignment_table, "fo", "mpa"
    Save as tab-separated file: reportPath$ + soundName$
        ... + "_normalised.Table"
    Remove


    ###########################################
    ### Generate High and Low Duration tier ###
    ###########################################
    ### identify duration of L and H tones in each foot

    for i to feet
        # get HL data for current foot
        cur_foot_start = start_t[i]
        cur_foot_end = end_t[i]

        #set initial time points for boundaries
        cur_hi_t = max_t[i]
        cur_hi_fo = max_val[i]
        cur_hi_left_t = cur_hi_t - time_step
        cur_hi_right_t = cur_hi_t + time_step
        cur_lo_t = min_t[i]
        cur_lo_fo = min_val[i]
        cur_lo_left_t = cur_lo_t - time_step
        cur_lo_right_t = cur_lo_t + time_step


		#get initial fo points for boundaries
        #use RS pitch track
		selectObject: pitchtrack
        cur_hi_left_fo = Get value at time: cur_hi_left_t, "Hertz", "Linear"
        cur_hi_right_fo = Get value at time: cur_hi_right_t, "Hertz", "Linear"
		cur_lo_left_fo = Get value at time: cur_lo_left_t, "Hertz", "Linear"
        cur_lo_right_fo = Get value at time: cur_lo_right_t, "Hertz", "Linear"

        #avoid accident undefined fo measurements
        # set parity flags for undefined values in the RS pitchtrack
		cur_hi_left_def = 1
		cur_hi_right_def = 1
		cur_lo_left_def = 1
		cur_lo_right_def = 1

        if cur_hi_left_fo = undefined
            cur_hi_left_fo = cur_hi_fo
            cur_hi_left_t = cur_hi_t
			cur_hi_left_def = 0
        endif

        if cur_hi_right_fo = undefined
            cur_hi_right_fo = cur_hi_fo
            cur_hi_right_t = cur_hi_t
			cur_hi_right_def = 0
        endif

        if cur_lo_left_fo = undefined
            cur_lo_left_fo = cur_lo_fo
            cur_lo_left_t = cur_lo_t
			cur_lo_left_def = 0
        endif

        if cur_lo_right_fo = undefined
            cur_lo_right_fo = cur_lo_fo
            cur_lo_right_t = cur_lo_t
    		cur_lo_right_def = 0
        endif

        #use manipulation pitchTier to get better initial values
        selectObject: pitchTier
		cur_hi_left_fo = Get value at time: cur_hi_left_t
        cur_hi_right_fo = Get value at time: cur_hi_right_t
		cur_lo_left_fo = Get value at time: cur_lo_left_t
        cur_lo_right_fo = Get value at time: cur_lo_right_t

        old_hi_left_t = cur_hi_left_t
        old_hi_right_t = cur_hi_right_t
        old_hi_left_fo = cur_hi_left_fo
        old_hi_right_fo = cur_hi_right_fo
        old_lo_left_t = cur_lo_left_t
        old_lo_right_t = cur_lo_right_t
        old_lo_left_fo = cur_lo_left_fo
        old_lo_right_fo = cur_lo_right_fo


        # identify left and right boundaries of H and L tones using
        # an fo threshold of +/- duration_fo_threshold ratio
        min_fo_threshold = cur_hi_fo * (1 - duration_fo_threshold)
        max_fo_threshold = cur_hi_fo * (1 + duration_fo_threshold)
        while cur_hi_left_fo > min_fo_threshold and cur_hi_left_t  > init_t
                 ... and max_fo_threshold >= cur_hi_left_fo
                 ... and cur_hi_left_def = 1
                 ... and cur_hi_left_t >= cur_foot_start
            old_hi_left_t = cur_hi_left_t
            cur_hi_left_t = cur_hi_left_t - time_step
            old_hi_left_fo = cur_hi_left_fo
			selectObject: pitchtrack
            cur_hi_left_def = Get value at time: cur_hi_left_t,  "Hertz", "Linear"
			cur_hi_left_def = cur_hi_left_def <> undefined
			selectObject: pitchTier
            cur_hi_left_fo = Get value at time: cur_hi_left_t

        endwhile
        while cur_hi_right_fo > min_fo_threshold and cur_hi_right_t < fin_t
                ... and max_fo_threshold >= cur_hi_right_fo
                ... and cur_hi_right_def = 1
                ... and cur_hi_right_t <= cur_foot_end
            old_hi_right_t = cur_hi_right_t
            cur_hi_right_t = cur_hi_right_t + time_step
            old_hi_right_fo = cur_hi_right_fo
			selectObject: pitchtrack
            cur_hi_right_def = Get value at time: cur_hi_right_t, "Hertz", "Linear"
			cur_hi_right_def = cur_hi_right_def <> undefined
            selectObject: pitchTier
			cur_hi_right_fo = Get value at time: cur_hi_right_t


        endwhile
        min_fo_threshold = cur_lo_fo * (1 - duration_fo_threshold)
        max_fo_threshold = cur_lo_fo * (1 + duration_fo_threshold)
        while cur_lo_left_fo < max_fo_threshold and cur_lo_left_t  > init_t
                ... and min_fo_threshold <= cur_lo_left_fo
                ... and cur_lo_left_def = 1
                ... and cur_lo_left_t >= cur_foot_start
            old_lo_left_t = cur_lo_left_t
            cur_lo_left_t = cur_lo_left_t - time_step
            old_lo_left_fo = cur_lo_left_fo
			selectObject: pitchtrack
            cur_lo_left_def = Get value at time: cur_lo_left_t, "Hertz", "Linear"
			cur_lo_left_def = cur_lo_left_def <> undefined
            selectObject: pitchTier
			cur_lo_left_fo = Get value at time: cur_lo_left_t
        endwhile
        while cur_lo_right_fo < max_fo_threshold and cur_lo_right_t < fin_t
                ... and min_fo_threshold <= cur_lo_right_fo
                ... and cur_lo_right_def = 1
                ... and cur_lo_right_t <= cur_foot_end
            old_lo_right_t = cur_lo_right_t
            cur_lo_right_t = cur_lo_right_t + time_step
            old_lo_right_fo = cur_lo_right_fo
			selectObject: pitchtrack
            cur_lo_right_def = Get value at time: cur_lo_right_t, "Hertz", "Linear"
			cur_lo_right_def = cur_lo_right_def <> undefined
            selectObject: pitchTier
			cur_lo_right_fo = Get value at time: cur_lo_right_t
        endwhile

        # start time data for H and L duration
        hi_start[i] = number(fixed$(old_hi_left_t, 3))
        hi_end[i] = number(fixed$(old_hi_right_t, 3))
        hi_dur[i] = number(fixed$(old_hi_right_t - old_hi_left_t, 3))
        lo_start[i]= number(fixed$(old_lo_left_t, 3))
        lo_end[i] = number(fixed$(old_lo_right_t, 3))
        lo_dur[i] = number(fixed$(old_lo_right_t - old_lo_left_t, 3))

        # start fo data for H and L duration fo values
        hi_start_fo[i] = round(old_hi_left_fo)
        hi_end_fo[i] = round(old_hi_right_fo)
        lo_start_fo[i]= round(old_lo_left_fo)
        lo_end_fo[i] = round(old_lo_right_fo)

    endfor

    ### add HL duration intervals to textgrid
    selectObject: textgrid
    for i to feet
        if hi_start[i] <> undefined
            check_boundary = Get interval at time: h_tone_dur, hi_start[i]
            check_start = Get start point: h_tone_dur, check_boundary
            if hi_start[i] <> check_start
                Insert boundary: h_tone_dur, hi_start[i]
            endif
        endif
        if hi_end[i] <> undefined
            check_boundary = Get interval at time: h_tone_dur, hi_end[i]
            check_start = Get start point: h_tone_dur, check_boundary
            if hi_end[i] <> check_start
                Insert boundary: h_tone_dur, hi_end[i]
            endif
        endif
        if lo_start[i] <> undefined
            check_boundary = Get interval at time: l_tone_dur, lo_start[i]
            check_start = Get start point: l_tone_dur, check_boundary
            if lo_start[i] <> check_start
                Insert boundary: l_tone_dur, lo_start[i]
            endif
        endif
        if lo_end[i] <> undefined
            check_boundary = Get interval at time: l_tone_dur, lo_end[i]
            check_start = Get start point: l_tone_dur, check_boundary
            if lo_end[i] <> check_start
                Insert boundary: l_tone_dur, lo_end[i]
            endif
        endif
    endfor
    tone_points = Get number of points: hi_lo_tier
    for i to  tone_points
        tone_time = Get time of point: hi_lo_tier, i
        tone_label$ = Get label of point: hi_lo_tier, i
        if left$(tone_label$, 1) = "H"
            interval_num = Get interval at time: h_tone_dur, tone_time
            num_intervals = Get number of intervals: h_tone_dur
            if interval_num = num_intervals
                interval_num = interval_num - 1
            endif
            Set interval text: h_tone_dur, interval_num, tone_label$
        elsif left$(tone_label$, 1) = "L"
            interval_num = Get interval at time: l_tone_dur, tone_time
            if interval_num = 1
                interval_num = 2
            endif
            Set interval text: l_tone_dur, interval_num, tone_label$
        endif
            endfor

    ################################
    ### CREATE & POPULATE TABLES ###
    ################################
    Create Table with column names: sound_code$ + "_main", 1,
        ... "code rep sent phon ana_syls ana_dur phr_dur phr_syls"
        ... + " init_phon init_t init_fo"
		#REMOVED ... +  "syls_sec"
    main_table = selected()
    Create Table with column names: sound_code$ + "_graph", 0,
        ... "t fo"
    graph_table = selected()
    cur_graph_row = 0

	### add general data to table row
    selectObject: main_table
    ### sound code info to main table
    Set string value: 1, "code", sound_code$
    Set string value: 1, "rep", rep$
    ### add sentence to main table
    Set string value: 1, "sent", sentence$
    ### add basic anacrusis info to main table
    Set numeric value: 1, "ana_syls", ana_syls
    Set numeric value: 1, "ana_dur", number(fixed$(ana_dur, 3))
    ### add phonological structure and phrase length to main table
    Set string value: 1, "phon", phonology$
    phr_dur = phrase_end - phr_strt
    Set numeric value: 1, "phr_dur", number(fixed$(phr_dur, 3))
    Set numeric value: 1, "phr_syls", phr_syls
    #REMOVED Set numeric value: 1, "syls_sec", number(fixed$(phr_syls / phr_dur, 3))
    # add initial boundary time and fo
    Set string value: 1, "init_phon", init_boundary$
    Set numeric value: 1, "init_t", number(fixed$(init_t - phr_strt, 3))
    Set numeric value: 1, "init_fo", round(init_fo)

	### add anacrusis data to table row
    for i to ana_syls
        selectObject: main_table
        Append column: "ana_t_" + string$(i)
        Append column: "ana_fo_" + string$(i)
        Set numeric value: 1, "ana_t_" + string$(i),
            ... number(fixed$(ana_t[i] - phr_strt, 3))
        Set numeric value: 1, "ana_fo_" + string$(i), round(ana_fo[i])
        @add_graph_data: ana_t[i] - phr_strt, ana_fo[i]
    endfor

	### add data for each foor to table row
    for i to feet
        selectObject: main_table
        Append column: "ft_phon_" + string$(i)
		Append column: "ft_start_" + string$(i)
		Append column: "ft_end_" + string$(i)
		Append column: "word_end_" + string$(i)
		Append column: "str_end_" + string$(i)
		Append column: "voice_on_" + string$(i)
		Append column: "V_St_" + string$(i)
		Append column: "V_End_" + string$(i)
		Append column: "V_Close_" + string$(i)
		Append column: "wrd_fin_syl_S_" + string$(i)
		Append column: "wrd_fin_syl_E_" + string$(i)
        #REMOVED Append column: "ft_dur_" + string$(i)
        #REMOVED Append column: "str_dur_" + string$(i)
        Append column: "L_t_" + string$(i)
        Append column: "L_fo_" + string$(i)
        Append column: "L_st_t_" + string$(i)
        Append column: "L_st_fo_" + string$(i)
        Append column: "L_end_t_" + string$(i)
        Append column: "L_end_fo_" + string$(i)
        Append column: "L_dur_" + string$(i)
        #REMOVED Append column: "L_pc_ft_" + string$(i)
        #REMOVED Append column: "L_pc_wd_" + string$(i)
        #REMOVED Append column: "L_pc_lex_" + string$(i)
        Append column: "L_syl_num_" + string$(i)
        Append column: "L_syl_" + string$(i)
        Append column: "H_t_" + string$(i)
        Append column: "H_fo_" + string$(i)
        Append column: "H_st_t_" + string$(i)
        Append column: "H_st_fo_" + string$(i)
        Append column: "H_end_t_" + string$(i)
        Append column: "H_end_fo_" + string$(i)
        Append column: "H_dur_" + string$(i)
        #REMOVED Append column: "H_pc_ft_" + string$(i)
        #REMOVED Append column: "H_pc_wd_" + string$(i)
        #REMOVED Append column: "H_pc_lex_" + string$(i)
        Append column: "H_word_" + string$(i)
        Append column: "H_syl_num_" + string$(i)
        Append column: "H_syl_" + string$(i)


        ### Get text and timing data for analysis of each foot from textgrid
        selectObject: textgrid
        mid_lex_stress = (foot_start[i] + stress_syll_end[i]) / 2
        lex_word = Get interval at time: ortho_tier, mid_lex_stress
        lex_word$ = Get label of interval: ortho_tier, lex_word
        phono_annot = Get interval at time: phono_tier, mid_lex_stress
        phono_annot$ = Get label of interval: phono_tier, phono_annot
        word_start_t = Get start point: ortho_tier, lex_word
        word_end_t = Get end point: ortho_tier, lex_word
        pk_syll = Get interval at time: syllable_tier, max_t[i]
        pk_syll$ = Get label of interval: syllable_tier, pk_syll
        pk_word = Get interval at time: ortho_tier, max_t[i]
        pk_word$ = Get label of interval: ortho_tier, pk_word
        val_syll = Get interval at time: syllable_tier, min_t[i]
        val_syll$ = Get label of interval: syllable_tier, val_syll

        ### calculate valley and peak timings as a % of lexically stressed syllable,
        ### lexical word,and foot
        #REMOVED val_pc_lex_stress = round((min_t[i] - foot_start[i])
        #REMOVED     ... / (stress_syll_end[i] - foot_start[i])*100)
        #REMOVED val_pc_word =
        #REMOVED     ... round((min_t[i] - word_start_t)/(word_end_t - word_start_t)*100)
        #REMOVED val_pc_foot =
        #REMOVED     ... round((min_t[i] - foot_start[i])/(foot_end[i] - foot_start[i])*100)
        #REMOVED pk_pc_lex_stress = round((max_t[i] - foot_start[i])
        #REMOVED     ... / (stress_syll_end[i] - foot_start[i])*100)
        #REMOVED pk_pc_word = round((max_t[i] - word_start_t)
        #REMOVED     ... / (word_end_t - word_start_t)*100)
        #REMOVED pk_pc_foot = round((max_t[i] - foot_start[i])
        #REMOVED     ... /(foot_end[i] - foot_start[i])*100)

        ### populate current foot of table
        selectObject: main_table
        Set string value: 1, "ft_phon_" + string$(i),
            ... phono_annot$
		Set numeric value: 1, "ft_start_" + string$(i),
		    ... number(fixed$(foot_start[i] - phr_strt, 3))
		Set numeric value: 1, "ft_end_" + string$(i),
		    ... number(fixed$(foot_end[i] - phr_strt, 3))
		Set numeric value: 1, "word_end_" + string$(i),
		    ... number(fixed$(word_end_t - phr_strt, 3))
		Set numeric value: 1, "str_end_" + string$(i),
		    ... number(fixed$(stress_syll_end[i] - phr_strt, 3))
		Set numeric value: 1, "V_St_" + string$(i),
            ... number(fixed$(vStart[i] - phr_strt, 3))
		Set numeric value: 1, "voice_on_" + string$(i),
            ... number(fixed$(voicingOnset[i] - phr_strt, 3))
		Set numeric value: 1, "V_End_" + string$(i),
            ... number(fixed$(vEnd[i]  - phr_strt, 3))
		Set numeric value: 1, "V_Close_" + string$(i),
            ... number(fixed$(vClose[i] - phr_strt, 3))

		Set numeric value: 1, "wrd_fin_syl_S_" + string$(i),
            ... number(fixed$(wordEndSylStart[i]  - phr_strt, 3))
		Set numeric value: 1, "wrd_fin_syl_E_" + string$(i),
            ... number(fixed$(wordEndSylEnd[i] - phr_strt, 3))

        #REMOVED Set numeric value: 1, "ft_dur_" + string$(i),
        #REMOVED     ... number(fixed$(foot_start[i] - phr_strt, 3))
        #REMOVED Set numeric value: 1, "str_dur_" + string$(i),
        #REMOVED     ... number(fixed$(foot_end[i] - phr_strt, 3))
        Set numeric value: 1, "L_t_" + string$(i),
            ... number(fixed$(min_t[i] - phr_strt, 3))
        Set numeric value: 1, "L_fo_" + string$(i),
            ... round(min_val[i])
        Set numeric value: 1, "L_st_t_" + string$(i),
            ... number(fixed$(lo_start[i] - phr_strt, 3))
        Set numeric value: 1, "L_st_fo_" + string$(i),
            ... round(lo_start_fo[i])
        Set numeric value: 1, "L_end_t_" + string$(i),
            ... number(fixed$(lo_end[i] - phr_strt, 3))
        Set numeric value: 1, "L_end_fo_" + string$(i),
            ... round(lo_end_fo[i])
        Set numeric value: 1, "L_dur_" + string$(i), lo_dur[i]
        #REMOVED Set numeric value: 1, "L_pc_ft_" + string$(i), val_pc_foot
        #REMOVED Set numeric value: 1, "L_pc_wd_" + string$(i), val_pc_word
        #REMOVED Set numeric value: 1, "L_pc_lex_" + string$(i), val_pc_lex_stress
        Set numeric value: 1, "L_syl_num_" + string$(i), val_syll-1
		if left$(val_syll$,1) = "_"
            val_syll$ = replace$(val_syll$, "_", "", 1)
        endif
        Set string value: 1, "L_syl_" + string$(i), val_syll$
        Set numeric value: 1, "H_t_" + string$(i),
            ... number(fixed$(max_t[i] - phr_strt, 3))
        Set numeric value: 1, "H_fo_" + string$(i),
             ... round(max_val[i])
        Set numeric value: 1, "H_st_t_" + string$(i),
            ... number(fixed$(hi_start[i] - phr_strt, 3))
        Set numeric value: 1, "H_st_fo_" + string$(i),
            ... round(hi_start_fo[i])
        Set numeric value: 1, "H_end_t_" + string$(i),
            ... number(fixed$(hi_end[i]  - phr_strt, 3))
        Set numeric value: 1, "H_end_fo_" + string$(i),
            ... round(hi_end_fo[i])
        Set numeric value: 1, "H_dur_" + string$(i), hi_dur[i]
        #REMOVED Set numeric value: 1, "H_pc_ft_" + string$(i), pk_pc_foot
        #REMOVED Set numeric value: 1, "H_pc_wd_" + string$(i), pk_pc_word
        #REMOVED Set numeric value: 1, "H_pc_lex_" + string$(i), pk_pc_lex_stress
        Set string value: 1, "H_word_" + string$(i), pk_word$
        Set numeric value: 1, "H_syl_num_" + string$(i), pk_syll-1
		if left$(pk_syll$,1) = "_"
            pk_syll$ = replace$(pk_syll$, "_", "", 1)
        endif
        Set string value: 1, "H_syl_" + string$(i), pk_syll$

        @add_graph_data: min_t[i] - phr_strt, min_val[i]
        @add_graph_data: lo_start[i] - phr_strt, lo_start_fo[i]
        @add_graph_data: lo_end[i] - phr_strt, lo_end_fo[i]
        @add_graph_data: max_t[i] - phr_strt, max_val[i]
        @add_graph_data: hi_start[i] - phr_strt, hi_start_fo[i]
        @add_graph_data: hi_end[i] - phr_strt, hi_end_fo[i]

    endfor
    selectObject: main_table
    Append column: "fin_phon"
    Append column: "fin_t"
    Append column: "fin_fo"

    Set string value: 1, "fin_phon", final_boundary$
    Set numeric value: 1, "fin_t", number(fixed$(fin_t - phr_strt, 3))
    Set numeric value: 1, "fin_fo", round(fin_fo)

    @add_graph_data: fin_t - phr_strt, fin_fo

    ### create and save fo and syllable boundary graph
    @create_fo_syl_graph

    ################################################
    ### save main_table data to appropriate file ###
    ################################################
    ### get full path and file name
    full_file_path$ = reportPath$ + "Analysis_" + sound_code$ + ".Table"
    selectObject: main_table
    no_cols = Get number of columns

    # check if relevantfile already exists
    if fileReadable (full_file_path$) = 0
        # create string with columns headers
        column_headers$ = ""
        for i to no_cols
            cur_col$ = Get column label: i
            column_headers$ = column_headers$ + cur_col$
            if i < no_cols
                column_headers$ = column_headers$ + tab$
            endif
        endfor
        writeFileLine: full_file_path$, column_headers$
    endif

    row_values$ = ""
    for i to no_cols
        cur_col$ = Get column label: i
        cur_val$ = Get value: 1, cur_col$
        row_values$ = row_values$ + cur_val$
        if i < no_cols
            row_values$ = row_values$ + tab$
        endif
    endfor
    appendFileLine: full_file_path$, row_values$

# 	##########################################################
#    ### Create and save PNA_table data to appropriate file ###
#    ########################################'##################

#	#create table with main and PNA info only
#    selectObject: main_table
#	Copy: "PNA"
#	pna_table = selected()
#	noColsPNA = Get number of columns
#	finalColPNA$ = "H_syl_1"

#	endPNA = 0
#	i = 1
#	while endPNA = 0
#		curColPNA$ = Get column label: i
#		if curColPNA$ = finalColPNA$
#			endPNA = i
#		endif
#		i = i + 1
#	endwhile
#
#	noColsPNA = Get number of columns
#	while noColsPNA > endPNA
#	   deleteMe$ = Get column label:  endPNA + 1
#	   Remove column: deleteMe$
#	   noColsPNA = Get number of columns
#	endwhile
#
#	#remove info for each syllable of anacrusis
#	for i to ana_syls
#	Remove column: "ana_t_"+ string$(i)
#	Remove column: "ana_fo_"+ string$(i)
#    endfor
#    #remove general data unnecessary for PNA analysis
#	Remove column: "phr_syls"
#	Remove column: "phr_dur"
#	Remove column: "init_t"
#	Remove column: "init_fo"

#	#remove tone duration info
#	Remove column: "L_st_t_1"
#	Remove column: "L_st_fo_1"
#	Remove column: "L_end_t_1"
#	Remove column: "L_end_fo_1"
#	Remove column: "L_dur_1"
#	Remove column: "H_st_t_1"
#	Remove column: "H_st_fo_1"
#	Remove column: "H_end_t_1"
#	Remove column: "H_end_fo_1"
#	Remove column: "H_dur_1"


#   ### get full path and file name
#    full_file_path$ = reportPath$ + "PNA_Analysis_" + sound_code$ + ".Table"
#
#    selectObject: pna_table
#    no_cols = Get number of columns

#   ### NB STARTING HERE: THIS IS DUPLICATE CODE AND SHOULD BE A PROCEDURE
#    # check if relevantfile already exists
#   if fileReadable (full_file_path$) = 0
#        # create string with columns headers
#        column_headers$ = ""
#        for i to no_cols
#            cur_col$ = Get column label: i
#            column_headers$ = column_headers$ + cur_col$
#            if i < no_cols
#                column_headers$ = column_headers$ + tab$
#            endif
#        endfor
#        writeFileLine: full_file_path$, column_headers$
#    endif

#    row_values$ = ""
#    for i to no_cols
#        cur_col$ = Get column label: i
#        cur_val$ = Get value: 1, cur_col$
#        row_values$ = row_values$ + cur_val$
#        if i < no_cols
#            row_values$ = row_values$ + tab$
#        endif
#    endfor
#    appendFileLine: full_file_path$, row_values$
#    ### NB ENDING HERE: THIS IS DUPLICATE CODE AND SHOULD BE A PROCEDURE


    ########################################
    ### Save updated textgrid and tables ###
    ########################################
    selectObject: textgrid
    @move_comments_to_bottom
    Save as text file: directory$ + soundName$ + ".TextGrid"


    ########################################
    ### Remove current surplus artifacts ###
    ########################################
    plusObject: pitchtrack
	plusObject: pitchTier
    plusObject: orig_pitchtrack
    plusObject: pitchsound
    plusObject: soundobject
    plusObject: textgrid
    plusObject: main_table
#	plusObject: pna_table
    plusObject: graph_table
    plusObject: syl_table

    Remove

endproc

### add to InfoLine and Report ###
procedure reportUpdate: .reportFile$, .lineText$
    appendInfoLine: .lineText$
    appendFileLine: .reportFile$, .lineText$
endproc

### find first defined value near to defined value ###
procedure defined_fo: .object, .time, .time_step, .wiggle_room
### adjust current_mid_point to find first defined fo value (prefers right over left)
    selectObject: .object
    .current_LR = .time_step
    .fo = Get value at time: .time, "Hertz", "Linear"
    while .fo = undefined and .time - .current_LR >= .current_LR - .wiggle_room
        .cur_fo_L = Get value at time: .time - .current_LR, "Hertz", "Linear"
        .cur_fo_R = Get value at time: .time + .current_LR, "Hertz", "Linear"
            if .cur_fo_R <> undefined
                .time = .time + .current_LR
                .fo = .cur_fo_R
            elsif .cur_fo_L <> undefined
                .time = .time - .current_LR
                .fo = .cur_fo_L
            else
                .current_LR = .current_LR + .time_step
            endif
    endwhile
endproc

### find first defined value near to boundary ###
procedure boundary_fo: .object, .time, .time_step

### adjust current_point to find first defined fo value (prefers right over left)
    selectObject: .object
    .fo = Get value at time: .time, "Hertz", "Linear"
    while .fo = undefined
        .time = .time + .time_step/10
        .fo = Get value at time: .time, "Hertz", "Linear"
    endwhile
endproc

### Calculate moving point average ###
procedure calc_mpa: .mpa_size, .table_object, .input_col$, .output_col$
    selectObject: .table_object
    .total_points = Get number of rows
    .mpa_lr = floor (.mpa_size/2)
    Append column: .output_col$
    for .current_point to .total_points
        ## calculate correct number of points to include to l and r of current point
        if .current_point <= .mpa_lr
            .cur_mpa_lr = .current_point - 1
        elsif .total_points - .current_point < .mpa_lr
            .cur_mpa_lr = .total_points - .current_point
        else
            .cur_mpa_lr = .mpa_lr
        endif
        .total = 0
        .n = .cur_mpa_lr * 2 + 1
        for .add_these from (.current_point - .cur_mpa_lr)
            ... to (.current_point + .cur_mpa_lr)
            .cur_fo = Get value: .add_these, .input_col$
            if .cur_fo  <> undefined
                .total = .total + .cur_fo
            else
                .n = .n - 1
            endif
        endfor
        Set numeric value: .current_point, .output_col$, round(.total/.n)
    endfor
endproc

# Update point label: create if none exists, appends if it does
procedure update_point_label: .tier_no, .check_T, .label$, .object_no
    selectObject: .object_no
    .close_index = Get nearest index from time: .tier_no , .check_T
    if .close_index > 0
        .poss_clash_T = Get time of point: .tier_no, .close_index
        if round(.check_T*1000) = round(.poss_clash_T*1000)
            .check_T = .poss_clash_T
            .clash_label$ = Get label of point: .tier_no, .close_index
            .label$ = .label$ + "." + .clash_label$
            Set point text: .tier_no, .close_index, .label$
        else
            Insert point: .tier_no, .check_T, .label$
        endif
    else
        Insert point: .tier_no, .check_T, .label$
    endif
endproc

### empty tier if it is non-emtpy ###
procedure clear_tier: .textgrid, .tier
    selectObject: .textgrid
    cur_name$ = Get tier name: .tier
    .is_interval_tier = Is interval tier: .tier
    if .is_interval_tier = 0
        .num_points = Get number of points: .tier
        if .num_points > 0
            text$ =  "   - Point tier '" + cur_name$ +
                ... "' being overwritten in textgrid."
            @reportUpdate: reportFilePath$, text$
            Remove points: .tier, "does not start with",
                ... "highly unlikely contents"
        endif
    else
        .num_intervals = Get number of intervals: .tier
        if .num_intervals > 0
            text$ =  "   - Interval tier '" + cur_name$
                ... + "' being overwritten in textgrid."
            for .i to .num_intervals - 1
              Remove left boundary: .tier, 2
            endfor
            Set interval text: .tier, 1, ""
        endif
    endif
endproc

### remove old tiers generated except ortho, syllable, rhythm, phon, and comments tier
procedure remove_old_tiers
    num_tiers = Get number of tiers
    while num_tiers > 0
        cur_tier_name$ = Get tier name: num_tiers
        if cur_tier_name$ <> syllabic$
            ... and cur_tier_name$ <> rhythmic$
            ... and cur_tier_name$ <> comments$
            ... and cur_tier_name$ <> orthographic$
            ... and cur_tier_name$ <> phonological$
			... and cur_tier_name$ <> vowel_info$
            text$ = "   - Removing tier #" + string$(num_tiers ) + " called "
                ... + cur_tier_name$
            @reportUpdate: reportFilePath$, text$
            Remove tier: num_tiers
        endif
        num_tiers = num_tiers - 1
    endwhile
endproc

### move comments tier to the bottom tier
procedure move_comments_to_bottom
    num_tiers = Get number of tiers
    cur_tier = num_tiers
    found_comments = 0
    while cur_tier > 0
        cur_tier_name$ = Get tier name: cur_tier
        if cur_tier_name$ = comments$
            Duplicate tier: cur_tier, num_tiers + 1, comments$
            Remove tier: cur_tier
            cur_tier = 0
        else
            cur_tier = cur_tier - 1
        endif
    endwhile
endproc

### add to time and fo value to graph table
procedure add_graph_data: t_val, fo_val
    selectObject: graph_table
	if fo_val <> undefined
        Append row
        cur_graph_row = cur_graph_row + 1
        Set numeric value: cur_graph_row, "t", number(fixed$(t_val, 3))
        Set numeric value: cur_graph_row, "fo", round(fo_val)
    endif
endproc

#hertz to semitones re ref hz
procedure hz2: .hz_act, .hz_ref
    .st = 12*log2(.hz_act/.hz_ref)
endproc

### Create fo trace graph with syllable boundaries marked
procedure create_fo_syl_graph
    Erase all
    Select outer viewport: 0, 6, 0, 4
    selectObject: graph_table
    Sort rows: "t"

    ### convert Hz to ST based on central fo
    @add_semitone_column: graph_table

    ###draw fo traces
    #get x and y ranges
    y_min = min_fo - 5
    y_max = max_fo
    x_min = number(fixed$(phr_strt, 3))
    x_max = x_min + ceiling(phr_dur*10)/10
    #draw original fo trace
    selectObject: orig_pitchtrack
    Line width: 0.5
    Dashed line
    Colour: "Grey"
    Draw: x_min, x_max, y_min, y_max, "no"
    #draw corrected fo trace
    selectObject: pitchtrack
    Line width: 0.5
    Dashed line
    Colour: "red"
    Draw: x_min, x_max, y_min, y_max, "no"

    ### Draw stylized intonation contour (using H and L points and effective durations)
    selectObject: graph_table
    Font size: 10
    Solid line
    Colour: "Blue"
    x_min = 0
    # set x max point to include tick mark for next point after phrase end
    x_max = ceiling(phr_dur*10)/10
    y_min = min_fo - 5
    y_max = max_fo
    pen_size = 1
    Scatter plot (mark): "t", x_min, x_max, "fo", y_min, y_max, pen_size, "no", "o"
    Scatter plot (mark): "t", x_min, x_max, "fo", y_min, y_max, pen_size, "no", "x"
    Scatter plot (mark): "t", x_min, x_max, "fo", y_min, y_max, pen_size/2, "no", "o"


    # draw lines between each data point on the x-y axes using the graph_table data
    Line width: 1.5
	for k to feet
        for i from ana_syls+1 + 6*(k-1) to  ana_syls+5+6*(k-1)
            x0 = Get value: i, "t"
            x1 = Get value: i + 1, "t"
            y0 = Get value: i, "fo"
            y1 = Get value: i + 1, "fo"
            Draw line: x0, y0, x1, y1
		endfor
    endfor

    ### draw syllable lines
    Font size: 10
    Solid line
    Colour: "Black"
    Dotted line
    Line width: 1
    selectObject: syl_table
    no_rows = Get number of rows
    syl_text_y = max_hz + 10
    for i to no_rows
        x0 = Get value: i, "tmin"
        x1 = Get value: i, "tmax"
        syl_text$ = Get value: i, "text"
        syl_text_x = (x1 + x0)/2 - phr_strt
        Draw line: x0  - phr_strt, min_fo - 5 , x0  - phr_strt, max_fo
        Text: syl_text_x, "Centre", min_fo, "Half", syl_text$
    endfor
    Draw line: x1 - phr_strt, min_fo - 5, x1  - phr_strt, max_fo

    ### draw margin info`
    Colour: "Black"
    Font size: 10
    Solid line
    Line width: 1
    temp$ = replace$(soundName$, "_", " ", 0)
    title$ = sentence$ + " (" + temp$ + ")"
    Marks bottom every: 1, 0.1, "yes", "yes", "no"
    Marks left every: 1, 10, "yes", "yes", "no"
    Draw inner box
    Text left: "yes", "fo (Hz)"
    Text top: "no", title$
    Text bottom: "yes", "time (secs)"

    if drawLegend = 1
        @draw_legend
    endif

    full_image_path$ = imagePath$ + soundName$ + ".png"
    Save as 600-dpi PNG file: full_image_path$

    selectObject: graph_table
    Save as tab-separated file: imagePath$ + soundName$ + "_graph.Table"
    selectObject: syl_table
    Save as tab-separated file: imagePath$ + soundName$ + "_syl.Table"
    text$ = "   - Stylized contour graph and associated tables saved to "
           ... + image_dir$ + " folder."
    @reportUpdate: reportFilePath$, text$
endproc

### Draw Legend
procedure draw_legend
    ### Draw Legend
    Paint rectangle: "white", 0.1, 0.35, max_fo - 10,  max_fo - 40
    Draw rectangle: 0.1, 0.35, max_fo - 10,  max_fo - 40
    Text: 0.19, "Left", max_fo - 16, "Half", "original f_o"
    Text: 0.19, "Left", max_fo - 25, "Half", "corrected f_o"
    Text: 0.19, "Left", max_fo - 34, "Half", "stylised f_o"
    #original fo trace
    Line width: 0.5
    Dashed line
    Colour: "Grey"
    Draw line: 0.11, max_fo - 16 , 0.18, max_fo - 16
    # corrected fo trace
    Line width: 0.5
    Dashed line
    Colour: "red"
    Draw line: 0.11, max_fo - 25 , 0.18, max_fo - 25
    # stylized intonation contour
    Line width: 1
    Solid line
    Colour: "Blue"
    Draw line: 0.11, max_fo - 34 , 0.18, max_fo - 34
endproc



procedure create_syl_table: .textgrid, .syllable_tier
    selectObject: .textgrid
    Extract one tier: .syllable_tier
    .temp_grid = selected ()
    Down to Table: "no", 3, "no", "no"
    .syl_table = selected ()
    selectObject: .temp_grid
    Remove
endproc

### convert Hz to ST based on lowest fo in phrase
procedure add_semitone_column: graph_table_name
    selectObject: graph_table_name
    max_hz = Get maximum: "fo"
    min_hz = Get minimum: "fo"
    #ref_hz = (max_hz + min_hz) / 2
	ref_hz = min_hz
    Append column: "semitones"
    no_rows = Get number of rows
    for i to no_rows
        cur_hz = Get value: i, "fo"
        @hz2: cur_hz, ref_hz
        Set numeric value: i, "semitones", hz2.st
    endfor
endproc
