/* Exercise 1-9. Replace each run of spaces with one space. */
#include <stdio.h>

int main(void)
{
    int c;
    int previous_space = 0;

    while ((c = getchar()) != EOF) {
        if (c != ' ' || !previous_space)
            putchar(c);
        previous_space = (c == ' ');
    }
    return 0;
}
