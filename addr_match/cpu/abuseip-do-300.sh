cp /root/blacklist.txt .

shuf -n 1000 blacklist.txt > tmp
./append.sh tmp | tee list-abuseipdb

./multi_measure_2.sh abuseipdb
