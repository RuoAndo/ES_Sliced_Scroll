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

using namespace std;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

int main(int argc, char *argv[])
{
    int N = atoi(argv[1]);

    struct timespec startTime, endTime, sleepTime;
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<unsigned long long> randN(20190501000000000, 20190501235959000);
    std::uniform_int_distribution<long> randM(1, 10000);

    std::map<unsigned long long, long> mp;

    thrust::host_vector<unsigned long long> h_vec_key(N);
    thrust::host_vector<long> h_vec_value(N);

    for (int i = 0; i < N; ++i) {    
        unsigned long long n = randN(mt);
	long m = randM(mt);
	h_vec_key[i] = n;
	h_vec_value[i] = m;        
    }

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    thrust::device_vector<unsigned long long> d_vec_key(N);
    thrust::device_vector<long> d_vec_value(N);

    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());

    clock_gettime(CLOCK_REALTIME, &endTime);

    printf("[transfer hostToDevice]:");
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());

    thrust::device_vector<unsigned long long> d_vec_key_out(N);
    thrust::device_vector<long> d_vec_value_out(N);

    auto new_end = thrust::reduce_by_key(d_vec_key.begin(), d_vec_key.end(),
					 d_vec_value.begin(),
       	       	 		         d_vec_key_out.begin(),
					 d_vec_value_out.begin());

    int new_size_r = new_end.first - d_vec_key_out.begin();
    cout << "[new size]" << new_size_r << endl;

    clock_gettime(CLOCK_REALTIME, &endTime);

    printf("[reduction]:");
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::host_vector<unsigned long long> h_vec_key_2(N);
    thrust::host_vector<long> h_vec_value_2(N);

    thrust::copy(d_vec_value_out.begin(),d_vec_value_out.end(),
		 h_vec_value_2.begin());
    thrust::copy(d_vec_key_out.begin(),d_vec_key_out.end(),
                 h_vec_key_2.begin());

    unsigned long long *key_out;
    key_out = (unsigned long long *)malloc(new_size_r);

    long *value_out;
    value_out = (long *)malloc(new_size_r);

    for(int i = 0; i < new_size_r; i++)
    {
    	// cout << h_vec_key[i] << endl;
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }

    clock_gettime(CLOCK_REALTIME, &endTime);

    // 処理時間を出力
    // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
    // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
    // printf("経過実時間 = ");
    printf("[transfer deviceToHost]:");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    iTbb_Vec_timestamp::accessor t;
    for (int i = 0; i < 10; ++i) {
        unsigned long long n = randN(mt);
	long m = randM(mt);
	TbbVec_timestamp.insert(t, n);
	t->second += m;
	/*
        cout << key_out[i] << endl;
        TbbVec_timestamp.insert(t, key_out[i]);
	t->second += value_out[i];
	*/
    }

    printf("[hashmap insertion]:");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");

    return 0;
}

