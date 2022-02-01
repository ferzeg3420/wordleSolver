#!/bin/sh

generatePositionString() {
    for _ in $(seq 1 "$NUM_LETTERS")
    do
        printf "_"
    done
    printf "\n"
}

generateLettersInPosToExlude() {
    for _ in $(seq 1 "$((NUM_LETTERS - 1))")
    do
        printf ","
    done
    printf "\n"
}

pressEnterToContinue() {
    printf "\npress enter to continue\n"
    read -r 
}

filterOutLettersNotInThisPosition() {
        tr '[:upper:]' '[:lower:]' < "$TEMP_DICT" \
            | sed 's/[[:space:]]*$//'          \
            | awk -v lettersToExcludeInCVSPos="$LETTERS_IN_POS_TO_EXCLUDE" -f filterOutMatchingPositions.awk
}

includeExcludeLettersAndMatchPositions() {
    if expr "$POSITION_STRING" : '^[a-z_]*[a-z][a-z_]*' 1>/dev/null
    then
        tr '[:upper:]' '[:lower:]' < "$DICTIONARY" \
            | sed 's/[[:space:]]*$//'          \
            | awk -v targetLength="$NUM_LETTERS" -f printOnlyDesiredLength.awk \
            | awk -v include="$INCLUDED" -v exclude="$EXCLUDED" -f includeAndExcludeLetters.awk \
            | awk -v letters="$POSITION_STRING" -f matchLetterPositions.awk
    else
        tr '[:upper:]' '[:lower:]' < "$DICTIONARY" \
            | sed 's/[[:space:]]*$//'          \
            | awk -v targetLength="$NUM_LETTERS" -f printOnlyDesiredLength.awk \
            | awk -v include="$INCLUDED" -v exclude="$EXCLUDED" -f includeAndExcludeLetters.awk 
    fi
}

generateGoodGuesses() {
    tr '[:upper:]' '[:lower:]' < "$WORDS" \
    | sed 's/[[:space:]]*$//'              \
    | awk -v targetLength="$NUM_LETTERS" -v prevGuesses="$PREV_GUESSES" -f generateGoodGuess.awk
}

getNumberOfLetters() {
    while true
    do
        printf "Number of letters (4-12): "
        read -r NUM_LETTERS
        if echo "$NUM_LETTERS" | grep '^\([4-9]\|1[0-2]\)$' 1>/dev/null
        then
            break
        fi
    done
}

displayGuessToTryDialog() {
    GUESS_TO_TRY="$(generateGoodGuesses)"
    printf "try: %s\n" "$GUESS_TO_TRY"
    PREV_GUESSES="$PREV_GUESSES $GUESS_TO_TRY"
    pressEnterToContinue
}

getGuessResultsFromUser() {
    printf "Type the results (G before green letters, Y before yellow letters, and nothing before grey. Type a single N if the word is not in wordle's dictionary):"
    read -r GUESS_RESULTS_FROM_USER
}

addCorrectLetterToPosString() {
    letter="$1"
    letterPos="$2"
    prevLetterPos=$((letterPos - 1 ))
    nextLetterPos="$(( letterPos + 1))"
    POSITION_STRING_SAV="$POSITION_STRING"
    POSITION_STRING="$(echo "$POSITION_STRING_SAV" | cut -c -"$prevLetterPos" 2>/dev/null)${letter}$(echo "$POSITION_STRING_SAV" | cut -c "$nextLetterPos"-)"
}

updateLettersInPosToExclude() {
    letterNumberIter=1
    newLettersToExcludeInPos=""
    isFirstLetter="t"
    for i in $(seq 1 "$NUM_LETTERS")
    do
        lettersToExcludeInPos=$(echo "$LETTERS_IN_POS_TO_EXCLUDE" | cut -d"," -f"$i")
        if test "$isFirstLetter" = "t"
        then
            if test "$letterNumberIter" -eq "$2" 
            then
                newLettersToExcludeInPos="${lettersToExcludeInPos}$1"
            else
                newLettersToExcludeInPos="${lettersToExcludeInPos}"
            fi
            isFirstLetter=""
            letterNumberIter=$((letterNumberIter + 1))
            continue
        fi
        if test "$letterNumberIter" -eq "$2" 
        then
            newLettersToExcludeInPos="${newLettersToExcludeInPos},${lettersToExcludeInPos}$1"
        else
            newLettersToExcludeInPos="${newLettersToExcludeInPos},${lettersToExcludeInPos}"
        fi
        letterNumberIter=$((letterNumberIter + 1))
    done
    LETTERS_IN_POS_TO_EXCLUDE="$newLettersToExcludeInPos"
}

addToIncludedLettersAndToDoNotMatchList() {
    if ! expr "$INCLUDED" : ".*${1}.*" 1>/dev/null 
    then
        INCLUDED="${INCLUDED}${1}"
    fi
    lettersToNotMatchInCurrentPos=$(echo "$LETTERS_IN_POS_TO_EXCLUDE" | cut -d"," -f"$2")
    if ! expr "$lettersToNotMatchInCurrentPos" : ".*${1}.*" 1>/dev/null
    then
        updateLettersInPosToExclude "$1" "$2"
    fi
}

addLetterToExcludedIfNotAlreadyThere() {
    if ! expr "$EXCLUDED" : ".*${1}.*" 1>/dev/null 
    then
        EXCLUDED="${EXCLUDED}${1}"
    fi
}

isUserInputSameAsProvidedGuess() {
    if test "$(echo "$1" | sed 's/[GY]//')" = "$GUESS_TO_TRY"
    then
        return 0
    fi
    return 1
}

excludeNonExistentWordFromDictionaries() {
    sed "/^${1}[[:space:]]*$/d" "$DICTIONARY" > "$TEMP_DICT"
    cat "$TEMP_DICT" > "$DICTIONARY"
    sed "/^${1}[[:space:]]*$/d" "$WORDS" > "$TEMP_DICT"
    cat "$TEMP_DICT" > "$WORDS"
}

removePreviousGuess() {
    if test "$GUESS_NUMBER" -eq 1
    then
        newPrevGuesses=""
    else
        newPrevGuesses=$(echo "$PREV_GUESSES" | sed 's/[[:space:]][a-z][a-z]*$//')
    fi
    PREV_GUESSES="$newPrevGuesses" 
}

processResults() {
    if expr "$GUESS_RESULTS_FROM_USER" : '^[Nn]$' >/dev/null
    then
        excludeNonExistentWordFromDictionaries "$GUESS_TO_TRY"
        removePreviousGuess
        return 0
    fi
    HINT_TYPE="excludedLetter"
    LETTER_POS=1
    GUESS_NUMBER=$((GUESS_NUMBER + 1))
    for c in $(echo "$GUESS_RESULTS_FROM_USER" | fold -w 1)
    do
        if test "$c" = "G"
        then
            HINT_TYPE="correctLetterAndPosition"
            continue
        fi
        if test "$c" = "Y"
        then
            HINT_TYPE="includedLetterInWrongPosition"
            continue
        fi

        if test "$HINT_TYPE" = "correctLetterAndPosition"
        then
            addCorrectLetterToPosString "$c" "$LETTER_POS"
        fi
        if test "$HINT_TYPE" = "includedLetterInWrongPosition"
        then
            addToIncludedLettersAndToDoNotMatchList "$c" "$LETTER_POS"
        fi
        if test "$HINT_TYPE" = "excludedLetter"
        then
            if test "$LETTER_POS" -eq 1
            then
                addLetterToExcludedIfNotAlreadyThere "$c"
            else
                prevPositionTemp="$((LETTER_POS - 1))"
                prevCharacters=$(echo "$GUESS_TO_TRY" | cut -c 1-"$prevPositionTemp")
                if ! expr "$prevCharacters" : ".*${c}.*" > /dev/null
                then
                    addLetterToExcludedIfNotAlreadyThere "$c"
                fi
            fi
        fi

        LETTER_POS=$((LETTER_POS + 1))
        HINT_TYPE="excludedLetter"
    done
}

narrowDictionary() {
    includeExcludeLettersAndMatchPositions > "$TEMP_DICT"
    filterOutLettersNotInThisPosition > "$DICTIONARY"
}

decideWhatToDo() {
    # if lonely q or Q, then exit
    if expr "$GUESS_RESULTS_FROM_USER" : '^[Qq]$' >/dev/null
    then
        return 1
    fi

    # if there's only one element in the solved list, make that guess, and break.
    if test "$(grep -c '.*' "$DICTIONARY")" -eq 1
    then
        echo "The solution is: $(head -1 "$DICTIONARY")"
        return 1
    fi

    # if there's zero elements in the solved list, inform user, and break
    if test "$(grep -c '.*' "$DICTIONARY")" -eq 0
    then
        echo "Sorry, that word doesn't appear to be in my dictionary"
        return 1
    fi

    # If Last guess, then show possible guesses to user, then break.
    if test "$GUESS_NUMBER" = 6
    then
        echo "Sorry, I've failed you, but the solution is one of these:"
        cat "$DICTIONARY"
        return 1
    fi

    # If the solved list is equal to, or less than, the number of remaining guesses, tell the user to make those guesses and exit.
    if test "$(grep -c '.*' "$DICTIONARY")" -le "$(( 6 - GUESS_NUMBER ))"
    then
        echo "Try each of these:"
        cat "$DICTIONARY"
        return 1
    fi

    if test "$GUESS_NUMBER" = 1
    then
        displayGuessToTryDialog
        return 0
    fi

    # If the included letters >= (75 % of num letters), then start making guesses from the solved list.
    NUM_INCL="$(awk -v incl="$INCLUDED" 'BEGIN{print length(incl)}')"
    THREE_QUARTERS_NUM_LETTERS=$(echo "${NUM_LETTERS} * 0.75" | bc | sed 's/\..*$//')
    if test "$NUM_INCL" -ge "$THREE_QUARTERS_NUM_LETTERS" && test "$GUESS_NUMBER" -ge 3
    then
        echo "Try: $(head -1 "$DICTIONARY")"
        return 0
    fi


    # else keep generating good guesses
    displayGuessToTryDialog
    return 0

}

GUESS_NUMBER=1
POSITION_STRING=""
INCLUDED=""
EXCLUDED=""
LETTERS_IN_POS_TO_EXCLUDE=""
DICTIONARY=$(mktemp)
WORDS=$(mktemp)
TEMP_DICT=$(mktemp)
cat words.txt > "$DICTIONARY"
cat words.txt > "$WORDS"

main() {
    getNumberOfLetters
    POSITION_STRING=$(generatePositionString)
    LETTERS_IN_POS_TO_EXCLUDE=$(generateLettersInPosToExlude)

    PREV_GUESSES=""

    while true
    do
        decideWhatToDo
        if test $? = 1
        then
            break
        fi
        getGuessResultsFromUser
        processResults
        narrowDictionary
    done
}
main
