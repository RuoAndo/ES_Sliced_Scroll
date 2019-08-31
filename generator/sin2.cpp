#include <stdio.h>
#include <math.h>

main()
{
  int i;

  int N;

  N = 18;
  
  double x;
  for(i = 0; i <= N; i++) {
    x = 3.1416 * (double)i / N * 2;
    printf("%f\n", sin(x));
  }
}
