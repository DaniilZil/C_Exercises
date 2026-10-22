/* Exercise 1-21. Use the minimum tabs/spaces for each run of spaces.
 * Prefer a space if a single space and a tab reach the same stop.
 * Existing tabs are preserved. Tab stops match exercise 1-20.
 */
#include <stdio.h>

#define TAB_WIDTH 8

int main(void)
{
    int c, column = 0, spaces = 0;

    while ((c = getchar()) != EOF) {
        if (c == ' ') {
            ++spaces;
            column = (column + 1) % TAB_WIDTH;
            if (column == 0) {
                if (spaces > 1)
                    putchar('\t');
                else
                    putchar(' ');
                spaces = 0;
            }
        } else {
            /* A following tab can absorb the pending spaces. */
            if (c == '\t')
                spaces = 0;
            while (spaces > 0) {
                putchar(' ');
                --spaces;
            }
            putchar(c);
            if (c == '\n' || c == '\r' || c == '\t')
                column = 0;
            else
                column = (column + 1) % TAB_WIDTH;
        }
    }
    while (spaces > 0) {
        putchar(' ');
        --spaces;
    }
    return 0;
}
