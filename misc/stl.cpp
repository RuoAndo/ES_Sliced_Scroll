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

    struct timespec startTime, endTime, sleepTime;

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
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

    clock_gettime(CLOCK_REALTIME, &endTime);

    // 処理時間を出力
    // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
    // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
    // printf("経過実時間 = ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    // printf("(秒)\n");
    
    return 0;
}

