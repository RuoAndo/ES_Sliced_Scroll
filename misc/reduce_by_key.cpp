#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <map>
#include <chrono>

#include <stdio.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"

#include <boost/timer/timer.hpp>

using namespace std;
using namespace tbb;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

int main(int argc, char *argv[])
{

    int N = atoi(argv[1]);

    // boost::timer::cpu_timer timer;
    // timer.start(); 

    /*
    std::chrono::system_clock::time_point  start, end; 
    start = std::chrono::system_clock::now(); 
    */

    struct timespec startTime, endTime, sleepTime;

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

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

    clock_gettime(CLOCK_REALTIME, &endTime);

    // 処理時間を出力
    // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
    // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
    // printf("経過実時間 = ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    // printf("(秒)\n");
    
    /*
    for(auto itr = final.begin(); itr != final.end(); ++itr) {
      std::string timestamp = to_string(itr->first);
      cout << itr->first << "," << itr->second << endl;
    }
    */

    // timer.stop();
    
    // std::string result = timer.format();
    // std::cout << result << std::endl;

    /*
    end = std::chrono::system_clock::now(); 
    double elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(end-start).count();
    */

    // cout << elapsed << endl;
    
    return 0;
}

