#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <bitset>

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

int main()
{

  // 0- 4294967295
  
  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<long long> randN(0, 4294967295);

  char del = '.';
  
  for (int i = 0; i < 600000000; ++i) {    
    long long r = randN(mt);
    string tmpstring = to_string(r);
    
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

    cout << sourceIP << endl;
    
    /*
    for (const auto subStr : split_string_2(tmpstring, del)) {
      unsigned long ipaddr_src;
      ipaddr_src = atoi(subStr.c_str());
      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
      std::string trans_string = trans.to_string();
      IPstring = IPstring + trans_string;
    }

    cout << IPstring << endl;
    */
  }

  return 0;
}

