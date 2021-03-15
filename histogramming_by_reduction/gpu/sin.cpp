#include <fstream>
#include <cmath>

int main()
{
  static const double pi = 3.141592653589793;
  std::ofstream file("sin.tsv");
  /*
  for (double x = -3.0*pi; x <= 3.0*pi; x += 0.1) {
    file << std::sin(x) << "\n";
  }
  */

  for(int i = 0; i < 100; i++) {
    file << std::sin(i) << "\n";
  }
	
}
