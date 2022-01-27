# Wordle Solver CLI

## Instructions

- Open the [wordle website](https://wordlegame.org/) and start a
puzzle, but don't make any guesses yet.

- Back on the CLI, an interactive dialogue will prompt you for the
number of letters in the wordle challenge. The default on the
official website is 5.

- The program will then show you a word to use as your first guess.
Type that word into the wordle website's game and press enter.

- Then, on the CLI, you will be prompted for the results of your
guess. This is entered by typing each letter from the result (from
the worle website) preceded by the uppercase frist letter of the
color that letter is painted with. Grey is an exception to this
rule because no letter needs to preceed it.

For example, guess: atone | result: atYonGe. The 'a', 't', and 'n'
are grey. The 'o' is yellow. And the 'e' is Green.

- Then keep making the guesses provided by the program. If a guess
is not part of wordle's dictionary, then type a single 'N' as the
result of your guess. This will exclude that word from the dictionary
(only for this session) and provide you with a different guess.

- When entering the results of a guess, one can use a single 'Q'
to quit the program.

## How to run the program

On the terminal:

```
$ ./wordleSolver.sh 
```

## How this program is structured

* The .awk files are awk programs that filter out words from the
dictionary to land on the right guess.

* These are all put together in a posix shell script (wordleSolver.sh).
