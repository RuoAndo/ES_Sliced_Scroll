cp /root/blacklist.txt .

shuf -n 500 blacklist.txt > tmp
./append.sh tmp | tee list-abuseipdb

./multi_measure_2.sh abuseipdb
