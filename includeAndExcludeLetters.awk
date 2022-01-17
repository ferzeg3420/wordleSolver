# Usage: awk -v include="abc" -v exclude="def" -f includeAndExcludeLetters.awk input.file

function doesInclude(includeLetters, word) {
    isLetterIncluded=0
    for( i = 1; i <= length(includeLetters); i++) {
        for( j = 1; j <= length(word); j++ ) {
            if( includeLetters[i] == word[j] ) {
                isLetterIncluded=1
                break
            }
        }
        if( !isLetterIncluded ) {
            return 0
        }
        isLetterIncluded=0
    }
    return 1
}

function doesExclude(excludeLetters, word) {
    for( i = 1; i <= length(excludeLetters); i++) {
        for( j = 1; j <= length(word); j++ ) {
            if( excludeLetters[i] == word[j] ) {
                return 0
            }
        }
    }
    return 1
}

function isIncludingExcludedLetters(includeLetters, excludeLetters) {
    for( i = 1; i <= length(includeLetters); i++) {
        for( j = 1; j <= length(excludeLetters); j++ ) {
            if( includeLetters[i] == excludeLetters[j] ) {
                return 1
            }
        }
    }
    return 0
}

BEGIN{
    split(include, INCLUDED, "")
    split(exclude, EXCLUDED, "")

    if( isIncludingExcludedLetters(INCLUDED, EXCLUDED) ) {
        print "ERROR: including excluded letters!"
        exit
    }
}

{
   wordToCheck=$1
   split(wordToCheck, wordToCheckAsArray, "")
   if( doesInclude(INCLUDED, wordToCheckAsArray) && doesExclude(EXCLUDED, wordToCheckAsArray) ) {
       print wordToCheck
   }
}
