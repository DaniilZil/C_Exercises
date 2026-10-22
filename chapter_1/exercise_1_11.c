/* Exercise 1-11. Test a word-counting program.
 * Words are separated by spaces, tabs, or newlines, as on the slide.
 * Test: empty input; whitespace only; one word without a newline;
 * leading/trailing whitespace; repeated separators; multiple lines.
 * Examples (lines, words, characters): "" -> 0,0,0;
 * "one" -> 0,1,3; " one\t two\n" -> 1,2,10; " \t\n" -> 1,0,3.
 */
#include <stdio.h>

#define IN 1
#define OUT 0

int main(void)
{
    int c, state = OUT;
    unsigned long lines = 0, words = 0, characters = 0;

    while ((c = getchar()) != EOF) {
        ++characters;
        if (c == '\n')
            ++lines;
        if (c == ' ' || c == '\t' || c == '\n')
            state = OUT;
        else if (state == OUT) {
            state = IN;
            ++words;
        }
    }
    printf("Lines: %lu\nWords: %lu\nCharacters: %lu\n",
           lines, words, characters);
    return 0;
}
