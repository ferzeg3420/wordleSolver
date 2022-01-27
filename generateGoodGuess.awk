# Usage: awk -v targetLength="n" -v prevGuesses="[word1 [word2 [...]]]" -f generateGoodGuess.awk dictionary.input

function scoreWord(targetLettersAsArray, candidateWordAsArray) {
    resultingScore=0
    isRepeatedLetter=0
    for( i = 1; i <= targetLength; i++ ) {
        for( j = 1; j <= targetLength; j++ ) {
            for( k = (j - 1); k >= 1; k-- ) {
                if( candidateWordAsArray[j] == candidateWordAsArray[k] ) {
                    isRepeatedLetter=1
                    break
                }
            }
            if( isRepeatedLetter ) {
                continue
            }
            if( targetLettersAsArray[i] == candidateWordAsArray[j] ) {
                resultingScore = resultingScore + (targetLength + 1 - i)
                break
            }
        }
    }
    return resultingScore
}

BEGIN {
    BEST_SCORE=0
    BEST_WORD=""
    split(prevGuesses, prevGuessesArray, " ")

    prevGuessesCombinedString=""
    for( n = 0; n < length(prevGuessesArray); n++ ) {
        prevGuessesCombinedString = prevGuessesCombinedString prevGuessesArray[n]
    }
    split(prevGuessesCombinedString, prevGuessesCombinedArray, "")

    mostFreqExceptAlreadyUsed=""
    split("etaoinsrhdlucmfywgpbvkxqjz" , mostFreqArray, "")
    for( i = 1; i <= length(mostFreqArray); i++ ) {
        shouldExclude=0
        for( j = 1; j <= length(prevGuessesCombinedArray); j++) {
            if( mostFreqArray[i] == prevGuessesCombinedArray[j] ) {
                shouldExclude=1
                break
            }
        }
        if( shouldExclude ) {
            continue
        }
        mostFreqExceptAlreadyUsed = mostFreqExceptAlreadyUsed mostFreqArray[i]
    }
    if( length(mostFreqExceptAlreadyUsed) > targetLength) {
        mostFreqExceptAlreadyUsed=substr(mostFreqExceptAlreadyUsed, 1, targetLength)
    }
    else {
        for( k = 0; k < (targetLength - length(mostFreqExceptAlreadyUsed)); k++) {
            mostFreqExceptAlreadyUsed= mostFreqExceptAlreadyUsed " "
        }
    }
    split(mostFreqExceptAlreadyUsed, MOST_FREQUENT_LETTERS_ARRAY, "")
}

{
    if( length($1) == targetLength ) {
        split($1, candidateWordArray, "")
        scoreIter=scoreWord(MOST_FREQUENT_LETTERS_ARRAY, candidateWordArray)
        if( scoreIter > BEST_SCORE ) {
            BEST_SCORE=scoreIter
            BEST_WORD=$1
        }
    }
}

END {
    print BEST_WORD
}
