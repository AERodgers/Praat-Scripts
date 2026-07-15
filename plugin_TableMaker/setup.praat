# Table Maker plugin.
#
# Written for Praat 6.4.60 or later
# script by Antoin Eoin Rodgers
#
# email:     antoin.rodgers@tcd.ie
# github:    github.com/AERodgers
#
# v.1.6.0.0

Add action command:
... "Sound", 1,
... "TextGrid", 1,
... "", 0,
... " ",
... "", 0,
... ""

Add action command:
... "Sound", 1,
... "TextGrid", 1,
... "", 0,
... "TableMaker",
... "", 0,
... ""

Add action command:
... "Sound", 1,
... "TextGrid", 1,
... "", 0,
... "Create table from nested textgrid tiers...",
... "TableMaker", 0,
... "nestedTiers2Table.praat"
