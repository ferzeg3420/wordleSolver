# Usage: awk -v targetLength="n" -f printOnlyDesiredLength.awk input.file

{
    if( length($1) == targetLength ) {
        print $1
    }
}
