# USAGE: awk -v solution="$solution" -v guess="$GUESS_TO_TRY" -f getGuessResults.awk 

BEGIN{
    result=""
    prevYellowLength=0
    split(solution, solutionCharArray, "")
    split(guess, guessCharArray, "")
    if( length(guessCharArray) != length(solutionCharArray) ) {
        exit 1
    }
    len=length(guessCharArray);
    for( j = 1; j <= len; j++ ) {
        guessChar = guessCharArray[j];
        isYellowSet=1
        isGreySet=1
        if( guessChar == solutionCharArray[j] ) {
            result = result "G" guessChar
            continue
        }
        for( k = 1; k <= prevYellowLength; k++ ) {
            if( guessChar == prevYellow[k] ) {
                isGreySet=0
                result = result guessChar
                break
            }
        }
        if( isGreySet == 0 ) {
            continue
        }
        
        for( i = 1; i <= len; i++ ) {
            if( j == i ) {
                continue
            }
            solnChar=solutionCharArray[i];
            if( solnChar == guessChar ) {
                prevYellowLength++
                prevYellow[prevYellowLength]=guessChar
                result = result "Y" guessChar
                isYellowSet=0
                break
            }
        }
        if( isYellowSet == 0 ) {
            continue
        }
        result = result guessChar
    }
    print result
}
