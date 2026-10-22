/* Exercise 1-3. Add a heading to the Fahrenheit-Celsius table. */
#include <stdio.h>

int main(void)
{
    int fahr;
    double celsius;

    printf("Fahrenheit  Celsius\n");
    printf("----------  -------\n");
    for (fahr = 0; fahr <= 300; fahr += 20) {
        celsius = (5.0 / 9.0) * (fahr - 32);
        printf("%10d  %7.1f\n", fahr, celsius);
    }
    return 0;
}
