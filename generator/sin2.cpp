#include <stdio.h>
#include <math.h>
#include <time.h>

#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <bitset>
#include<fstream>

#include <functional> //for std::function
#include <algorithm>  //for std::generate_n
 
int GetRandom(int min,int max)
{
	return min + (int)(rand()*(max-min+1.0)/(1.0+RAND_MAX));
}

main()
{
  int i;

  int N;

  N = 1000;

  float result;
  
  float num;
  srand(time(NULL));   

  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<long> randD(0,32767);

  long tmp; 
  
  double x;
  for(i = 0; i <= N; i++) {
    x = 3.1416 * (double)i / N * 2;

    tmp = randD(mt);
    num = ((float)tmp -16000) / ((float)32767.0);

    result = (float)sin(x) + (float)num;
    
    // printf("%f, %f, %f \n", sin(x), num, result);
    printf("%f\n", result);
  }
}
