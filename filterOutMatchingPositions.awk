# Usage: awk -v lettersToExcludeInCVSPos="lettersInPos1,lettersInPos2,..." -f filterOutMatchingPositions.awk words.txt

function doesNotMatchLetterInPosition(lettersToExcludeInPosArray,
                                   candidateWordAsArray) 
{
    for( i = 1; i <= length(lettersToExcludeInCVSPosArray); i++ ) {
        if( length(candidateWordAsArray) < i ) {
            break
        }
        split(lettersToExcludeInCVSPosArray[i], lettersToExcludeArray, "")
        for( j = 1; j <= length(lettersToExcludeArray); j++ ) {
            if( lettersToExcludeArray[j] == candidateWordAsArray[i] ) {
                return 0
            }
        }
    }
    return 1
}

BEGIN {
    split(lettersToExcludeInCVSPos, lettersToExcludeInCVSPosArray, ",")
}

{
    split($1, candidateWord, "")
    if( doesNotMatchLetterInPosition(lettersToExcludeInCVSPosArray,
                                     candidateWord) ) {
        print $1
    }
}
