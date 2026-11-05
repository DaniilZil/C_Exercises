/* Chapter 5, lecture 1, slide 5: unnumbered pointer-tracing exercise.
 * Correct the slide's typo np = &np to np = &n, as explained in speech.
 * Initially: m=10, n=5. After the first assignment: m=15, n=5.
 * After the second assignment: m=15, n=10.
 */
#include <stdio.h>

int main(void)
{
    int m = 10, n = 5;
    int *mp, *np;

    mp = &m;
    np = &n;
    *mp = *mp + *np;
    *np = *mp - *np;
    printf("%d %d\n%d %d\n", m, *mp, n, *np);
    return 0;
}
