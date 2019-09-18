#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <map>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

using namespace std;

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

    thrust::device_vector<unsigned long long> d_vec_key(N);
    thrust::device_vector<long> d_vec_value(N);

    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());
    
    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());

    /*
    thrust::host_vector<unsigned long long> h_vec_key_2(N);
    thrust::host_vector<long> h_vec_value_2(N);

    thrust::copy(d_vec_value.begin(),d_vec_value.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key.begin(),d_vec_key.end(),h_vec_key_2.begin());
    */

    /*reduce */
    thrust::device_vector<unsigned long long> d_vec_key_out(N);
    thrust::device_vector<long> d_vec_value_out(N);

    auto new_end = thrust::reduce_by_key(d_vec_key.begin(), d_vec_key.end(),
					 d_vec_value.begin(),
       	       	 		         d_vec_key_out.begin(),
					 d_vec_value_out.begin());

    int new_size_r = new_end.first - d_vec_key_out.begin();

    thrust::host_vector<unsigned long long> h_vec_key_2(N);
    thrust::host_vector<long> h_vec_value_2(N);

    thrust::copy(d_vec_value_out.begin(),d_vec_value_out.end(),
		 h_vec_value_2.begin());
    thrust::copy(d_vec_key_out.begin(),d_vec_key_out.end(),
                 h_vec_key_2.begin());

    /*
    for (int i = 0; i < new_size_r; ++i) {
      cout << h_vec_key_2[i] << "," << h_vec_value_2[i] << endl;
    }
    */

    clock_gettime(CLOCK_REALTIME, &endTime);

    // 処理時間を出力
    // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
    // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
    // printf("経過実時間 = ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    // printf("(秒)\n");

    return 0;
}

