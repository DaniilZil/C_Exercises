/* Exercise 1-17. Print lines longer than 80 characters.
 * The newline is not included in the length. Long lines are streamed.
 */
#include <stdio.h>

#define LIMIT 80

int main(void)
{
    char prefix[LIMIT];
    int c, length = 0, printing = 0;

    while ((c = getchar()) != EOF) {
        if (c == '\n') {
            if (printing)
                putchar(c);
            length = printing = 0;
        } else if (printing) {
            putchar(c);
        } else if (length < LIMIT) {
            prefix[length++] = (char)c;
        } else {
            fwrite(prefix, 1, LIMIT, stdout);
            putchar(c);
            printing = 1;
        }
    }
    return 0;
}
