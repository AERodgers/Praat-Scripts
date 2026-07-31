# CHOP UP LARGE SOUND FILE USING 2-TIERED TEXTGRID
# ================================================
# This script chops up a larger file into smaller files based on a textgrid with two tiers.
#   - It creates a unique filename for each sound by combining the text from an optional prefix
#     with text from tiers 1 and 2.
#   - If a file with the same name already exists, a copy will be saved in the backup directory
#     and the previous file overwritten.
#   - A report is saved to the "output" folder
#
# One of a set of scripts to help automate some of my PhD research.
# for Praat 6.0.36
#
# Antoin Eoin Rodgers
# rodgeran@tcd.ie
# Phonetics and speech Laboratory, Trinity College Dublin
# October 28, 2017

### TIER ANNOTATION INSTRUCTIONS
###    1. The .TextGrid file must have the same name as the .wav file and be saved in the same directory
###    2. The .TextGrid file must have 2 interval tiers only:
###          - TIER 1: should contain a general reference (e.g. speaker code or phrase code)
###          - TIER 2: should contain a rep number for the general reference
### UI FORM
###    1. PREFIX
###          - Prefix all output files (e.g. speaker code, gender, location)
###          - Leave blank for no prefix
###    2. PASS BAND FREQUENCY
###          - The lower limit for the pass band filtering
###          - This should be AT LEAST 10 Hz below the lowest F0 in the files.

##################
### User Input ###
##################
### Input Form
form Input Parameters
    natural pass_band_frequency 45
    positive Silence_length 0.25
    sentence Output_file_prefix
endform
### Get file to process
sound_file$ = chooseReadFile$: "Open a sound file"

#Read in target wave file
Read from file: sound_file$
sound_ID = selected()
fs = Get sampling frequency

######################################
### READ TEXTGRID FILE (IF EXISTS) ###
######################################
textgrid_file$ = left$ (sound_file$, rindex (sound_file$, "."))+ "TextGrid"
### check textgrid exists
textGrid_okay = fileReadable (textgrid_file$)
if textGrid_okay = 0
    exitScript: "NO TEXTGRID FOR SELECTED .WAV FILE." + newline$
endif

### read in textgrid
Read from file: textgrid_file$
grid_ID = selected()

###run validity checks for input textgrid
num_tiers = Get number of tiers
if num_tiers != 2
    exitScript: "TEXTGRID FOR SELECTED .WAV FILE SHOULD ONLY HAVE 2 TIERS." + newline$
endif

is_interval_1 = Is interval tier: 1
is_interval_2 = Is interval tier: 2

if is_interval_1 + is_interval_2 != 2
    exitScript: "EACH TEXTGRID TIER MUST BE AN INTERVAL TIER." + newline$
endif

total_intervals_1 = Get number of intervals: 1
total_intervals_2 = Get number of intervals: 2

if total_intervals_1 > total_intervals_2
    exitScript: "TIER 1 SHOULD HAVE AT LEAST AS MANY TIERS A TIER 2." + newline$
endif

not_blank_1 = Count intervals where: 1, "is not equal to", ""
not_blank_2 = Count intervals where: 2, "is not equal to", ""

if not_blank_1 * not_blank_2 = 0
    exitScript: "AT LEAST ONE TIER IS BLANK." + newline$
endif

#############################
### SET UP OUTPUT FOLDERS ###
#############################
output_dir$ = chooseDirectory$: "Choose a directory for save file"
output_text$ =  "Saving Files to directory: " +output_dir$
@SetUpFolders: output_dir$

### start report
text$ = "========================"
writeInfoLine: text$
writeFileLine: report_file_path$, text$
text$ = "Chop Up Large Sound File" + newline$ + "========================"
  ... + newline$ + date$ ( ) + newline$
@reportUpdate: report_file_path$, text$

### input directory
rightmost_slash = rindex (sound_file$, "/")
inputDir$ = left$(sound_file$, rightmost_slash)
inputFile$ = right$(sound_file$, length(sound_file$) - rightmost_slash)

@ChopLines: inputDir$, 50, "Input directory:  """, """"
inputDirText$ = new_text$
@ChopLines: output_dir$, 50, "Output directory: """, """"
output_dirText$ = new_text$

text$ = "Input .wav file:  """ + inputFile$ + """" + newline$
  ... + inputDirText$ + newline$
  ... + output_dirText$ + newline$ + newline$
  ... + "Stop band : 0 - " + string$(pass_band_frequency) + " Hz"  + newline$
@reportUpdate: report_file_path$, text$

### CREATE NEW SOUND OBJECTS BASED ON TIER 1 INTERVAL AND ARRAY OF NON-BLANK INTERVAL NAMES
valid_intervals_2 = 0
### Create unique output file names: tier1 (code) + "_" + tier2 (rep)
for i from 1 to total_intervals_2
    i$ = Get label of interval: 2, i
    if i$<>""
        valid_intervals_2 = valid_intervals_2 + 1
        rep$ =  i$
        start_point = Get start point: 2, i
        end_point = Get end point: 2, i
        mid_point = (start_point + end_point) / 2
        code_num = Get interval at time: 1, mid_point
        code$ = Get label of interval: 1, code_num
        unique_name$[valid_intervals_2] = code$ + "_" + rep$
    endif
endfor

### extract reps from sound file
selectObject: grid_ID
plusObject: sound_ID
Extract non-empty intervals: 2, "no"
total_files = numberOfSelected ()
start_sound = selected(1)
end_sound = selected(-1)

selectObject: sound_ID
plusObject: grid_ID
Remove

### append file prefix if necessary
if output_file_prefix$ <> ""
    output_file_prefix$ = output_file_prefix$ + "_"
endif

### Remove low-frequency noise and save new sound file
text$ = "Output files:"
@reportUpdate: report_file_path$, text$

for i from start_sound to end_sound
    backedUp$ = ""
    j = i - start_sound + 1

    selectObject: i
    Filter (stop Hann band): 0, pass_band_frequency, 10

    iTemp = selected()
    file_name_cur$ = output_dir$ + "/" + output_file_prefix$ + unique_name$[j] + ".wav"
    curFileExists = fileReadable (file_name_cur$)

    backupNum = 0
    while curFileExists
        backupNum += 1
        curBackUp$ = backup_path$ + output_file_prefix$
               ... + unique_name$[j] + "_bk" + string$(backupNum) + ".wav"
        curFileExists = fileReadable (curBackUp$)
        if curFileExists = 0
            backedUp$ = " (backup: " + output_file_prefix$ + unique_name$[j]
                  ... + "_bk" + string$(backupNum) + ".wav)"
            Read from file: file_name_cur$
            Save as WAV file: curBackUp$
            Remove
        endif
    endwhile

    @addSilence: iTemp, silence_length, 0.01
    removeObject: iTemp
    iTemp = addSilence.output
    selectObject: iTemp
    Save as WAV file: file_name_cur$

    text$ = "   " + output_file_prefix$ + unique_name$[j] + ".wav" + backedUp$
    @reportUpdate: report_file_path$, text$

    selectObject: i
    plusObject: iTemp
    Remove
endfor

text$ = newline$ + "================"
  ... + newline$ + "PROCESS COMPLETE"
  ... + newline$ + "================"
@reportUpdate: report_file_path$, text$

##################
### procedures ###
##################
### report update
procedure reportUpdate: .report_file$, .line_text$
    appendInfoLine: .line_text$
    appendFileLine: .report_file$, .line_text$
endproc

### create text for directory info
procedure ChopLines: .original_text$, .line_length, .new_text$, .end_text$

    .spaces$ = ""
    for .i to length(.new_text$)
        .spaces$ = .spaces$ + " "
    endfor

    .dir_len = length(.original_text$)
    .full_chunks = floor(.dir_len/.line_length)
    .remainder = .dir_len - .full_chunks * .line_length

    for .i to .full_chunks
        .new_text$ = .new_text$ + mid$(.original_text$, 1 + .line_length * (.i - 1), .line_length)
                ... + newline$ + .spaces$
    endfor

    .new_text$ = .new_text$ + right$(.original_text$, .remainder) + .end_text$
    new_text$ = .new_text$
endproc

### Set up folders
procedure SetUpFolders: .directory$
    output_dir$ = "output"
    backup_dir$ = "backup"
    report_name$ = "create_sound_files_report_"
        ... + right$(replace$(replace$(date$()," ","", 0),":","",0),15)
        ... + " .txt"
    report_path$ = .directory$ + "/" + output_dir$
    backup_path$ = .directory$ + "/" + backup_dir$

    createDirectory: report_path$
    createDirectory: backup_path$

    report_path$ = report_path$ + "/"
    backup_path$ = backup_path$ + "/"

    report_file_path$ = report_path$ + report_name$
endproc

### Add silence to sound file
procedure addSilence: .sound_object, .silence_length, .overlap
    .silence_length = .silence_length + .overlap 

    selectObject: .sound_object
    .fs = Get sampling frequency
    .channels = Get number of channels

    .leading_silence = Create Sound from formula:
    ... "leading_silence", .channels, 0, .silence_length, .fs, "0"

    selectObject: .sound_object
    .sound_copy = Copy: "sound_copy"
    selectObject: .leading_silence
    .trailing_silence = Copy: "trailing_silence"

    selectObject: .leading_silence
    plusObject: .sound_copy 
    plusObject: .trailing_silence    
    .output = Concatenate with overlap: .overlap
    
    removeObject: .leading_silence, .sound_copy, .trailing_silence    
endproc
