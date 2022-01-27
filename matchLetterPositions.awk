# Usage: awk -v letters="_a_d" -f matchLetterPositions.awk input.file

function min(a, b) {
    if( a <= b ) {
        return a
    }
    return b
}

function doesMatchLetterInPosition(targetLettersAsArray, candidateWordAsArray) {
    loopEnd=min(length(targetLettersAsArray), length(candidateWordAsArray))
    for( i = 0; i <= loopEnd; i++ ) {
        if( targetLettersAsArray[i] != "_" \
            && targetLettersAsArray[i] != candidateWordAsArray[i]) {
            return 0
        }
    }
    return 1
}

BEGIN {
    split(letters, TARGET_LETTERS_ARRAY, "")
}

{
    split($1, candidateWord, "")
    if( doesMatchLetterInPosition(TARGET_LETTERS_ARRAY, candidateWord) ) {
        print $1
    }
}
