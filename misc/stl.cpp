#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <map>

#include <stdio.h>

using namespace std;

int main(int argc, char *argv[])
{

    int N = atoi(argv[1]);
  
    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<unsigned long long> randN(20190501000000000, 20190501235959000);
    std::uniform_int_distribution<long> randM(1, 10000);

    std::map<unsigned long long, long> mp;
    
    for (int i = 0; i < N; ++i) {    
        unsigned long long n = randN(mt);
	long m = randM(mt);
	mp.insert(std::make_pair(n, m));
	// cout << n << "," << m << endl;
    }

    /*
    for(auto itr = mp.begin(); itr != mp.end(); ++itr) {
      cout << itr->first << "," << itr->second << endl;
    }
    */
    
    return 0;
}

