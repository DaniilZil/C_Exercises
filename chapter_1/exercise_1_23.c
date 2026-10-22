/* Exercise 1-23. Remove C comments, preserving quoted literals.
 * Replace each comment with a space to avoid joining adjacent tokens.
 * Preserve comment newlines; support both block and line comments.
 * Backslash-newline splicing is performed before recognizing comments.
 */
#include <stdio.h>

enum state { CODE, STRING, CHARACTER, BLOCK_COMMENT, LINE_COMMENT };

int source_char(void);

int main(void)
{
    int c, next, escaped = 0, previous = 0;
    enum state state = CODE;

    while ((c = source_char()) != EOF) {
        if (state == BLOCK_COMMENT) {
            if (c == '\n')
                putchar('\n');
            if (previous == '*' && c == '/') {
                state = CODE;
                previous = 0;
            } else {
                previous = c;
            }
        } else if (state == LINE_COMMENT) {
            if (c == '\n') {
                putchar(c);
                state = CODE;
            }
        } else if (state == STRING || state == CHARACTER) {
            putchar(c);
            if (escaped)
                escaped = 0;
            else if (c == '\\')
                escaped = 1;
            else if ((state == STRING && c == '"') ||
                     (state == CHARACTER && c == '\''))
                state = CODE;
        } else if (c == '/') {
            next = source_char();
            if (next == '*' || next == '/') {
                putchar(' ');
                state = next == '*' ? BLOCK_COMMENT : LINE_COMMENT;
                previous = 0;
            } else {
                putchar(c);
                /* A non-comment lookahead must still be parsed as code. */
                if (next == EOF)
                    break;
                putchar(next);
                if (next == '"')
                    state = STRING;
                else if (next == '\'')
                    state = CHARACTER;
            }
        } else {
            putchar(c);
            if (c == '"')
                state = STRING;
            else if (c == '\'')
                state = CHARACTER;
        }
    }
    if (state == BLOCK_COMMENT || state == STRING || state == CHARACTER) {
        fprintf(stderr, "Unterminated comment or quoted literal.\n");
        return 1;
    }
    return 0;
}

int source_char(void)
{
    int c, next;

    while ((c = getchar()) == '\\') {
        next = getchar();
        if (next != '\n') {
            if (next != EOF)
                ungetc(next, stdin);
            return c;
        }
    }
    return c;
}
