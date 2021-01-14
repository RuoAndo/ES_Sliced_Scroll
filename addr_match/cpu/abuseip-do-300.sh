cp /root/blacklist.txt .

g++ -o rand rand.cpp
./rand 300 > list-rand
./listgen.sh list-rand > list-abuseipdb

#shuf -n 1000 blacklist.txt > tmp
#./append.sh tmp | tee list-abuseipdb

#./multi_measure_2.sh abuseipdb
