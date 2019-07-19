#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <random>
#include <functional> //for std::function
#include <algorithm>  //for std::generate_n

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"

using namespace tbb;
using namespace std;

concurrent_vector < string > IPpair;
std::vector<string> sv;
std::vector<string> sourceIP;
std::vector<string> destinationIP;
std::vector<string> timestamp;

std::vector<string> IPstring_src;
std::vector<string> IPstring_dst;

std::vector<string> counts;
std::vector<string> counts_sent;
std::vector<string> counts_recv;
std::vector<string> bytes;
std::vector<string> bytes_sent;
std::vector<string> bytes_recv;

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

int main( int argc, char* argv[] ) {

  int counter = 0;
  int N = atoi(argv[2]);  

  struct in_addr inaddr;
  char *some_addr;

  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<long long> randN(20190701000000000, 20190701235959000);

  
    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        // Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	std::remove("trans-tmp");
	ofstream outputfile("trans-tmp");

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  long long r = randN(mt);
	  string tmpstring = to_string(r);

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 

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

	    string sourceIP = "\"" + to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4) + "\"";

	    outputfile << rec[0] << "," << rec[1] << "," << rec[2] << "," << rec[3] << "," << sourceIP << "," 
	         << rec[5] << "," << rec[6] << "," << sourceIP << "," << rec[8] << "," << rec[9] << "," 
	         << rec[10] << "," << rec[11] << "," << rec[12] << "," << rec[13] << "," << rec[14] << "," 	 
	         << rec[15] << "," << rec[16] << "," << rec[17] << "," << rec[18] << "," << rec[19] << ","	   
	         << rec[20] << "," << rec[21] << "," << rec[22] << "," << rec[23] << endl;
	  }

	  outputfile.close();

	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
