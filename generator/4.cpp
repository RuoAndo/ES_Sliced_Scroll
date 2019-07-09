#include <iostream>
#include <vector>
#include <random>
#include <vector>

using namespace std;
int main()
{

    // 20190501000000000
    // 20190501235959000
  
    // const int N = 10000;  
    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<long long> randN(20190501000000000, 20190501235959000);

    // std::vector vc(N, 0);  

    for (int i = 0; i < 24; ++i) {    
        long long r = randN(mt);
	string tmpstring = to_string(r);
	
	cout << tmpstring.substr( 0, 4 )
	     << "-"
	     << tmpstring.substr( 4, 2 ) 
	     << "-"
	     << tmpstring.substr( 6, 2 )
	     << " "
	     << tmpstring.substr( 8, 2 )
	     << ":"
	     << tmpstring.substr( 10, 2 )
	     << ":"
	     << tmpstring.substr( 12, 2 )
	     << "."
	     << tmpstring.substr( 14, 3 )
	     << endl;
    
    }

    return 0;
}

