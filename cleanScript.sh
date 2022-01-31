#!/bin/sh

# Usage ./cleanScript.sh "inputFile" "outputFileName"
# This script lowercases words, 
# chomps words, 
# filters out: 
#   words shorter than 4 letters, 
#   longer than 11 letters
#   That have characters that aren't in the alphabet
# It also sorts the words by letter frequency
# And sorts the words by length

test -e "$2" && exit 1
test "$#" -ne 2 && exit 2

tr '[:upper:]' '[:lower:]' < "$1" \
    | sed 's/[[:space:]]*$//' \
    | grep '^[a-z][a-z]*$' \
    | awk -f scoreWordsByFreq.awk \
    | sort --reverse --numeric-sort \
    | awk '{print $2}' \
    | awk '{if(length($1)>=4&&length($1)<=11){print length($1), $1}}' \
    | sort -s --numeric-sort \
    | awk '{print $2}' > "$2"
