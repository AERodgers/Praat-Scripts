# Delete unwanted items from a TextGrid
# UI lazibones!
csv_file$ = "C:/Users/AERODGER/OneDrive - Trinity College Dublin/TCDGroup-Phonetics & Phonology WG - Dublin IPA Illustration/recordings_chopped/figure_examples/targets.csv"
my_textgrid = selected("TextGrid")


# Get wanted list
# Trim whitespace from each item in the list and make all lower case
@csv2stringArray(csv_file$, "wanted_list$", "y", "y")

# for  text in each interval. 
    # Trim whitespace from each interval itemand make all lower case
    # compare interval text to wanted list
    # If the text interval is not in the wanted list delete it.




procedure csv2stringArray(.csv$, .array$, .trim$, .lower_case$)
    .table = Read Table from comma-separated file: .csv$
    .num_rows = Get number of rows
    .num_cols = Get number of columns

    for .cur_row to .num_rows
        for .cur_col to .num_cols
            .cur_col$ = Get column label: .cur_col
            .value$ = Get value: .cur_row, .cur_col$ 
            if lowerCase$(left$(.trim$,1)) = "y"
                .value$ = replace_regex$ (.value$, "^\s+|\s+$", "", 0)
            endif
            if lowerCase$(left$(.lower_case$,1)) = "y"
                .value$ = lowerCase$(.value$)
            endif
            '.array$'[.cur_row, .cur_col] = .value$

        endfor
    endfor
    removeObject: .table
endproc

#### TEST
writeInfoLine:"Test"
for cur_row to csv2stringArray.num_rows
    appendInfo: newline$
    for cur_col to csv2stringArray.num_cols
        appendInfo: ">", wanted_list$[cur_row, cur_col], "<", tab$
    endfor
endfor
