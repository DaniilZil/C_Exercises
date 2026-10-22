/* Exercise 2-3. Convert hexadecimal text to an int.
 * Accept optional 0x/0X and both letter cases.
 * Return -1 for empty/invalid input or a value greater than INT_MAX.
 */
#include <stdio.h>
#include <limits.h>

int htoi(const char s[]);

int main(void)
{
    const char *samples[] = { "84ada", "f", "F0", "12fab", "0x2A", "0Xff" };
    int i;

    for (i = 0; i < 6; ++i)
        printf("htoi('%s') = %d\n", samples[i], htoi(samples[i]));
    return 0;
}

int htoi(const char s[])
{
    int i = 0, n = 0, digit;

    if (s == NULL)
        return -1;
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        i = 2;
    if (s[i] == '\0')
        return -1;
    for (; s[i] != '\0'; ++i) {
        if (s[i] >= '0' && s[i] <= '9')
            digit = s[i] - '0';
        else if (s[i] >= 'a' && s[i] <= 'f')
            digit = s[i] - 'a' + 10;
        else if (s[i] >= 'A' && s[i] <= 'F')
            digit = s[i] - 'A' + 10;
        else
            return -1;
        if (n > (INT_MAX - digit) / 16)
            return -1;
        n = 16 * n + digit;
    }
    return n;
}
