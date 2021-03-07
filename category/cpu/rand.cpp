#include <random>
#include <iostream>
int main(int argc, char *argv[])
{
  std::random_device rnd;     // 非決定的な乱数生成器
  for(int i = 0; i < atoi(argv[1]); i++) {
      std::cout << rnd() % 9999 << "\n";
  }
  return 0;
}


