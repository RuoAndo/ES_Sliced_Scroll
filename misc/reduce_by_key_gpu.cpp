#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <map>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"

#include "timer.h"

using namespace std;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

extern void transfer(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int* new_size, int thread_id);
extern void sort(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int thread_id);

int main(int argc, char *argv[])
{
    int N = atoi(argv[1]);
    unsigned int t, travdirtime;
    
    start_timer(&t);
    
    struct timespec startTime, endTime, sleepTime;
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<unsigned long long> randN(20190501000000000, 20190501005959000);
    std::uniform_int_distribution<long> randM(1, 10000);

    std::map<unsigned long long, long> mp;

    size_t kBytes = N * sizeof(unsigned long long);
    size_t vBytes = N * sizeof(long);

    unsigned long long *key;
    key = (unsigned long long *)malloc(kBytes);

    long *value;
    value = (long *)malloc(vBytes);

    unsigned long long *key_out;
    key_out = (unsigned long long *)malloc(kBytes);
    
    long *value_out;
    value_out = (long *)malloc(vBytes);

    for (int i = 0; i < N; ++i) {    
        unsigned long long n = randN(mt);
	long m = randM(mt);
	key[i] = n;
	value[i] = m;        
    }

    int new_size=0;
    transfer(key, value, key_out, value_out, kBytes, vBytes, N, &new_size, 0);

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    for(int i = 0; i < new_size; i++)
      {
	iTbb_Vec_timestamp::accessor tms;
	TbbVec_timestamp.insert(tms, key_out[i]);
	tms->second += value_out[i];
      }

    printf("[hashmap insertion] - ");
    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec @ %d \n", new_size);

    free(key);
    free(value);
    free(key_out);
    free(value_out);

    kBytes = TbbVec_timestamp.size() * sizeof(unsigned long long);
    key = (unsigned long long *)malloc(kBytes);

    vBytes = TbbVec_timestamp.size() * sizeof(long);
    value = (long *)malloc(vBytes);

    key_out = (unsigned long long *)malloc(kBytes);
    value_out = (long *)malloc(vBytes);

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    int i = 0;
    for(auto itr = TbbVec_timestamp.begin(); itr != TbbVec_timestamp.end(); ++itr) {
      key[i] = (unsigned long long)(itr->first);
      value[i] = (long)(itr->second);
      i++;
    }

    sort(key, value, key_out, value_out, kBytes, vBytes, TbbVec_timestamp.size(),0);

    printf("[sort] - ");
    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec @ %d \n", new_size);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    
    return 0;
}

