Random (session) data generator

<pre>
Usage: ./9 [the number of data to be generated]

# ./build.sh 9
# ./9 100000                                                                      
# wc -l random_data.txt                                                           
100000 random_data.txt

# head -n 2 random_data.txt                                                        
"2019-05-01 08:38:45.010",
"2019-05-01 08:38:45",
"2019-05-01 08:38:45",
"841",
"*.*.82.39",
"25846",
"ua",
"*.*.163.161",
"51321",
"aI",
"SCu",
"HFCi1qAnY",
"Xub",
"Aregp",
"ab8tqr2Y",
"8",
"cyX3duDunIjVkTzAMIFLO7S8WA",
"912",
"198",
"336",
"769",
"278",
"554",
"rand-pa1"
</pre>

Fields description.

<pre>
  - 1  capture_time 
  - 2  generated_time
  - 3  start_time
  - 4  elapsed_time
  - 5  source_ip
  - 6  source_port
  - 7  src_country_code
  - 8  destination_ip
  - 9  destination_port
  - 10  dest_country_code
  - 11  protocol
  - 12  application
  - 13  subtype
  - 14  action
  - 15  session_end_reason
  - 16  repeat_count
  - 17  category
  - 18  packets
  - 19  packets_sent
  - 20  packets_received
  - 21  bytes
  - 22  bytes_sent
  - 23  bytes_received
  - 24  device_name
</pre>

<pre>
# time ./aipr 1000000000                                                         
real    56m15.670s
user    39m38.850s
sys     16m35.885s

# head -n 2 random_data.txt                                                      
"2019/07/02 00:00:00.000","841","25846"
"2019/07/02 00:00:00.000","784","52326"

# ls -alh random_data.txt 
-rw-r--r-- 1 root root 37G  8月 21 14:16 random_data.txt
</pre>
