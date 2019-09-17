#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <map>

#include <stdio.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"

using namespace std;
using namespace tbb;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

int main(int argc, char *argv[])
{

    int N = atoi(argv[1]);
  
    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<unsigned long long> randN(20190501000000000, 20190501235959000);
    std::uniform_int_distribution<long> randM(1, 10000);

    std::map<unsigned long long, long> mp;

    iTbb_Vec_timestamp::accessor t;

    for (int i = 0; i < N; ++i) {    
        unsigned long long n = randN(mt);
	long m = randM(mt);
        TbbVec_timestamp.insert(t, n);
	t->second += m;
    }

    /*
    for(auto itr = mp.begin(); itr != mp.end(); ++itr) {
      cout << itr->first << "," << itr->second << endl;
    }
    */

    std::map<unsigned long long, long> final;
    
    for(auto itr = TbbVec_timestamp.begin(); itr != TbbVec_timestamp.end(); ++itr)    {
      final.insert(std::make_pair((unsigned long long)(itr->first), long(itr->second)));
    }

    /*
    for(auto itr = final.begin(); itr != final.end(); ++itr) {
      std::string timestamp = to_string(itr->first);
      cout << itr->first << "," << itr->second << endl;
    }
    */

    return 0;
}

