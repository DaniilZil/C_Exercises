/* Exercise 1-20. Replace tabs with spaces to the next tab stop.
 * A symbolic constant is appropriate because stops are fixed.
 */
#include <stdio.h>

#define TAB_WIDTH 8

int main(void)
{
    int c, column = 0, spaces;

    while ((c = getchar()) != EOF) {
        if (c == '\t') {
            spaces = TAB_WIDTH - column;
            while (spaces-- > 0)
                putchar(' ');
            column = 0;
        } else {
            putchar(c);
            if (c == '\n' || c == '\r')
                column = 0;
            else
                column = (column + 1) % TAB_WIDTH;
        }
    }
    return 0;
}
