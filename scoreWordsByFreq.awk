# Usage: awk -f scoreWordsByFreq.awk dictionary.input

function scoreWord(targetLettersAsArray, candidateWordAsArray) 
{
    resultingScore=0
    isRepeatedLetter=0
    lengthOfTargetArray=length(targetLettersAsArray)
    lengthOfCandidateWord=length(candidateWordArray)

    for( i = 1; i <= lengthOfCandidateWord; i++ ){
        for( j = 1; j <= lengthOfTargetArray; j++ ){
            if( candidateWordArray[i] == targetLettersAsArray[j] ){
                resultingScore = resultingScore + (lengthOfTargetArray - j + 1)
                break
            }
        }
    }
    return resultingScore
}

BEGIN{
    split("etaoinsrhdlucmfywgpbvkxqjz" , MOST_FREQUENT_LETTERS_ARRAY, "")
}

{
    split($1, candidateWordArray, "")
    score=scoreWord(MOST_FREQUENT_LETTERS_ARRAY, candidateWordArray)
    print score, $1
}
