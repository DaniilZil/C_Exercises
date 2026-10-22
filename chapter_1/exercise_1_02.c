/* Exercise 1-2. Investigate an unknown escape sequence.
 * Build with /DTEST_UNKNOWN_ESCAPE (MSVC) or -DTEST_UNKNOWN_ESCAPE (GCC).
 * \q is not a standard C escape: a diagnostic is required, and any
 * resulting executable has compiler-dependent behavior.
 */
#include <stdio.h>

int main(void)
{
#ifdef TEST_UNKNOWN_ESCAPE
    printf("Unknown escape: \q\n");
#else
    printf("Newline: first\nsecond\n");
    printf("Tab: left\tright\n");
    printf("Quote: \"  Backslash: \\\n");
    printf("Enable TEST_UNKNOWN_ESCAPE to experiment with \\q.\n");
#endif
    return 0;
}
