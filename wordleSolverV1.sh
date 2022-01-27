#!/bin/sh

getInputToGenerateGuess() {
    PREV_GUESSES=""
    if test -z "$NUM_LETTERS" 
    then
        echo "How many letters is this Wordle?"
        read -r NUM_LETTERS
    fi
    echo "Have you made guesses already?"
    read -r ANSWER
    if expr "$ANSWER" : '^[Yy][Ee][Ss].*' 1>/dev/null
    then
        echo "Please list those guesses separated by spaces"
        read -r PREV_GUESSES
    fi
}

getInputToSolveWordle() {
    if test -z "$NUM_LETTERS" 
    then
        echo "How many letters is this Wordle?"
        read -r NUM_LETTERS
    fi
    echo "What letters are yellow (included in the word but the position is unknown)?"    
    read -r INCLUDED
    echo "What letters are grey (not part of the word)?"    
    read -r EXCLUDED
    echo "What letters are green [format: _a_] (empty if none)?"    
    read -r POSITION_STRING
}

includeExcludeLettersAndMatchPositions() {
    echo "POSSIBLE SOLUTIONS:"
    if expr "$POSITION_STRING" : '^[a-z_]*[a-z][a-z_]*' 1>/dev/null
    then
        tr '[:upper:]' '[:lower:]' < words.txt \
            | sed 's/[[:space:]]*$//'          \
            | awk -v targetLength="$NUM_LETTERS" -f printOnlyDesiredLength.awk \
            | awk -v include="$INCLUDED" -v exclude="$EXCLUDED" -f includeAndExcludeLetters.awk \
            | awk -v letters="$POSITION_STRING" -f matchLetterPositions.awk
    else
        tr '[:upper:]' '[:lower:]' < words.txt \
            | sed 's/[[:space:]]*$//'          \
            | awk -v targetLength="$NUM_LETTERS" -f printOnlyDesiredLength.awk \
            | awk -v include="$INCLUDED" -v exclude="$EXCLUDED" -f includeAndExcludeLetters.awk 
    fi
    echo "END POSSIBLE SOLUTIONS"
}

generateGoodGuesses() {
    tr '[:upper:]' '[:lower:]' < words.txt \
    | sed 's/[[:space:]]*$//'              \
    | awk -v targetLength="$NUM_LETTERS" -v prevGuesses="$PREV_GUESSES" -f generateGoodGuess.awk
}

while true
do
    clear
    echo "OPTIONS:"
    echo "(g)et a good guess to try"
    echo "(s)olve world using info"
    printf "What would you like to do? (q to quit): "
    read -r USER_INPUT
    if expr "$USER_INPUT" : '^[Qq].*' 1>/dev/null
    then
        exit 0
    fi
    if expr "$USER_INPUT" : '^[Gg].*' 1>/dev/null
    then
        clear
        getInputToGenerateGuess
        generateGoodGuesses
        read -r
        clear
    fi
    if expr "$USER_INPUT" : '^[Ss].*' 1>/dev/null
    then
        clear
        getInputToSolveWordle
        includeExcludeLettersAndMatchPositions
        read -r
        clear
    fi
done
