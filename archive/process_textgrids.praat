# ANALYSIS OF TEXTGRIDS AND PITCH CONTOURS V.2.0.3
# ================================================
# Written for Praat 6.0.36

# Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# latest update: 28/01/2020

# Script Purpose
# This script is designed to extract data from pre-annotated textgrids
# (and pitch tier objects) in spectified directories. It is intended to be used
# after:
#     1. annotating the textgrids created by the "create_more_tiers" script; or
#     2. running the "acoustic_annotations" script
# It requires a list of all the target directories saved in a .txt file

# Version 2 Notes
# V2 has been written to minimise the amount of number crunching done in praat,
# with the burden of this being done in R instead.
# This is to facilitiate transparency.
#
# main changes:
#     1. Table columns renamed so rightmost text states measurement type.
#     2. Unused columns no longer included in table, but still calculated in
#        script; e.g., rhythm normalised times no longer saved to table.
#     3. All actual times output re utterance start (i.e. from 0)
#     4. V.2.0.1: Epdated syl_normT estimations - each of these is now
#                 normalised to a grand mean syllable time in ms for each
#                 stim_metre pairing.
#                 Added v/l/h_syl_ratio column to show target as a proportion
#                 of the syllable.
#     5. V.2.0.2: Removed "include allProcs.praat" line, and replaced it with
#                 relevant procedures from libraries. (Makes script portable.)
#

# GET USER INPUT ---------------------------------------------------------------
form Analysis of TextGrids and Pitch contours
    choice corpus_to_analyse 3
        button alignment
        button focus
        button sentence modes
        #button continuation
    optionmenu Analysis_set: 1
        option Analysis set one (original)
        option Analysis set two (STH hypothesis)
endform
# Get start time in seconds
@seconds: "started"

# PROCESS USER INPUT
# Get input directory and output file names.
if corpus_to_analyse = 1
    corpus_to_analyse$ = "alignment and H_Placement"
    batchFile$ = "a_corpus"
elsif corpus_to_analyse = 2
    corpus_to_analyse$ = "focus"
    batchFile$ = "f_corpus"
elsif corpus_to_analyse = 3
    batchFile$ = "m_corpus"
    corpus_to_analyse$ = "sentence_modes"
else
    corpus_to_analyse = 4
    corpus_to_analyse$ = "continutation"
    batchFile$ = "c_corpus"
endif

# DEFINE KEY VARIABLES ---------------------------------------------------------

@globalDictionaries
root$ = root_G$ + "/" + analysis_G$[analysis_set]
corpusArchiveDir$ = "_Corpus archive"

# Define directory list by individual folders in root directory.
dir_list = Create Strings as tokens: "", " ,"
Insert string: 0, root$ + "/" + "F5"
Insert string: 0, root$ + "/" + "F6"
Insert string: 0, root$ + "/" + "F12"
Insert string: 0, root$ + "/" + "F15"
Insert string: 0, root$ + "/" + "F16"
Insert string: 0, root$ + "/" + "F17"
Insert string: 0, root$ + "/" + "M4"
Insert string: 0, root$ + "/" + "M5"
Insert string: 0, root$ + "/" + "M8"
Insert string: 0, root$ + "/" + "M9"
Insert string: 0, root$ + "/" + "M10"
num_dirs = Get number of strings

# Define tier names (previously part of UI form in V.1).
orthographic$ = "ortho"
syllabic$ = "syllable"
rhythmic$ = "rhythmic"
phonological$ = "phono"
vowel_info$ = "vowel"
tone$ = "tone"
high_tone_duration$ = "HDur"
low_tone_duration$ = "LDur"

# Define/create output directories.
@date
createDirectory: root$ + "/" +  corpusArchiveDir$
outputFileAddressArchive$ = root$ + "/" + corpusArchiveDir$ + "/"
                      ... + batchFile$ + "_" + (date.index$) + ".csv"
outputFileAddress$ = root$ + "/" +  batchFile$ + ".Table"

# Create empty output table.
id_data$ = "code speaker gender stim rep sent metre_ID stim_metre "
grid_basics$ = "tot_syls ana_syls "
    ... + "tot_feet cur_foot foot_syls wrd_end_syl "
    ... + "acc_phon phr_phon init_phon fin_phon v_text "
grid_times$ = "phr_strt_t phr_end_t ana_end_t "
    ... + "foot_strt_t foot_end_t stress_end_t wrd_fin_syl_strt_t wrd_end_t "
    ... + "v_onset_t v_offset_t "
alignment_data$ = "strt_t end_t l_t h_t "
    ... + "l_syl_strt_t l_syl_end_t "
    ... + "h_syl_strt_t h_syl_end_t "
    ... + "v_sylNormT l_sylNormT h_sylNormT "
    ... + "v_syl l_syl h_syl "
    ... + "v_syl_ratio l_syl_ratio h_syl_ratio "
f0_data$ =
    ... "s_f0 e_f0 v_onset_f0 l_f0 h_f0 slope_st intercept_st mean_st med_st "

output_table = Create Table with column names: "output", 0,
    ... id_data$
    ... + grid_basics$
    ... + grid_times$
    ... + alignment_data$
    ... + f0_data$
    ... + "location"

# PROCESS TEXTGRIDS AND PITCH FILES -------------------------------------------

# Processs each directory.
for dir_i to num_dirs
    writeInfoLine: mid$(date$(), 12, 8), " Reading data for directory ",
    ... dir_i, "/", num_dirs, "."
    selectObject: dir_list
    cur_dir$ = Get string: dir_i
    cur_dir$ = cur_dir$ + "/" + corpus_to_analyse$ + "/"
    cur_fileList =  Create Strings as file list: "fileList" + string$(dir_i),
        ... cur_dir$ + "*.TextGrid"
    num_TextGrids = Get number of strings

    # Processs textgrid and pitch files in each directory.
    for j to num_TextGrids
        # Get current textgrid and pitch objects
        selectObject: cur_fileList
        cur_TextGrid$ = Get string: j
        cur_textGrid = Read from file: cur_dir$ + cur_TextGrid$
        cur_address$ = replace$(cur_dir$, ".textGrid", "", 0)
        cur_PitchName$ = cur_dir$ + "pitch/PF_" + selected$ ("TextGrid")
            ... + ".Pitch"
        cur_pitch = Read from file: cur_PitchName$

        # Get tier numbers for current grid (non-existent tier = 0)
        @getTierIndices: cur_textGrid

        # Process reference data.
        selectObject: cur_textGrid
        cur_textGrid$ = selected$("TextGrid")
        mrk1 = index (cur_textGrid$, "_")
        mrk2 = rindex (cur_textGrid$, "_")
        speaker$ = left$(cur_textGrid$, mrk1 - 1)
        gender$ = left$(cur_textGrid$, 1)
        stim$ = mid$(cur_textGrid$, mrk1 + 1, mrk2 - mrk1 - 1)
        rep$ = right$(cur_textGrid$, length(cur_textGrid$) - mrk2)

        # Process tiers.
        @processRhythmTier: cur_textGrid
        @processSyllableTier: cur_textGrid
        @processPhonoTier: cur_textGrid
        @processOrthoTier: cur_textGrid
        @processVowelTier: cur_textGrid, cur_pitch
        @processToneTier: cur_textGrid, cur_pitch
        # Calculate alignment info
        @calculateAlignmentData

        @populateTable

        # remove current pitch, textgrid, tier and table objects
        selectObject: cur_textGrid
        plusObject: cur_pitch
        plusObject: syl_tier
        plusObject: syl_table
        plusObject: rhythm_tier
        plusObject: rhy_table
        plusObject: phono_tier
        plusObject: phono_table
        plusObject: ortho_tier
        plusObject: ortho_table
        plusObject: vowel_tier
        plusObject: vowel_table
        plusObject: tone_tier
        plusObject: tone_table
        endif
        Remove
    endfor

    # remove current file list
    selectObject: cur_fileList
    Remove
endfor

# OUTPUT -----------------------------------------------------------------------

# Tidy table
appendInfoLine: mid$(date$(), 12, 8),
    ... " Calculating grand-mean syllable-normalised times."

# Convert syllable-normalised time to grand-mean syllable-normalised time
@grandMeanSylTime: output_table, root$, corpusRef_G$[corpus_to_analyse]

# Convert times to ms using phr_strt_t as t=0. Couldn't do this tidily in R!
selectObject: output_table
Formula (column range): "phr_end_t", "h_syl_end_t",
    ... "fixed$((self - self[""phr_strt_t""]) * 1000, 0)"
Remove column: "phr_strt_t"
Formula (column range): "v_sylNormT", "h_sylNormT", "fixed$(self * 1000, 0)"

# convert F0 to ST re 1 Hz using. Couldn't do this tidily in R!
Formula (column range): "s_f0", "h_f0", "fixed$(12 * log2(self), 2)"
Formula (column range): "mean_st", "med_st", "fixed$(self, 2)"

# round syllable ratio values to two decimal places
Formula (column range): "v_syl_ratio", "h_syl_ratio", "fixed$(self, 2)"

# Calculate end time before user intervention.
@seconds: "ended"

# Save data
appendInfoLine: mid$(date$(), 12, 8), " Saving batch data."
selectObject: output_table
Save as comma-separated file: outputFileAddressArchive$
Save as tab-separated file: outputFileAddress$
saveToDir$ = chooseDirectory$: "Choose a CSV database output directory"
Save as comma-separated file: saveToDir$ + "/" +  batchFile$ + ".csv"

# Remove remaining objects
selectObject: dir_list
plusObject: output_table
plusObject: dir_list
Remove

# Timing Info
if ended < started
    totSecs = ended + 86400 - started
else
    totSecs = ended - started
endif
appendInfoLine: mid$(date$(), 12, 8), " Finished in ", totSecs, " seconds."
exit

# PROCEDURES -------------------------------------------------------------------
procedure getTierIndices: .textgrid
    selectObject: .textgrid
    ortho_tier_num = 0
    syl_tier_num  = 0
    rhythm_tier_num = 0
    phono_tier_num = 0
    vowel_tier_num = 0
    tone_tier_num = 0
    h_dur_tier_num = 0
    l_dur_tier_num = 0
    # get information about existing tiers
    num_tiers = Get number of tiers
    for .i to num_tiers
        tier_name$ = Get tier name: .i
        if tier_name$ = syllabic$
            @checkForValidTier: .textgrid, .i, "I"
            syl_tier_num = result
        elsif tier_name$ = orthographic$
            @checkForValidTier: .textgrid, .i, "I"
            ortho_tier_num = result
        elsif tier_name$ = rhythmic$
            @checkForValidTier: .textgrid, .i, "P"
            rhythm_tier_num = result
        elsif tier_name$ = phonological$
            @checkForValidTier: .textgrid, .i, "I"
            phono_tier_num = result
        elsif tier_name$ = vowel_info$
            @checkForValidTier: .textgrid, .i, "I"
            vowel_tier_num = result
        elsif tier_name$ = tone$
            @checkForValidTier: .textgrid, .i, "P"
            tone_tier_num = result
        elsif tier_name$ = high_tone_duration$
            @checkForValidTier: .textgrid, .i, "I"
            h_dur_tier_num = result
        elsif tier_name$ = low_tone_duration$
            @checkForValidTier: .textgrid, .i, "I"
            l_dur_tier_num = result
        endif
    endfor
endproc

procedure checkForValidTier: .textgrid, .inputTierNum, .tierType$
    selectObject: .textgrid
    if left$(.tierType$, 1) = "i" or left$(.tierType$, 1) = "I"
        .emptyTest = Get number of intervals: .inputTierNum
    else
        .emptyTest = Get number of points: .inputTierNum
    endif
    .emptyTest = .emptyTest > 0
    result = .inputTierNum * .emptyTest
endproc

procedure processRhythmTier: .textGrid
    #convert rhythm tier to table
    selectObject: .textGrid
    Extract one tier: rhythm_tier_num
    rhythm_tier = selected()
    Down to Table: "no", 3, "no", "no"
    rhy_table = selected()

    selectObject: rhy_table
    num_rows = Get number of rows

    # get phrase start and end
    phr_strt = Get value: 1, "tmin"
    phr_end = Get value: num_rows, "tmin"
    tot_feet = 0
    boundaries = 0

    # get start time of each foot: foot_strt[#]
    # get duration of each stressed syllable:  foot_stress_dur[#]
    for .i to num_rows
        rhy_time_cur = Get value: .i, "tmin"
        rhy_text_cur$ = Get value: .i, "text"
        # remove accidental table
        rhy_text_cur$ =
            ... replace$(replace$(rhy_text_cur$, tab$, "", 0), newline$, "", 0)
        for .j to length(rhy_text_cur$)
            char_cur$= mid$ (rhy_text_cur$, .j, 1)
            if char_cur$ = "<"
                tot_feet += 1
                foot_strt[tot_feet] = rhy_time_cur
                stress_end[tot_feet] = Get value: .i + 1, "tmin"
                foot_stress_dur[tot_feet] = stress_end[tot_feet] - rhy_time_cur
                foot_strt[tot_feet] = rhy_time_cur
            elsif char_cur$ = "%"
                boundaries += 1
                if boundaries = 1
                    init_phono$ = replace$(rhy_text_cur$, "<", "", 0)
                else
                    fin_phono$ =  replace$(rhy_text_cur$, ">", "", 0)
                endif
            endif
        endfor
    endfor

    # get duration of each foot: foot_dur[#]
    for .i to tot_feet - 1
        foot_dur[.i] = foot_strt[.i+1] - foot_strt[.i]
        foot_end[.i] = foot_strt[.i+1]
    endfor
    foot_dur[tot_feet] =  (phr_end) - foot_strt[tot_feet]
    foot_end[tot_feet] = phr_end
    # get anacrusis and phrase duration
    ana_end_t = foot_strt[1]
    phr_dur =  phr_end - phr_strt
endproc

procedure processSyllableTier: .textGrid
    # convert syllable tier to table
    selectObject: .textGrid
    Extract one tier: syl_tier_num
    syl_tier = selected()
    Down to Table: "no", 3, "no", "no"
    syl_table = selected()

    selectObject: syl_table
    # get number of syllables
    num_syls = Get number of rows

    # get start time of each syllable: syl_strt[#]
    # check number of syllables of anacrusis: ana_syls[#]
    ana_syls = 0
    cur_foot = 0
    foot_one_start = foot_strt[1]
    stress_one_end = foot_strt[1] + foot_stress_dur[1]
    for i to num_syls
        cur_syl_strt = Get value: i, "tmin"
        cur_syl_end_t = Get value: i, "tmax"
        cur_syl_mid = (cur_syl_end_t + cur_syl_strt) / 2

        # check if current syllable is part of anacrusis
        if cur_syl_mid < foot_one_start
            ana_syls += 1
        # else check if current syllable is 1st stressed syllable of 1st foot
        elsif cur_syl_mid > foot_one_start and
                ... cur_syl_mid < stress_one_end
            cur_foot = 1
            foot_syls[cur_foot] = 1

        # else check if current syllable is start of a new foot
        elsif cur_syl_mid >
            ... foot_strt[cur_foot] + foot_dur[cur_foot]
            cur_foot += 1
            foot_syls[cur_foot] = 1

        # otherwise assume curr syllable is part of current foot
        else
            foot_syls[cur_foot] += 1
        endif
        # get foot identity of each syllable: syl_foot_ID[#]
        syl_foot_ID[i] = cur_foot
        # get duration of each syllable: syl_dur[#]
        syl_dur[i] = cur_syl_end_t - cur_syl_strt
        syl_strt[i] = cur_syl_strt
    endfor

    metrical_ID = ana_syls
    for m_index to cur_foot
        metrical_ID += foot_syls[m_index] * 10^m_index
    endfor
    metrical_ID$ = ""
    m_ID_len = length(string$(metrical_ID))
    for m_index to m_ID_len
           metrical_ID$ += mid$(string$(metrical_ID), m_ID_len - m_index + 1, 1)
    endfor
endproc

procedure processPhonoTier: .textGrid
    # convert syllable tier to table
    selectObject: .textGrid
    Extract one tier: phono_tier_num
    phono_tier = selected()
    Down to Table: "no", 3, "no", "no"
    phono_table = selected()

    # get accent type: accent$[#]
    selectObject: phono_table
    num_rows = Get number of rows
    phr_phono$ = init_phono$
    for i to num_rows
        cur_accent$ = Get value: i, "text"
        accent$[i] =
            ... replace$(replace$(cur_accent$, tab$, "", 0), newline$, "", 0)
        phr_phono$ = phr_phono$ + " " + cur_accent$
    endfor
    phr_phono$ = replace$(replace$(phr_phono$ + " " + fin_phono$, tab$, "", 0),
        ... newline$, "", 0)
endproc

procedure processOrthoTier: .textGrid
    # convert ortho tier to table
    selectObject: .textGrid
    Extract one tier: ortho_tier_num
    ortho_tier = selected()
    Down to Table: "no", 6, "no", "no"
    ortho_table = selected()
    num_words = Get number of rows

    #get sentence
    cur_sent$ = Get value: 1, "text"
    for i from 2 to num_words
        cur_word$ = Get value: i, "text"
        cur_sent$ = replace$(replace$(cur_sent$ + " " + cur_word$, tab$, "", 0),
            ... newline$, "", 0)
    endfor

    #get word end boundaries
    for i to tot_feet
        selectObject: ortho_tier
        mid_lex_stress = foot_stress_dur[i] / 2 + foot_strt[i]
        lex_word = Get interval at time: 1, mid_lex_stress
        lex_word$[i] = Get label of interval: 1, lex_word
        word_start_t = Get start point: 1, lex_word
        word_end_t = Get end point: 1, lex_word

       selectObject: syl_tier
       word_fin_syll = Get low interval at time: 1, word_end_t - 0.001
       foot_first_syl = Get low interval at time: 1, mid_lex_stress
       wrd_fin_syl_strt_t[i] = Get start time of interval: 1, word_fin_syll
       wrd_end_t[i] = word_end_t
       wrd_end_syl[i] = word_fin_syll - foot_first_syl + 1
    endfor
endproc

procedure processVowelTier: .textGrid, .pitchObject
    # convert vowel tier to table
    selectObject: .textGrid
    vowel_tier = Extract one tier: vowel_tier_num
    vowel_table = Down to Table: "no", 3, "no", "no"
    vowel_rows = Get number of rows
    for cur_foot to tot_feet
        # add vowel info
        for i to vowel_rows
            selectObject: vowel_table
            vowelText$ = Get value: i, "text"
            # remove accidental tabs and carriage returns
            curVowelText$ = replace$(replace$(vowelText$, tab$, "", 0),
                ... newline$, "", 0)
            curStartTime = Get value: i, "tmin"
            curEndTime = Get value: i, "tmax"
            # add vowel info if foot number is valid

            if curStartTime >= foot_strt[cur_foot]
                        ... and curEndTime <=
                        ... foot_strt[cur_foot] + foot_stress_dur[cur_foot]
                v_onset[cur_foot] = curStartTime
                v_offset[cur_foot] = curEndTime
                v_text$[cur_foot] = curVowelText$
                @getPitchAtTime: .pitchObject, v_onset[cur_foot]
                v_onset_f0[cur_foot] = result
            endif
        endfor
    endfor
endproc

procedure processToneTier: .textGrid, .pitchObject
    # convert phono tier to table
    selectObject: .textGrid
    Extract one tier: tone_tier_num
    tone_tier = selected()
    Down to Table: "no", 3, "no", "no"
    tone_table = selected()

    selectObject: tone_table
    num_rows = Get number of rows
    for i to num_rows
        selectObject: tone_table
        cur_text$ = Get value: i, "text"
        cur_time = Get value: i, "tmin"
        foot_ref$ = right$(cur_text$,1)
        if left$(cur_text$, 1) = "L"
            l_t[number(foot_ref$)] = cur_time
            @getPitchAtTime: .pitchObject, cur_time
            l_f0[number(foot_ref$)] = result
        elsif left$(cur_text$, 1) = "H"
            h_t[number(foot_ref$)] = cur_time
            @getPitchAtTime: .pitchObject, cur_time
            h_f0[number(foot_ref$)] = result
        elsif left$(cur_text$, 1) = "S"
            strt_t = cur_time
            @get_nearest_f0: .pitchObject, cur_time, 0.01
            strt_t = get_nearest_f0.time
            s_f0 = get_nearest_f0.fo
        elsif left$(cur_text$, 1) = "E"
            end_t = cur_time
            @get_nearest_f0: .pitchObject, cur_time, -0.01
            end_t = get_nearest_f0.time
            e_f0 =get_nearest_f0.fo
        endif
    endfor

    # Get intercept & slope of linear regression between L & H in each foot
    for i to tot_feet
        l_t_cur = l_t[i]
        h_t_cur = h_t[i]
        @getAccLinear: l_t_cur, h_t_cur, .pitchObject
        slope_st[i] = getAccLinear.slope_st
        intercept_st[i] = getAccLinear.intercept_st
        mean_f0[i] = getAccLinear.mean_f0
        med_st[i] = getAccLinear.med_st
    endfor
endproc

procedure calculateAlignmentData
    cur_syl_strt = ana_syls
    # get H, L, and V-onset times normalised to rhythm
    for cur_foot to tot_feet
        cur_foot_start = foot_strt[cur_foot]
        cur_stress_dur = foot_stress_dur[cur_foot]
        cur_foot_dur = foot_dur[cur_foot]
        cur_foot_syls = foot_syls[cur_foot]
        cur_l_t = l_t[cur_foot]
        cur_h_t = h_t[cur_foot]
        cur_v_onset = v_onset[cur_foot]
        unstressed_denom = (cur_foot_dur - cur_stress_dur)

        # Get times normalised to rhythm
        if cur_l_t < cur_stress_dur
            l_rhy_norm[cur_foot] = cur_l_t / cur_stress_dur
        else
            l_rhy_norm[cur_foot] = 1 + (cur_l_t - cur_stress_dur)
                ... / unstressed_denom
        endif
        if cur_h_t < cur_stress_dur
            h_rhy_norm[cur_foot] = cur_h_t / cur_stress_dur
        else
            h_rhy_norm[cur_foot] = 1 + (cur_h_t - cur_stress_dur)
                ... / unstressed_denom
        endif
        if cur_v_onset < cur_stress_dur
            v_rhy_norm[cur_foot] = cur_v_onset / cur_stress_dur
        else
            v_rhy_norm[cur_foot] = 1 + (cur_v_onset - cur_stress_dur)
                ... / unstressed_denom
        endif

        # Get times normalised to syllables
        for i to foot_syls[cur_foot]
            cur_syl = cur_syl_strt + i
            cur_syl_l_edge = syl_strt[cur_syl]
            cur_syl_r_edge = syl_strt[cur_syl]
                ... + syl_dur[cur_syl]
            if cur_l_t >= cur_syl_l_edge and cur_l_t <= cur_syl_r_edge
                l_syl_num[cur_foot] = cur_syl
                l_syl_strt[cur_foot] = cur_syl_l_edge
                l_syl_end[cur_foot] = cur_syl_r_edge
                l_syl_ratio[cur_foot] = (cur_l_t - cur_syl_l_edge) /
                    ... (cur_syl_r_edge - cur_syl_l_edge)
            endif
            if cur_h_t >= cur_syl_l_edge and cur_h_t <= cur_syl_r_edge
                h_syl_num[cur_foot] = cur_syl
                h_syl_strt[cur_foot] = cur_syl_l_edge
                h_syl_end[cur_foot] = cur_syl_r_edge
                h_syl_ratio[cur_foot] = (cur_h_t - cur_syl_l_edge) /
                    ... (cur_syl_r_edge - cur_syl_l_edge)
            endif
            if cur_v_onset >= cur_syl_l_edge and cur_v_onset <= cur_syl_r_edge
                v_syl_num[cur_foot] = cur_syl
                v_syl_ratio[cur_foot] = (cur_v_onset - cur_syl_l_edge) /
                    ... (cur_syl_r_edge - cur_syl_l_edge)
            endif
        endfor
        cur_syl_strt += foot_syls[cur_foot]
    endfor

    # Get  times of L, H, and V relative to the current foot
    for i to tot_feet
        l_t_ft[i] = l_t[i]
        h_t_ft[i] = h_t[i]
        v_t_ft[i] = v_onset[i]
        v_off_ft[i] = v_offset[i]
    endfor
endproc

procedure getAccLinear: .l_t, .h_t, .pitchObj
    # Calculates libear regression of pitch curve between T*  +T

    #convert target pitch object to table
    selectObject: .pitchObj
    @pitch2Table: .pitchObj, 0
    .pitchTable = pitch2Table.table

    #keep only rows between l_t and h_t
    if .l_t > .h_t
        .temp = .l_t
        .l_t = .h_t
        .h_t = .temp
    endif

    .num_rows = Get number of rows
    for .i to .num_rows
        .curRow = .num_rows - .i + 1
        .curT = Get value: .curRow, "Time"
        .cur_num_rows = Get number of rows
        # remove line ONLY if outside time range and there are at least
        # three rows in table.
        if (.curT < .l_t or .curT > .h_t) and (.cur_num_rows > 2)
            Remove row: .curRow
        endif
    endfor

    #convert Hz to semitones re 1 Hz
    Formula: "F0", "12 * log2(self)"

    @tableStats: .pitchTable, "Time", "F0"
    .slope_st = tableStats.slope
    .intercept_st = tableStats.intercept
    .mean_f0 = tableStats.yMean
    .med_st = tableStats.yMed
    selectObject: .pitchTable
    Remove
endproc

procedure populateTable
    for i to tot_feet
        selectObject: output_table
        Append row
        bottomRow = Get number of rows
        # add general info
        Set string value: bottomRow, "code", cur_textGrid$
        Set string value: bottomRow, "speaker", speaker$
        Set string value: bottomRow, "gender", gender$
        Set string value: bottomRow, "stim", stim$
        Set string value: bottomRow, "rep", rep$
        Set string value: bottomRow, "location", cur_address$

        # add data requiring RHYTHM tier only
        Set string value: bottomRow, "init_phon", init_phono$
        Set string value: bottomRow, "fin_phon", fin_phono$
        Set numeric value: bottomRow, "phr_strt_t", phr_strt
        Set numeric value: bottomRow, "phr_end_t", phr_end
        Set numeric value: bottomRow, "tot_feet", tot_feet
        Set numeric value: bottomRow, "stress_end_t", stress_end[i]
        Set numeric value: bottomRow, "foot_end_t", foot_end[i]
        Set numeric value: bottomRow, "foot_strt_t", foot_strt[i]
        Set numeric value: bottomRow, "cur_foot", i

        # add data requiring SYLLABLE and/or rhythm tiers
        Set string value: bottomRow, "metre_ID", metrical_ID$
        Set string value: bottomRow, "stim_metre", stim$ + "_" + metrical_ID$
        Set numeric value: bottomRow, "ana_syls", ana_syls
        Set numeric value: bottomRow, "ana_end_t", ana_end_t
        Set numeric value: bottomRow, "foot_syls", foot_syls[i]
        Set numeric value: bottomRow, "tot_syls", num_syls

        # add data requiring PHONO and/or rhythm tiers
        Set string value: bottomRow, "acc_phon", accent$[i]
        Set string value: bottomRow, "phr_phon", phr_phono$

        # add data requiring ORTHO and/or rhythm / syllable tiers
        Set string value: bottomRow, "sent", cur_sent$
        Set numeric value: bottomRow, "wrd_fin_syl_strt_t",
                                  ... wrd_fin_syl_strt_t[i]
        Set numeric value: bottomRow, "wrd_end_t", wrd_end_t[i]
        Set numeric value: bottomRow, "wrd_end_syl", wrd_end_syl[i]

        # add data requiring TONE and rhythm, syllable tiers
        Set numeric value: bottomRow, "l_f0", l_f0[i]
        Set numeric value: bottomRow, "h_f0", h_f0[i]
        Set numeric value: bottomRow, "s_f0", s_f0
        Set numeric value: bottomRow, "e_f0", e_f0
        Set numeric value: bottomRow, "v_onset_f0", v_onset_f0[i]
        Set numeric value: bottomRow, "slope_st", slope_st[i]
        Set numeric value: bottomRow, "intercept_st", intercept_st[i]
        Set numeric value: bottomRow, "mean_st", mean_f0[i]
        Set numeric value: bottomRow, "med_st", med_st[i]

        # add ALIGNMENT data requiring VOWEL Tiers
        Set numeric value: bottomRow, "l_t", l_t[i]
        Set numeric value: bottomRow, "h_t", h_t[i]
        Set numeric value: bottomRow, "strt_t", strt_t
        Set numeric value: bottomRow, "end_t", end_t
        Set numeric value: bottomRow, "v_syl", v_syl_num[i]
        Set numeric value: bottomRow, "v_syl_ratio", v_syl_ratio[i]

        # add other ALIGNMENT data
        Set numeric value: bottomRow, "l_syl_strt_t", l_syl_strt[i]
        Set numeric value: bottomRow, "l_syl_end_t", l_syl_end[i]
        Set numeric value: bottomRow, "h_syl_strt_t", h_syl_strt[i]
        Set numeric value: bottomRow, "h_syl_end_t", h_syl_end[i]
        Set numeric value: bottomRow, "l_syl", l_syl_num[i]
        Set numeric value: bottomRow, "h_syl", h_syl_num[i]
        Set numeric value: bottomRow, "l_syl_ratio", l_syl_ratio[i]
        Set numeric value: bottomRow, "h_syl_ratio", h_syl_ratio[i]

        # add data requiring VOWEL and RHYTHM tiers
        Set numeric value: bottomRow, "v_onset_t", v_t_ft[i]
        Set numeric value: bottomRow, "v_offset_t", v_off_ft[i]
        Set string value: bottomRow, "v_text", v_text$[i]
        endif
    endfor
endproc

procedure getPitchAtTime: .pitchObject, .time
    selectObject: .pitchObject
    result = Get value at time: .time, "Hertz", "Linear"
endproc

procedure get_nearest_f0: .object, .time, .time_step
    # Finds nearestdefined f0 to .time (prefers right over left)
    selectObject: .object
    .fo = Get value at time: .time, "Hertz", "Linear"
    while .fo = undefined
        .time = .time + .time_step/10
        .fo = Get value at time: .time, "Hertz", "Linear"
    endwhile
endproc

procedure grandMeanSylTime: .corpusTable, .root$, .corpus$
    # Converts syllable-normalised time to grand-mean syllable-normalised time
    # across all utterances). i.e.:
    # INPUT: syllable normalised time, where integer part = syllable number,
    #        decimal part = proportion of syllable
    # OUPUT: grand mean syllable-nomalised time, where output value is the
    #        otime based on the average syllable duration across all utterences
    #        with the same stimulus and metre ID (i.e. the same stim_metre
    #        parameter)

    # Read or create Grand mean Source table
    .gmSourceCSV$ = .root$ + "/" + .corpus$ + "_MeanSylDur.csv"
    if fileReadable(.gmSourceCSV$)
        .gmTable = Read Table from comma-separated file: .gmSourceCSV$
    else
        @meanSylDurs: .corpusTable, 0
        .gmTable =  meanSylDurs.table
        selectObject: .gmTable
        Save as comma-separated file: .gmSourceCSV$
    endif

    # Convert gmTable to set of arrays for convenience and speed of processing
    selectObject: .gmTable
    .numStims = Get number of rows
    for .curStim to .numStims
        .stimMetre$[.curStim] = Get value: .curStim, "stimMetre"
        .numSyls[.curStim] = Get value: .curStim, "numSyls"
        .gmStrt[.curStim, 1] = 0
        for .curSyl to .numSyls[.curStim]
            .gmDur[.curStim, .curSyl] =
                ... Get value: .curStim, "s" + string$(.curSyl)
            if .curSyl > 1
                .gmStrt[.curStim, .curSyl] =
                ... .gmStrt[.curStim, .curSyl - 1] +
                ... .gmDur[.curStim, .curSyl - 1]
            endif
        endfor
    endfor

    # use syl_NormT prefixes to use in loop
    .affix$[1] = "v_"
    .affix$[2] = "l_"
    .affix$[3] = "h_"

    selectObject: .corpusTable
    # add temporary columns for grand mean calculation
    for .i to 3
        Append column: .affix$[.i] + "gmStrt"
        Append column: .affix$[.i] + "gmDur"
    endfor

    # convert syl number and syl duration grandmean start time and duration
    # using grand mean array values
    for .curStim to .numStims
        for .i to 3
            .durCol$ =  .affix$[.i] + "gmDur"
            .strtCol$ =  .affix$[.i] + "gmStrt"
            .tgtRatio$ = .affix$[.i] + "syl_ratio"
            .tgtSylNum$ = .affix$[.i] + "syl"
            Formula: .durCol$,
                ... "if self$[""stim_metre""] = .stimMetre$[.curStim] then " +
                ... "self[.tgtRatio$] * .gmDur[.curStim, self[.tgtSylNum$]] " +
                ... "else self endif"

            Formula: .strtCol$,
                ... "if self$[""stim_metre""] = .stimMetre$[.curStim] then " +
                ... ".gmStrt[.curStim, self[.tgtSylNum$]] else self endif"
        endfor
    endfor
    # convert sylNormT columns to grand mean syllable times
    for .i to 3
        Formula: .affix$[.i] + "sylNormT",
            ... "self[.affix$[.i] + ""gmDur""] + self[.affix$[.i] + ""gmStrt""]"
        # Remove columns as no longer necessary
        Remove column: .affix$[.i] + "gmDur"
        Remove column: .affix$[.i] + "gmStrt"
    endfor

    # remove remaining object
    selectObject: .gmTable
    Remove
endproc

# ==============================================================================
# PROCEDURES FROM OWN LIBRARIES=================================================

# global.dictionaries.praat ----------------------------------------------------
procedure globalDictionaries

    ### ROOT DIRECTORY
	##################
    root_G$ = "G:/My Drive/Phonetics and speech/Research/2 Field Recordings"
    meanSylDur_M$ = "/M-Corpus_MeanSylDur.Table"
    meanSylDur_A$ = "/A-Corpus_MeanSylDur.Table"
    sylMeanStrtT_M$ = "/M-Corpus_sylMeanStrtT.Table"
    sylMeanStrtT_A$ = "/A-Corpus_sylMeanStrtT.Table"
    # analysis folders
    analyses_G = 2
    analysis_G$[1] = "Analysis_1_standard"
    analysis_G$[2] = "Analysis_2_STH"

    ### TEXTGRID TIER NUMBERS
	#########################
    tierName_G$[1] = "ortho"
    tierName_G$[2] = "syllable"
    tierName_G$[3] = "rhythmic"
    tierName_G$[4] = "phono"

    tierName_G["ortho"] = 1
    tierName_G["syllable"] = 2
    tierName_G["rhythmic"] = 3
    tierName_G["phono"] = 4

    ### CORPORA CODES AND DIRECTORY NAMES
	#####################################
    corpora_G = 4
    corpusFolder_G$[1] = "alignment and H_Placement"
    corpusRef_G$[1] = "a_corpus"
    corpusFolder_G$[2] = "focus"
    corpusRef_G$[2] = "F-corpus"
    corpusFolder_G$[3] = "sentence_modes"
    corpusRef_G$[3] = "M-corpus"
    corpusFolder_G$[4] = "continutation"
    corpusRef_G$[4] = "C-corpus"


    #### SPEAKER ARRAYS AND DICTIONARIES
	####################################

    # SPEAKER CODES
    spkrs_G = 11
    spkr_G$[1] = "F5"
    spkr_G$[2] = "F6"
    spkr_G$[3] = "F12"
    spkr_G$[4] = "F15"
    spkr_G$[5] = "F16"
    spkr_G$[6] = "F17"
    spkr_G$[7] = "M4"
    spkr_G$[8] = "M5"
    spkr_G$[9] = "M8"
    spkr_G$[10] = "M9"
    spkr_G$[11] = "M10"
    spkr_G$[12] = "Sample"

    # SPEAKER NUMBERS
    spkrNum_G["F5"] = 1
    spkrNum_G["F6"] = 2
    spkrNum_G["F12"] = 3
    spkrNum_G["F15"] = 4
    spkrNum_G["F16"] = 5
    spkrNum_G["F17"] = 6
    spkrNum_G["M4"] = 7
    spkrNum_G["M5"] = 8
    spkrNum_G["M8"] = 9
    spkrNum_G["M9"] = 10
    spkrNum_G["M10"] = 11
    spkrNum_G["Sample"] = 12


    ### M-CORPUS
	############

    # SENTENCE MODE
    cat_G$["MDC1"] = "DEC"
    cat_G$["MDC2"] = "DEC"
    cat_G$["MDC3"] = "DEC"
    cat_G$["MYN1"] = "YNQ"
    cat_G$["MYN2"] = "YNQ"
    cat_G$["MYN3"] = "YNQ"
    cat_G$["MWH1"] = "WHQ"
    cat_G$["MWH2"] = "WHQ"
    cat_G$["MWH3"] = "WHQ"
    cat_G$["MDQ1"] = "DCQ"
    cat_G$["MDQ2"] = "DCQ"
    cat_G$["MDQ3"] = "DCQ"

    # SENTENCE MODE HIERARCHY
    mode_G["DEC"] = 1
    mode_G["WHQ"] = 2
    mode_G["YNQ"] = 3
    mode_G["DCQ"] = 4

    # SENTENCE MODE LONG FORM
    modeLong_G$["DEC"] = "declarative"
    modeLong_G$["WHQ"] = "wh- question"
    modeLong_G$["YNQ"] = "yes/no question"
    modeLong_G$["DCQ"] = "declarative question"

    # TARGET WORD IN NUCLEUS
    nucWord_G$["MDC1"] = "vases"
    nucWord_G$["MDC2"] = "valley"
    nucWord_G$["MDC3"] = "valuables"
    nucWord_G$["MYN1"] = "vases"
    nucWord_G$["MYN2"] = "valley"
    nucWord_G$["MYN3"] = "valuables"
    nucWord_G$["MWH1"] = "vases"
    nucWord_G$["MWH2"] = "valley"
    nucWord_G$["MWH3"] = "valuables"
    nucWord_G$["MDQ1"] = "vases"
    nucWord_G$["MDQ2"] = "valley"
    nucWord_G$["MDQ3"] = "valuables"

    # CODE FOR TARGET WORD IN NUCLEUS
    word_G["vases"] = 1
    word_G["valley"] = 2
    word_G["valuables"] = 3

    word_G$[1] = "vases"
    word_G$[2] = "valley"
    word_G$[3] = "valuables"

    ### A-CORPUS / H-CORPUS
	#######################

    # SYLLABLES OF ANACRUSIS
    ana_G["A01"] = 0
    ana_G["A1422"] = 1
    ana_G["A2422"] = 2
    ana_G["A3422"] = 3
    ana_G["A0131"] = 0
    ana_G["A0221"] = 0
    ana_G["A0321"] = 0
    ana_G["A0423"] = 0
    ana_G["A1111"] = 1
    ana_G["A1211"] = 1
    ana_G["A11"] = 0
    ana_G["A12"] = 0
    ana_G["A13"] = 1
    ana_G["A14"] = 0
    ana_G["A1231"] = 1
    ana_G["A1241"] = 0

    ana_G["H0322"] = 0
    ana_G["H0421"] = 0
    ana_G["H0422"] = 0
    ana_G["H1322"] = 1
    ana_G["H1321"] = 1

    # SYLLABLES IN PRE-NUCLEAR FOOT
    pnSyls_G["A01"] = 4
    pnSyls_G["A1422"] = 4
    pnSyls_G["A2422"] = 4
    pnSyls_G["A3422"] = 1
    pnSyls_G["A0131"] = 2
    pnSyls_G["A0221"] = 3
    pnSyls_G["A0321"] = 3
    pnSyls_G["A0423"] = 4
    pnSyls_G["A1111"] = 1
    pnSyls_G["A1211"] = 2
    pnSyls_G["A11"] = 3
    pnSyls_G["A12"] = 4
    pnSyls_G["A13"] = 2
    pnSyls_G["A14"] = 2
    pnSyls_G["A1231"] = 2
    pnSyls_G["A1241"] = 2

    pnSyls_G["H0322"] = 3
    pnSyls_G["H0421"] = 4
    pnSyls_G["H0422"] = 4
    pnSyls_G["H1322"] = 3
    pnSyls_G["H1321"] = 3

    # PN target stressed Syllable onset
    pnStrOn_G$["A1422"] = "v"
    pnStrOn_G$["A2422"] = "v"
    pnStrOn_G$["A3422"] = "v"
    pnStrOn_G$["A0131"] = "v"
    pnStrOn_G$["A0221"] = "v"
    pnStrOn_G$["A0321"] = "v"
    pnStrOn_G$["A0423"] = "v"
    pnStrOn_G$["A1111"] = "n"
    pnStrOn_G$["A1211"] = "l"
    pnStrOn_G$["A1231"] = "l"
    pnStrOn_G$["A1241"] = "n"

	pnStrOn_G$["H0322"] = "l"
	pnStrOn_G$["H0421"] = "v"
	pnStrOn_G$["H0422"] = "l"
	pnStrOn_G$["H1322"] = "l"
	pnStrOn_G$["H1321"] = "l"

    # PN target stressed Syllable rhyme
    pnStrRhy_G$["A1422"] = "al"
    pnStrRhy_G$["A2422"] = "al"
    pnStrRhy_G$["A3422"] = "al"
    pnStrRhy_G$["A0131"] = "alz"
    pnStrRhy_G$["A0221"] = "alz"
    pnStrRhy_G$["A0321"] = "alz"
    pnStrRhy_G$["A0423"] = "al"
    pnStrRhy_G$["A1111"] = "oU"
    pnStrRhy_G$["A1211"] = "Iv"
    pnStrRhy_G$["A1231"] = "Iv"
    pnStrRhy_G$["A1241"] = "id"

	pnStrRhy_G$["H0322"] = "al"
	pnStrRhy_G$["H0421"] = "al"
	pnStrRhy_G$["H0422"] = "al"
	pnStrRhy_G$["H1322"] = "eIn"
	pnStrRhy_G$["H1321"] = "eIn"

    # NUC target stressed Syllable onset
    nucStrOn_G$["A1422"] = "r"
    nucStrOn_G$["A2422"] = "r"
    nucStrOn_G$["A3422"] = "r"
    nucStrOn_G$["A0131"] = "v"
    nucStrOn_G$["A0221"] = "v"
    nucStrOn_G$["A0321"] = "v"
    nucStrOn_G$["A0423"] = "v"
    nucStrOn_G$["A1111"] = "v"
    nucStrOn_G$["A1211"] = "v"
    nucStrOn_G$["A1231"] = "v"
    nucStrOn_G$["A1241"] = "v"

	nucStrOn_G$["H0322"] = "v"
	nucStrOn_G$["H0421"] = "l"
	nucStrOn_G$["H0422"] = "v"
	nucStrOn_G$["H1322"] = "n"
	nucStrOn_G$["H1321"] = "n"

    # NUC target stressed Syllable rhyme
    nucStrRhy_G$["A1422"] = "Iv"
    nucStrRhy_G$["A2422"] = "Iv"
    nucStrRhy_G$["A3422"] = "Iv"
    nucStrRhy_G$["A0131"] = "al"
    nucStrRhy_G$["A0221"] = "al"
    nucStrRhy_G$["A0321"] = "al"
    nucStrRhy_G$["A0423"] = "al"
    nucStrRhy_G$["A1111"] = "al"
    nucStrRhy_G$["A1211"] = "al"
    nucStrRhy_G$["A1231"] = "al"
    nucStrRhy_G$["A1241"] = "al"

	nucStrRhy_G$["H0322"] = "al"
	nucStrRhy_G$["H0421"] = "al"
	nucStrRhy_G$["H0422"] = "al"
	nucStrRhy_G$["H1322"] = "an"
	nucStrRhy_G$["H1321"] = "an"


    # UNSTRESSED SYLLABLES BEFORE NUCLEUS
    nucPreSyls_G["A01"] = 3
    nucPreSyls_G["A1422"] = 3
    nucPreSyls_G["A2422"] = 3
    nucPreSyls_G["A3422"] = 0
    nucPreSyls_G["A0131"] = 1
    nucPreSyls_G["A0221"] = 2
    nucPreSyls_G["A0321"] = 2
    nucPreSyls_G["A0423"] = 3
    nucPreSyls_G["A1111"] = 0
    nucPreSyls_G["A1211"] = 1
    nucPreSyls_G["A11"] = 2
    nucPreSyls_G["A12"] = 3
    nucPreSyls_G["A13"] = 1
    nucPreSyls_G["A14"] = 1
    nucPreSyls_G["A1231"] = 1
    nucPreSyls_G["A1241"] = 1

    nucPreSyls_G["H0322"] = 2
    nucPreSyls_G["H0422"] = 3
    nucPreSyls_G["H0421"] = 3
    nucPreSyls_G["H1322"] = 2
    nucPreSyls_G["H1321"] = 2

    # SYLLABLES IN NUCLEAR FOOT
    nucSyls_G["A01"] = 2
    nucSyls_G["A1422"] = 2
    nucSyls_G["A2422"] = 2
    nucSyls_G["A3422"] = 2
    nucSyls_G["A0131"] = 3
    nucSyls_G["A0221"] = 2
    nucSyls_G["A0321"] = 2
    nucSyls_G["A0423"] = 2
    nucSyls_G["A1111"] = 1
    nucSyls_G["A1211"] = 1
    nucSyls_G["A11"] = 2
    nucSyls_G["A12"] = 2
    nucSyls_G["A13"] = 1
    nucSyls_G["A14"] = 2
    nucSyls_G["A1231"] = 3
    nucSyls_G["A1241"] = 4

    nucSyls_G["H0322"] = 2
    nucSyls_G["H0421"] = 2
    nucSyls_G["H0422"] = 2
    nucSyls_G["H1322"] = 2
    nucSyls_G["H1321"] = 2

    ### H-CORPUS ONLY
    ##################

    # FINAL SYLLABLE OF WORD WITH LEXICAL STRESS IN PN FOOT
    pnWordEnd_G["A0321"] = 1
    pnWordEnd_G["H0322"] = 2
    pnWordEnd_G["H0421"] = 1
    pnWordEnd_G["H0422"] = 2
    pnWordEnd_G["A0423"] = 3
    pnWordEnd_G["H1322"] = 2
    pnWordEnd_G["H1321"] = 1

    # DOES FIRST SYLLABLE OF WORD WITH LEXICAL STRESS START IN ANACRUSIS
    pnWordStart_G["A0321"] = 0
    pnWordStart_G["H0322"] = 0
    pnWordStart_G["H0421"] = 0
    pnWordStart_G["H0422"] = 0
    pnWordStart_G["A0423"] = 0
    pnWordStart_G["H1322"] = 1
    pnWordStart_G["H1321"] = 1

    ### F-CORPUS
    #############

    # FOCUS FOOT
    focusType["FN3"] = 3
    focusType["FN1"] = 1
    focusType["FN2"] = 2
    focusType["FN0"] = 0

    focusType$["FN3"] = "NF-Val"
    focusType$["FN1"] = "NF-Dad"
    focusType$["FN2"] = "NF-Liv"
    focusType$["FN0"] = "BF"
endproc

# object.management.praat ------------------------------------------------------
# Time and Date procedures
procedure seconds: .varName$
    '.varName$' = number(mid$(date$(), 12, 2))*60*60
        ... + number(mid$(date$(), 15, 2))*60
        ... + number(mid$(date$(), 18, 2))
endproc

procedure date
    .zeros$ = "00"
    @month

    .day$ = left$(date$(),3)
    .day = number(mid$(date$(),9,2))
    .day0$ = mid$(date$(),9,2)

    .month$ = mid$(date$(),5, 3)
    .month = month.num[.month$]
    .month0$ = left$(.zeros$, 2-length(string$(.month))) +  string$(.month)

    .year$ = right$(date$(),4)
    .year = number(.year$)
    .time$ = mid$(date$(), 12, 5)
    .hour = number(mid$(date$(), 12, 2))
    .min = number(mid$(date$(), 15, 2))
    .sec = number(mid$(date$(), 18, 2))

    .index = .sec
        ... + .min           *60
        ... + .hour          *60*60
        ... + (.day -1)      *60*60*24
        ... + (.month - 1)   *60*60*24*31
        ... + (.year - 2019) *60*60*24*31*12

    .index$ = .year$
        ... + "_" + .month0$
        ... + "_" + .day0$
        ... + "_" + mid$(date$(), 12, 2)
        ... + "_" + mid$(date$(), 15, 2)
        ... + "_" + mid$(date$(), 18, 2)
endproc

procedure month
    .num["Jan"] = 1
    .num["Feb"] = 2
    .num["Mar"] = 3
    .num["Apr"] = 4
    .num["May"] = 5
    .num["Jun"] = 6
    .num["Jul"] = 7
    .num["Aug"] = 8
    .num["Sep"] = 9
    .num["Oct"] = 10
    .num["Nov"] = 11
    .num["Dec"] = 12
endproc

# Table, array, and variable management procedures
procedure pitch2Table: .pitchObject, .interpolate
    selectObject: .pitchObject

    if .interpolate
        .pitchObject = Interpolate
    endif
    .originalObject = .pitchObject

    # Get key pitch data
    .frameTimeFirst = Get time from frame number: 1
    .timeStep = Get time step

    #create pitch Table (remove temp objects)
    .pitchTier = Down to PitchTier
    .tableofReal = Down to TableOfReal: "Hertz"
    .pitchTable = To Table: "rowLabel"
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

    #removeInterpolated pitch
    if     .originalObject != .pitchObject
        selectObject: .pitchObject
        Remove
    endif
	.table = .pitchTable
endproc

procedure tableStats: .table, .colX$, .colY$
    @keepCols: .table, "'.colX$' '.colY$'", "tableStats.shortTable"

	.numRows = Get number of rows
	.factor$ = Get column label: 1
	if .colX$ != .factor$
		@table2array: .shortTable, .colY$, "tableStats.colTemp$"
		Remove column: .colY$
		Append column: .colY$
		for .i to table2array.n
		    Set string value: .i, .colY$, .colTemp$[.i]
		endfor
	endif

    if .numRows > 1
		.stDevY = Get standard deviation: .colY$
		.stDevY = number(fixed$(.stDevY, 3))
		.stDevX = Get standard deviation: .colX$
		.linear_regression = To linear regression
		.linear_regression$ = Info
		.slope = extractNumber (.linear_regression$, "Coefficient of factor '.colX$': ")
		.slope = number(fixed$(.slope, 3))
		.intercept = extractNumber (.linear_regression$, "Intercept: ")
		.intercept = number(fixed$(.intercept, 3))
		.r = number(fixed$(.slope * .stDevX / .stDevY, 3))
		selectObject: .linear_regression
		.info$ = Info
		Remove
	else
		.stDevY = undefined
		.stDevX = undefined
		.linear_regression = undefined
		.linear_regression$ = "N/A"
		.slope = undefined
		.intercept = Get value: 1, .colY$
		.r = undefined
		.info$ = "N/A"
	endif

	selectObject: .shortTable
	.xMean = Get mean: .colX$
	.xMed = Get quantile: .colX$, 0.5
	.yMean = Get mean: .colY$
	.yMed = Get quantile: .colY$, 0.5
	Remove
endproc

procedure table2array: .table, .col$, .array$
    .string = right$(.array$, 1) = "$"
    selectObject: .table
    .n = Get number of rows
    for .i to .n
        if .string
            .cur_val$ = Get value: .i, .col$
            '.array$'[.i] = .cur_val$
        else
            .cur_val = Get value: .i, .col$
            '.array$'[.i] = .cur_val
        endif
    endfor
endproc

procedure keepCols: .table, .keep_cols$, .new_table$
    @list2array: .keep_cols$, ".keep$"
    selectObject: .table
    '.new_table$' = Copy: .new_table$
    .num_cols = Get number of columns
    for .i to .num_cols
        .col_cur = .num_cols + 1 - .i
        .label_cur$ = Get column label: .col_cur
        .keep_me = 0
        for .j to list2array.n
            if .label_cur$ = list2array.keep$[.j]
                .keep_me = 1
            endif
        endfor
        if .keep_me = 0
            Remove column: .label_cur$
        endif
    endfor
endproc

procedure list2array: .list$, .array$
    .list_length = length(.list$)
    .n = 1
    .prev_start = 1
    for .i to .list_length
        .char$ = mid$(.list$, .i, 1)
        if .char$ = " "
            '.array$'[.n] = mid$(.list$, .prev_start, .i - .prev_start)
            .origIndex[.n] = .prev_start
            .n += 1
            .prev_start = .i + 1
        endif
    endfor
    if .n = 1
        '.array$'[.n] = .list$
    else
        '.array$'[.n] = mid$(.list$, .prev_start, .list_length - .prev_start + 1)
    endif
    .origIndex[.n] = .prev_start
endproc

procedure unique_strings: .table, .column$, .output_array$
    #create temp copy to sort
    selectObject: .table
    .tempTable = Copy: "Temp"
    Sort rows: .column$
    # Check column exists
    .column_exists = Get column index: .column$
    if not .column_exists
    appendInfoLine: "ERROR:", tab$, "@unique_strings: ", .table, ", """, .column$,
                ... """, """, .output_array$, """"
    appendInfoLine: tab$, "Col. """, .column$, """ not found in table #", .table
    appendInfoLine: "EXITING SCRIPT"
        exit
    endif

    #correct name of output array
    if right$(.output_array$, 1) != "$"
        #create variable name for unique count
        .unique_count$ = .output_array$
        .output_array$ += "$"
    else
        #create variable name for unique count
        .unique_count$ = replace$(.output_array$, "$", "", 1)
    endif
    .unique_num$ = replace$(.output_array$, "$", "Num", 1)
    .num_rows = Get number of rows
    '.unique_count$' = 1

    '.output_array$'[1] = Get value: 1, .column$

    for .i to .num_rows
        .cur_string$ = Get value: .i, .column$
        .string_is_new = 1
        for j to '.unique_count$'
            if .cur_string$ = '.output_array$'[j]
                .string_is_new = 0
            endif
        endfor
        if .string_is_new
            '.unique_count$' += 1
            '.output_array$'['.unique_count$'] = .cur_string$
        endif
    endfor

    # look for number of entries for each unique entry value
    for .i to '.unique_count$'
        #find first entry for current unique entry value
        .curRow = Search column: .column$, '.output_array$'[.i]

        # populate first element in each array
        '.unique_num$'[.i] = 1
        .curStimMetre$ = '.output_array$'[.i]

        # create "done" flag to end array (i.e. end if the last entry was not
        # one of the unique entries or if there are no more table rows)
        .done = (.curRow >= .num_rows) or (.curStimMetre$ != '.output_array$'[.i])

        # search the table until there done
        while not .done
            .curRow += 1
            if .curRow < .num_rows
                .curStimMetre$ = Get value: .curRow, .column$
                if .curStimMetre$ = '.output_array$'[.i]
                    '.unique_num$'[.i] += 1
                endif
            endif
        .done = (.curRow >= .num_rows) or (.curStimMetre$ != '.output_array$'[.i])
        endwhile
    endfor
    #remove the temp table
    Remove
endproc

procedure removeRowsWhere: .table, .col$, .criteria$
    selectObject: .table
    .num_rows = Get number of rows
    for .i to .num_rows
        .cur_row = .num_rows + 1 - .i
        .cur_value$ = Get value: .cur_row, .col$
        if .cur_value$ '.criteria$'
            Remove row: .cur_row
        endif
    endfor
endproc

# Corpus management / processing procedures -------------------------------------
procedure meanSylDurs: .corpus_choice, .analysis_set
    @globalDictionaries
    # .analysis_set = 0 --> corpus_choice object already in object window!
    if .analysis_set = 0
        selectObject: .corpus_choice
        .corpus = Copy: selected$("Table")
        .baseName$ = selected$("Table")
    else
        .corpus = Read from file: root_G$ + "/" + analysis_G$[.analysis_set] + "/"
            ... + corpusRef_G$[.corpus_choice] + ".Table"
        .baseName$ = corpusRef_G$[.corpus_choice]
    endif

    # TRIM CORPUS
    @trimCorpus: "meanSylDurs.corpus"

    # GET ARRAY OF UNIQUE STIM_METRE CODES
    selectObject: .corpus
    @unique_strings: .corpus, "stim_metre", "meanSylDurs.stim_metres"

    # CREATE TABLES LISTING EACH LOCATION OF EACH UNIQUE-STIM METRE
    for .curStimMetre to .stim_metres
        selectObject: .corpus
        .curName$ = .stim_metres$[.curStimMetre]
        .stimMetreTable[.curStimMetre] = Copy: .curName$
        @removeRowsWhere: .stimMetreTable[.curStimMetre], "stim_metre",
            ... "!= meanSylDurs.stim_metres$[meanSylDurs.curStimMetre]"
        .stimMetreReps[.curStimMetre] = Get number of rows
    endfor

    # Remove redundant corpus object
    selectObject: .corpus
    Remove
    .maxSyls = 0
    for .i to .stim_metres
        selectObject: .stimMetreTable[.i]
        .numRows = Get number of rows
        for .curGrid to .numRows
            selectObject: .stimMetreTable[.i]
            .curFile$ = Get value: .curGrid, "code"
            .dir$ = Get value: .curGrid, "location"
            .curFile = Read from file: .dir$ + .curFile$ + ".TextGrid"
            .tIndex = (.curGrid * (.i - 1)) + .curGrid
            @rhythm: .curFile, 3, 0
            @syllable: .curFile, 2, 0
            selectObject: rhythm.table
            Remove
            selectObject: syllable.table
            Append column: "dur"
            Formula: "dur", "self[""tmax""]-self[""tmin""]"
            Remove column: "tmin"
            Remove column: "tmax"
            Remove column: "text"
            Remove column: "metre_ID"
            Remove column: "syl"
            .durTable[.curGrid] = Transpose
            selectObject: syllable.table
            plusObject: .curFile
            Remove
        endfor

        ## create table of all syl durs for cur STIM_METRE
        selectObject: .durTable[1]

        for .curGrid from 2 to .numRows
            plusObject: .durTable[.curGrid]
        endfor

        .combined = Append
        Rename: .stim_metres$[.i]
        Set column label (index): 1, "text"
        Remove column: "text"
        .numSyls[.i] = Get number of columns

        ## update maxSyls
        if .numSyls[.i] > .maxSyls
            .maxSyls = .numSyls[.i]
        endif

        for .col to .numSyls[.i]
            Set column label (index): .col, "syl_" + string$(.col)
            .mean[.i,.col] = Get mean: "syl_" + string$(.col)
            .sd[.i,.col] = Get standard deviation: "syl_" + string$(.col)
        endfor

        selectObject: .stimMetreTable[.i]
        plusObject: .combined
        for .curGrid to .numRows
            plusObject: .durTable[.curGrid]
        endfor
        Remove
    endfor

    ##CREATE OUTPUT TABLE
    .sylCols$ = ""
    for .i to .maxSyls
        .sylCols$ += " s" + string$(.i)
    endfor

    .table = Create Table with column names:
        ... .baseName$ + "_MeanSylDur",
        ... .stim_metres, "stimMetre numReps numSyls phrDur" + .sylCols$

    ##POPULATE OUTPUT TABLE
    for .i to .stim_metres
        .curPhrDur = 0
        Set string value: .i, "stimMetre", .stim_metres$[.i]
        Set numeric value: .i, "numSyls", .numSyls[.i]
        for .j to .numSyls[.i]
             Set numeric value: .i, "s" + string$(.j),
                 ... number(fixed$(.mean[.i,.j],3))
             .curPhrDur += .mean[.i,.j]
        endfor
        Set numeric value: .i, "phrDur", number(fixed$(.curPhrDur,3))
        Set numeric value: .i, "numReps", .stimMetreReps[.i]
    endfor

    Formula (column range): "s1", "s" +string$(.maxSyls),
        ... "if self$ = """" then self$ = ""0"" else self endif"
endproc

procedure trimCorpus: .originalCorpusVar$
    .corpus = '.originalCorpusVar$'
    @keepCols: .corpus,
           ... "code speaker rep stim metre_ID cur_foot stim_metre location",
           ... "trimCorpus.trim"
    selectObject: .corpus
    .name$ = selected$("Table")
    selectObject: .trim
    Rename: .name$ + "_trimmed"
    @removeRowsWhere: .trim, "cur_foot", "!= ""1"""
    Remove column: "cur_foot"
    selectObject: .corpus
    Remove
    '.originalCorpusVar$' = .trim
endproc

procedure rhythm: .textGrid, .tierNum, .startAtZero

    #convert rhythm tier to table
    selectObject: .textGrid
    .code$ = selected$("TextGrid")
    .name$ = "Rhy_"  + .code$

    .tierGrid = Extract one tier: .tierNum
    .tierTable = Down to Table: "no", 3, "no", "no"
    selectObject: .tierTable
    .numRows = Get number of rows

    # get phrase start and end
    .phrStrt = Get value: 1, "tmin"
    .phrEnd = Get value: .numRows, "tmin"
    .feet = 0
    .boundaries = 0

    # get start time of each foot: foot_start[#]
    # get duration of each stressed syllable:  .ftStrDur[#]
    for .i to .numRows
        .timeCur = Get value: .i, "tmin"
        .textCur$ = Get value: .i, "text"
        # remove accidental table
        .textCur$ = replace$(replace$(.textCur$, tab$, "", 0), newline$, "", 0)
        for .j to length(.textCur$)
            .charCur$= mid$ (.textCur$, .j, 1)
            if .charCur$ = "<"
                .feet += 1
                .ftStrt[.feet] = .timeCur
                .strEnd[.i] = Get value: .i+1, "tmin"
                .ftStrDur[.feet] = .strEnd[.i] - .timeCur
                .ftStrt[.feet] = .timeCur - .phrStrt
            elsif .charCur$ = "%"
                .boundaries += 1
                if .boundaries = 1
                    init_phono$ = replace$(.textCur$, "<", "", 0)
                else
                    .finPhono$ =  replace$(.textCur$, ">", "", 0)
                endif
            endif
        endfor
    endfor

    # get duration of each foot: .ftDur[#]
    for .i to .feet - 1
        .ftDur[.i] = .ftStrt[.i+1] - .ftStrt[.i]
    endfor
    .ftDur[.feet] =  (.phrEnd - .phrStrt) - .ftStrt[.feet]
    # get anacrusis and phrase duration
    .anaDur = .ftStrt[1]
    .phrDur =  .phrEnd - .phrStrt

    # create RhythmTable mimicking interval table
    .table = Create Table with column names: .name$, 0, "num_foot tmin foot_strt_t"
        ... + " tmax ft_dur text"
    # add anacrusis
    if .anaDur > 0
        Append row
        Set numeric value: 1, "tmin", 0
        Set numeric value: 1, "tmax", .ftStrt[1]
        Set string value: 1, "text", "%"
        Set numeric value: 1, "num_foot", 0
        Set numeric value: 1, "foot_strt_t", 0
        Set numeric value: 1, "ft_dur", .ftStrt[1]
    endif
    # add stressed syllables plus unstressed syllables (except final tail)
    for .i to .feet
        Append row
        .curRow = Get number of rows
        Set numeric value: .curRow, "tmin", .ftStrt[.i]
        Set numeric value: .curRow, "tmax", .ftStrt[.i] + .ftStrDur[.i]
        Set numeric value: .curRow, "num_foot", .i
        Set numeric value: .curRow, "foot_strt_t", .ftStrt[.i]
        Set numeric value: .curRow, "ft_dur", .ftDur[.i]

        if .anaDur = 0 and .i = 1
            .text$ = "%<STR>"
        elsif .ftStrDur[.i] = .ftDur[.i] and .i = .feet
            .text$ = "<STR>%"
        else
            .text$ = "<STR>"
        endif
        Set string value: .curRow, "text", .text$

        if .i != .feet and .ftDur[.i] != .ftStrDur[.i]
            Append row
            .curRow = Get number of rows
            Set numeric value: .curRow, "tmin", .ftStrt[.i] + .ftStrDur[.i]
            Set numeric value: .curRow, "tmax", .ftStrt[.i + 1]
            Set string value: .curRow, "text", "..."
            Set numeric value: .curRow, "num_foot", .i
            Set numeric value: .curRow, "foot_strt_t", .ftStrt[.i]
            Set numeric value: .curRow, "ft_dur", .ftDur[.i]
        endif
    endfor
    # add final tail if it exists
    if .ftStrDur[.feet] < .ftDur[.feet]
        Append row
        .curRow = Get number of rows
        Set numeric value: .curRow, "tmin", .ftStrt[.feet] + .ftStrDur[.feet]
        Set numeric value: .curRow, "tmax", .phrDur
        Set string value: .curRow, "text", "%"
        Set numeric value: .curRow, "num_foot", .i-1
        Set numeric value: .curRow, "foot_strt_t", .ftStrt[.i-1]
        Set numeric value: .curRow, "ft_dur", .ftDur[.i-1]
    endif
    if .startAtZero
        .offset = 0
    else
        .offset = .phrStrt
    endif
    Formula: "tmin", "number(fixed$(self + .offset, 3))"
    Formula: "tmax", "number(fixed$(self + .offset, 3))"
    Formula: "ft_dur", "number(fixed$(self + .offset, 3))"
    Formula: "foot_strt_t", "number(fixed$(self + .offset, 3))"

    selectObject: .tierGrid
    plusObject: .tierTable
    Remove
endproc

procedure syllable: .textGrid, .tierNum, .startAtZero
    # convert syllable tier to table
    selectObject: .textGrid
    .code$ = selected$("TextGrid")
    .name$ = "Syl_"  + .code$
    .syl_tier = Extract one tier: .tierNum
    .table = Down to Table: "yes", 3, "no", "no"
    Rename: .name$
    Set column label (index): 1, "syl"
    .phr_start = rhythm.phrStrt

    selectObject: .table
    # get number of syllables
    .num_syls = Get number of rows

    # get start time of each syllable: syl_start[#]
    # check number of syllables of anacrusis: ana_syls[#]
    .ana_syls = 0
    .cur_foot = 0
    .foot_one_start = .phr_start + rhythm.ftStrt[1]
    .stress_one_end = .phr_start + rhythm.ftStrt[1] + rhythm.ftStrDur[1]
    for .i to .num_syls
        .cur_syl_start = Get value: .i, "tmin"
        .cur_syl_end = Get value: .i, "tmax"
        .cur_syl_mid = (.cur_syl_end + .cur_syl_start) / 2

        # check if current syllable is part of anacrusis
        if .cur_syl_mid < .foot_one_start
            .ana_syls += 1
        # else check if current syllable is 1st stressed syllable of 1st foot
        elsif .cur_syl_mid > .foot_one_start and
                ... .cur_syl_mid < .stress_one_end
            .cur_foot = 1
            .foot_syls[.cur_foot] = 1

        # else check if current syllable is start of a new foot
        elsif .cur_syl_mid > .phr_start + rhythm.ftStrt[.cur_foot] +
            ... rhythm.ftDur[.cur_foot]
            .cur_foot += 1
            .foot_syls[.cur_foot] = 1

        # otherwise assume curr syllable is part of current foot
        else
            .foot_syls[.cur_foot] += 1
        endif
        # get foot identity of each syllable: syl_foot_ID[#]
        .syl_foot_ID[.i] = .cur_foot
        # get duration of each syllable: syl_dur[#]
        .syl_dur[.i] = .cur_syl_end - .cur_syl_start
        .syl_start[.i] = .cur_syl_start - .phr_start
    endfor

    .metrical_ID = .ana_syls
    for .m_index to .cur_foot
        .metrical_ID += .foot_syls[.m_index] * 10^.m_index
    endfor
    .metrical_ID$ = ""
    .m_ID_len = length(string$(.metrical_ID))
    for .m_index to .m_ID_len
   	    .metrical_ID$ +=
            ... mid$(string$(.metrical_ID), .m_ID_len - .m_index + 1, 1)
    endfor

    if .startAtZero
        .offset = .phr_start
    else
        .offset = 0
    endif
    Formula: "tmin", "number(fixed$(self - .offset, 3))"
    Formula: "tmax", "number(fixed$(self - .offset, 3))"

    # add utterence identifer column
    selectObject: .table
    .numRows = Get number of rows
    Insert column: 1, "metre_ID"
    Formula: "metre_ID", ".metrical_ID$"

    selectObject: .syl_tier
    Remove
endproc
