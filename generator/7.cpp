#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <bitset>

int GetRandom(int min,int max);

using namespace std;

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

int main(void)
{
  int i;

  /*
  for (i = 0;i < 10;i++) {
		printf("%d\n",GetRandom(1,6));
  }
  */

  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<long long> randN(20190501000000000, 20190501235959000);

  // std::vector vc(N, 0);  

  for (int i = 0; i < 24; ++i) {    

    long long r = randN(mt);
    string tmpstring = to_string(r);

    for (int j = 0; j < 3; j++)
      {
	cout << "\"" << tmpstring.substr( 0, 4 )
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
	     << "\"" << "," ;
      }

    cout << "\"" << GetRandom(1,1000) << "\"" << ",";

    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<long long> randN(0, 4294967295);

    char del = '.';
  
    r = randN(mt);
    tmpstring = to_string(r);
    
    std::bitset<32> s = std::bitset<32>(stoull(tmpstring));
    string bs = s.to_string();

    string bs1 = bs.substr(0,8);
    int bi1 =  bitset<8>(bs1).to_ulong();
    
    string bs2 = bs.substr(8,8);
    int bi2 =  bitset<8>(bs2).to_ulong();

    string bs3 = bs.substr(16,8);
    int bi3 =  bitset<8>(bs3).to_ulong();
    
    string bs4 = bs.substr(24,8);
    int bi4 =  bitset<8>(bs4).to_ulong();

    string sourceIP = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);

    cout << "\"" << sourceIP << "\"";

      cout << endl;
    }
	
  return 0;
}

int GetRandom(int min,int max)
{
	return min + (int)(rand()*(max-min+1.0)/(1.0+RAND_MAX));
}

