#include <algorithm>
#include <cfloat>
#include <chrono>
#include <fstream>
#include <iostream>
#include <random>
#include <sstream>
#include <vector>
#include <boost/tokenizer.hpp>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <random>
#include "timer.h"

using namespace std;

__device__ float
squared_l2_distance(float x_1, float y_1, float x_2, float y_2) {
  return (x_1 - x_2) * (x_1 - x_2) + (y_1 - y_2) * (y_1 - y_2);
}

float
squared_l2_distance_h(float x_1, float y_1, float x_2, float y_2) {
  return (x_1 - x_2) * (x_1 - x_2) + (y_1 - y_2) * (y_1 - y_2);
}

__global__ void assign_clusters(const thrust::device_ptr<float> data_x,
                                const thrust::device_ptr<float> data_y,
                                int data_size,
                                const thrust::device_ptr<float> means_x,
                                const thrust::device_ptr<float> means_y,
                                thrust::device_ptr<float> new_sums_x,
                                thrust::device_ptr<float> new_sums_y,
                                int k,
                                thrust::device_ptr<int> counts,
				thrust::device_ptr<int> d_clusterNo) {
				
  const int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index >= data_size) return;

  // Make global loads once.
  const float x = data_x[index];
  const float y = data_y[index];

  float best_distance = FLT_MAX;
  int best_cluster = 0;
  for (int cluster = 0; cluster < k; ++cluster) {
    const float distance =
        squared_l2_distance(x, y, means_x[cluster], means_y[cluster]);
    if (distance < best_distance) {
      best_distance = distance;
      best_cluster = cluster;
    }
  }

  // d_clusterNo[index] = best_cluster;
  //  __syncthreads();

  atomicAdd(thrust::raw_pointer_cast(new_sums_x + best_cluster), x);
  atomicAdd(thrust::raw_pointer_cast(new_sums_y + best_cluster), y);
  atomicAdd(thrust::raw_pointer_cast(counts + best_cluster), 1);
}

__global__ void compute_new_means(thrust::device_ptr<float> means_x,
                                  thrust::device_ptr<float> means_y,
                                  const thrust::device_ptr<float> new_sum_x,
                                  const thrust::device_ptr<float> new_sum_y,
                                  const thrust::device_ptr<int> counts) {
  const int cluster = threadIdx.x;
  const int count = max(1, counts[cluster]);
  means_x[cluster] = new_sum_x[cluster] / count;
  means_y[cluster] = new_sum_y[cluster] / count;
}

void sort(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int thread_id)
{
    int GPU_number = thread_id % 4;

    // cout << "transfer:threadID:" << thread_id << ",data size:" << "," << data_size << endl;

    thrust::host_vector<unsigned long long> h_vec_key(data_size);
    thrust::host_vector<long> h_vec_value(data_size);

    for(int i=0; i < data_size; i++)
    {
	h_vec_key[i] = key[i];
	h_vec_value[i] = value[i];
    }

    cudaSetDevice(GPU_number);
    
    thrust::device_vector<unsigned long long> d_vec_key(data_size);
    thrust::device_vector<long> d_vec_value(data_size);

    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());
    
    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());

    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<long> h_vec_value_2(data_size);

    thrust::copy(d_vec_value.begin(),d_vec_value.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key.begin(),d_vec_key.end(),h_vec_key_2.begin());

    /*
    for(int i = 0; i < 3; i++)
    {
	cout << "[sort result] threadID:" << thread_id << ":" << h_vec_key_2[i] << ","
	     << h_vec_value_2[i] << endl;
    }
    */
    
    for(int i = 0; i < data_size; i++)
    {
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }
}

void transfer(unsigned long long *key_1, float *value_1, unsigned long long *key_2, float *value_2, unsigned long long *key_out, float *value_out, int kBytes, int vBytes, size_t data_size, int *new_size, int thread_id)
{
    // unsigned int t, travdirtime;
    int GPU_number = thread_id % 4;

    clock_t start_t = clock();

    thrust::host_vector<unsigned long long> h_vec_key_1(data_size);
    thrust::host_vector<float> h_vec_value_1(data_size);
    for(int i=0; i < data_size; i++)
    {
	h_vec_key_1[i] = key_1[i];
	h_vec_value_1[i] = value_1[i];
    }

    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<float> h_vec_value_2(data_size);
    for(int i=0; i < data_size; i++)
    {
	h_vec_key_2[i] = key_2[i];
	h_vec_value_2[i] = value_2[i];
    }

    //start_timer(&t);
    cudaSetDevice(GPU_number);
    
    thrust::device_vector<unsigned long long> d_vec_key_1(data_size);
    thrust::device_vector<float> d_vec_value_1(data_size);
    thrust::copy(h_vec_key_1.begin(), h_vec_key_1.end(), d_vec_key_1.begin());
    thrust::copy(h_vec_value_1.begin(), h_vec_value_1.end(), d_vec_value_1.begin());

    thrust::device_vector<unsigned long long> d_vec_key_2(data_size);
    thrust::device_vector<float> d_vec_value_2(data_size);
    thrust::copy(h_vec_key_2.begin(), h_vec_key_2.end(), d_vec_key_2.begin());
    thrust::copy(h_vec_value_2.begin(), h_vec_value_2.end(), d_vec_value_2.begin());
    
    /* reduction 1 */
    thrust::sort_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin());
    thrust::device_vector<unsigned long long> d_vec_key_out_1(data_size);
    thrust::device_vector<float> d_vec_value_out_1(data_size);

    auto new_end_1 = thrust::reduce_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin(),
       	       	 		       d_vec_key_out_1.begin(), d_vec_key_out_1.begin());

    int new_size_r_1 = new_end_1.first - d_vec_key_out_1.begin();

    /* reduction 2 */
    thrust::sort_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin());
    thrust::device_vector<unsigned long long> d_vec_key_out_2(data_size);
    thrust::device_vector<float> d_vec_value_out_2(data_size);

    auto new_end_2 = thrust::reduce_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin(),
       	       	 		       d_vec_key_out_2.begin(), d_vec_key_out_2.begin());

    int new_size_r_2 = new_end_2.first - d_vec_key_out_2.begin();

    int k = 10;
    int number_of_iterations = 1000;
    // int counter = 0;

    thrust::device_vector<float> d_x(new_size_r_2);
    thrust::device_vector<float> d_y(new_size_r_2);
    
    thrust::device_vector<int> d_clusterNo(new_size_r_2);

    thrust::copy(d_vec_value_out_1.begin(), d_vec_value_out_1.end(), d_x.begin());
    thrust::copy(d_vec_value_out_2.begin(), d_vec_value_out_2.end(), d_y.begin());

    thrust::host_vector<float> h_x(new_size_r_2);
    thrust::host_vector<float> h_y(new_size_r_2);
    std::mt19937 rng(std::random_device{}());
    std::shuffle(h_x.begin(), h_x.end(), rng);
    std::shuffle(h_y.begin(), h_y.end(), rng);
    thrust::device_vector<float> d_mean_x(h_x.begin(), h_x.begin() + k);
    thrust::device_vector<float> d_mean_y(h_y.begin(), h_y.begin() + k);

    thrust::device_vector<float> d_sums_x(k);
    thrust::device_vector<float> d_sums_y(k);
    thrust::device_vector<int> d_counts(k, 0);

    const size_t number_of_elements = new_size_r_2;
    const int threads = 1024;
    const int blocks = (number_of_elements + threads - 1) / threads;

    const auto start = std::chrono::high_resolution_clock::now();
    for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
     thrust::fill(d_sums_x.begin(), d_sums_x.end(), 0);
     thrust::fill(d_sums_y.begin(), d_sums_y.end(), 0);
     thrust::fill(d_counts.begin(), d_counts.end(), 0);

     assign_clusters<<<blocks, threads>>>(d_x.data(),
                                         d_y.data(),
                                         number_of_elements,
                                         d_mean_x.data(),
                                         d_mean_y.data(),
                                         d_sums_x.data(),
                                         d_sums_y.data(),
                                         k,
                                         d_counts.data(),
					 d_clusterNo.data());

     cudaDeviceSynchronize();

     compute_new_means<<<1, k>>>(d_mean_x.data(),
                                d_mean_y.data(),
                                d_sums_x.data(),
                                d_sums_y.data(),
                                d_counts.data());
    cudaDeviceSynchronize();
    }

  const auto end = std::chrono::high_resolution_clock::now();
  const auto duration =
  std::chrono::duration_cast<std::chrono::duration<float>>(end - start);
  // std::cerr << "Took: " << duration.count() << "s" << std::endl;

  thrust::host_vector<float> h_mean_x = d_mean_x;
  thrust::host_vector<float> h_mean_y = d_mean_y;
  thrust::host_vector<int> h_counts = d_counts;
  thrust::host_vector<int> h_clusterNo(d_clusterNo.size());

  float distance;
  int best_cluster;

  for(int i = 0; i < new_size_r_2; i++)
  {
	float best_distance = FLT_MAX;
	for (int cluster = 0; cluster < k; ++cluster) {	
    	    distance = squared_l2_distance_h(h_x[i], h_y[i], h_mean_x[cluster], h_mean_y[cluster]);
	    // std::cout << h_x[i] << "," << h_y[i] << "," << cluster << "," << distance << endl;
	    
	    if (distance < best_distance) {
      	      	 best_distance = distance;
      		 best_cluster = cluster;
             }
 
	}	
	// std::cout << "*" << h_x[i] << "," << h_y[i] << "," << best_cluster << "," << distance << endl;
	h_clusterNo[i] = best_cluster;
  }

  std::string fname_clstr = "clustered_" + thread_id;
  // std::remove(fname_clstr);
  ofstream outputfile(fname_clstr);  

  int sum;

  int nBytes = k * sizeof(float);

  float *percent;
  percent = (float *)malloc(nBytes);
  
  for (size_t cluster = 0; cluster < k; ++cluster) {
    sum = sum + h_counts[cluster];
  }

  for (size_t cluster = 0; cluster < k; ++cluster) {
    percent[cluster] = (float)h_counts[cluster] / (float)sum;
  }

  thrust::host_vector<unsigned long long> h_vec_key_f(new_size_r_2);
  thrust::copy(d_vec_key_out_2.begin(),d_vec_key_out_2.end(),h_vec_key_f.begin());


  for(int i=0; i < new_size_r_2; i++)
  {
	outputfile << h_vec_key_f[i] << "," << h_x[i] << "," << h_y[i] << ", cluster" << h_clusterNo[i] << ",(" << percent[h_clusterNo[i]] << "%)" << std::endl;
  }

  outputfile.close();

    /*
    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<long> h_vec_value_2(data_size);

    thrust::copy(d_vec_value_out.begin(),d_vec_value_out.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key_out.begin(),d_vec_key_out.end(),h_vec_key_2.begin());

    for(int i = 0; i < new_size_r; i++)
    {
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }

    clock_t end_t = clock();
    const double time = static_cast<double>(end_t - start_t) / CLOCKS_PER_SEC * 1000.0;
    cout << "thread:" << thread_id << " - reduction done with new_size " << new_size_r
    	 << "(" << data_size << ") - " << time << endl;

    (*new_size) = new_size_r;
    */
}

void kernel(long *h_key, long *h_value_1, long *h_value_2, string filename, int size)
{
  int N = size;

  cout << "kernel" << endl;

  for(int i = 0; i < 5; i++)
  {
	cout << h_key[i] << "," << h_value_1[i] << endl;
  }

  thrust::host_vector<int> h_vec_1(N);
  std::generate(h_vec_1.begin(), h_vec_1.end(), rand); 

  thrust::device_vector<int> key_in(N);
  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin()); 

  thrust::host_vector<unsigned long long> h_vec_key_1(N);
  thrust::host_vector<unsigned long long> h_vec_key_2(N);

  thrust::host_vector<long> h_vec_value_1(N);
  thrust::host_vector<long> h_vec_value_2(N);

  cout << N << endl;

  for(int i=0; i < N; i++)
  {
	// cout << h_key[i] << endl;
	h_vec_key_1[i] = h_key[i];
	h_vec_key_2[i] = h_key[i];
	h_vec_value_1[i] = h_value_1[i];
	h_vec_value_2[i] = h_value_2[i];
  }

  /* 1 -> 3 */

  thrust::device_vector<unsigned long long> d_vec_key_1(N);
  thrust::device_vector<long> d_vec_value_1(N);
  thrust::copy(h_vec_key_1.begin(), h_vec_key_1.end(), d_vec_key_1.begin());
  thrust::copy(h_vec_value_1.begin(), h_vec_value_1.end(), d_vec_value_1.begin());

  // thrust::sort_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin(), thrust::greater<unsigned long long>());

  thrust::sort_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin());

  thrust::host_vector<unsigned long long> h_vec_key_3(N);
  thrust::host_vector<long> h_vec_value_3(N);

  thrust::copy(d_vec_value_1.begin(),d_vec_value_1.end(),h_vec_value_3.begin());
  thrust::copy(d_vec_key_1.begin(),d_vec_key_1.end(),h_vec_key_3.begin());

  /* 2 -> 4 */

  thrust::device_vector<unsigned long long> d_vec_key_2(N);
  thrust::device_vector<long> d_vec_value_2(N);
  thrust::copy(h_vec_key_2.begin(), h_vec_key_2.end(), d_vec_key_2.begin());
  thrust::copy(h_vec_value_2.begin(), h_vec_value_2.end(), d_vec_value_2.begin());

  // thrust::sort_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin(), thrust::greater<unsigned long long>());

  thrust::sort_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin());

  thrust::host_vector<unsigned long long> h_vec_key_4(N);
  thrust::host_vector<long> h_vec_value_4(N);

  thrust::copy(d_vec_value_2.begin(),d_vec_value_2.end(),h_vec_value_4.begin());
  thrust::copy(d_vec_key_2.begin(),d_vec_key_2.end(),h_vec_key_4.begin());

  cout << "1 -> 3" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_3[i] << "," << h_vec_value_3[i] << endl;
  }

  cout << "2 -> 4" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_4[i] << "," << h_vec_value_4[i] << endl;
  }

  thrust::device_vector<unsigned long long> d_vec_key_1_out(N);
  thrust::device_vector<long> d_vec_value_1_out(N);

  thrust::device_vector<unsigned long long> d_vec_key_2_out(N);
  thrust::device_vector<long> d_vec_value_2_out(N);

  auto new_end_1 = thrust::reduce_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin(),
       	       	 		       d_vec_key_1_out.begin(), d_vec_value_1_out.begin());

  int new_size_1 = new_end_1.first - d_vec_key_1_out.begin() + 1; 

  thrust::host_vector<unsigned long long> h_vec_key_3_out(N);
  thrust::host_vector<long> h_vec_value_3_out(N);

  thrust::copy(d_vec_value_1_out.begin(),d_vec_value_1_out.end(),h_vec_value_3_out.begin());
  thrust::copy(d_vec_key_1_out.begin(),d_vec_key_1_out.end(),h_vec_key_3_out.begin());

  auto new_end_2 = thrust::reduce_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin(),
       	       	 		       d_vec_key_2_out.begin(), d_vec_value_2_out.begin());      

  int new_size_2 = new_end_2.first - d_vec_key_2_out.begin();// + 1; 

  thrust::host_vector<unsigned long long> h_vec_key_4_out(N);
  thrust::host_vector<long> h_vec_value_4_out(N);

  thrust::copy(d_vec_value_2_out.begin(),d_vec_value_2_out.end(),h_vec_value_4_out.begin());
  thrust::copy(d_vec_key_2_out.begin(),d_vec_key_2_out.end(),h_vec_key_4_out.begin());

  cout << "1 -> 3" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << endl;
  }

  cout << "2 -> 4" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_4_out[i] << "," << h_vec_value_4_out[i] << endl;
  }

  ofstream outputfile(filename);
    
  cout << "all" << endl;

  outputfile << "timestamp, counted, bytes" << endl;
  
  for(int i = 0; i < new_size_2; i++)
  {
	// cout << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;

	/*
	if(h_vec_key_3_out[i] != 0)
		outputfile << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;
	*/
	
	std::string timestamp = to_string(h_vec_key_3_out[i]);

	outputfile << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" << timestamp.substr(6,2) << " "
	     	   << timestamp.substr(8,2) << ":" << timestamp.substr(10,2) << ":" << timestamp.substr(12,2)
	     	   << "." << timestamp.substr(14,3) << "," 
		   << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;
  }

  outputfile.close();
  
}


