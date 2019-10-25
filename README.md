# Usenix LISA 2019

<pre>
.
|-- clustering
|   `-- gpu
|-- discern
|   |-- cpu
|   `-- gpu
|-- generator
|-- misc
|-- parallel_exporter
|   `-- Output_SessionData
|-- plot
|-- putSession
|   |-- conf
|   |-- ElasticBulk_Data
|   `-- Output_SessionData
`-- reduction
    |-- cpu
    |-- gpu
    `-- stl
</pre>

clustering: under testing

discern: direction disrimination (you will need your own IP address list to match)
<pre>
X.X.X.X/24
Y.Y.Y.Y/28
</pre>

generator: random session data generator.

misc: tester of CUDA Thrust API

paralel_exporter: parallel scroll API invocation

plot: matplotlib

putSession: parallel bulk inserter

reduction: histogramming with CUDA Thrust and Intel TBB

# [1] Parallel bulk inserter

<pre>
#cd ./putSession
</pre>

1.1: Modify USR and ADDRESS:
<pre>
# head -n 4 putSessionDataElastic.sh
1: DIR=$(cd $(dirname $0);pwd)/
2: 
3: USR=user_name
4: ADDRESS=192.168.0.3:9200
</pre>

1.2: Set password of Elasticsearch:
<pre>
# cd conf/
# head -n 1 putSessionDataElastic.conf
server_password
</pre>

1.3: Delete index (to make sure):
<pre>
curl -XDELETE username:password@192.168.64.195:9200/import_sessionlog_20190702
</pre>

1.4: Build the binary:
<pre>
# ./build.sh rand_gen
</pre>

1.5: Generate random data:
<pre>
# time ./rand_gen 100000

real    0m3.122s
user    0m2.985s
sys     0m0.136s
</pre>

1.6: Move generated data to ./Output_SessionData
<pre>
# rm -rf Output_SessionData/random_data.txt
# mv random_data.txt ./Output_SessionData/
</pre>

1.7: Execute
<pre>
time ./putSessionDataElastic.sh 20190702                                                                            
--------------------------------------------
-- putSessionDataElastic.sh (start) [2019/10/25 17:36:41]
--------------------------------------------
--------------------------------------------
-- getSessionDataCSv.sh: checking process [2019/10/25 17:36:41]
--------------------------------------------
--------------------------------------------
-- splitSessionData.py(start) [2019/10/25 17:36:41]
--------------------------------------------
/mnt/data/ES_Sliced_Scroll/putSession//Output_SessionData/random_data.txt Split Start. (2019-10-25 17:36:41) (PID = 152900)
/mnt/data/ES_Sliced_Scroll/putSession//Output_SessionData/random_data.txt Split End. (2019-10-25 17:36:41) (PID = 152900)
elapsed_time:0.1305809021[sec]
--------------------------------------------
-- splitSessionData.py: finished [2019/10/25 17:36:42]
--------------------------------------------
--------------------------------------------
-- putSessionDataElasticBulk.py (start) [2019/10/25 17:36:42]
--------------------------------------------
/mnt/data/ES_Sliced_Scroll/putSession//ElasticBulk_Data/INPUT_152900_20191025173641_982501 Bulk Start. (2019-10-25 17:36:42) (PID = 153070)
/mnt/data/ES_Sliced_Scroll/putSession//ElasticBulk_Data/INPUT_152900_20191025173641_982501 Bulk End. (2019-10-25 17:36:43) (PID = 153070)
elapsed_time:1.28126597404[sec]
--------------------------------------------
-- putSessionDataElasticBulk.py finished [2019/10/25 17:36:43]
--------------------------------------------
{"error":{"root_cause":[{"type":"security_exception","reason":"failed to authenticate user [elastic]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}}],"type":"security_exception","reason":"failed to authenticate user [elastic]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}},"status":401}
--------------------------------------------
-- putSessionDataElastic.sh (finished) [2019/10/25 17:36:43]
--------------------------------------------

real    0m1.953s
user    0m1.333s
sys     0m1.614s
</pre>

You see the error message above. But it might be OK.

# [2] Parallel exporter

2.1: Modify USR, PASSWD and ADDRESS.

<pre>
# head -n 30 ./getSessionDataCSv.sh

 18# Level of multiplex
 19MULTIPLE=32
 20
 21# Elasticsearch connection parameters
 22# Please change these four itmes in your environment
 23USR=user_name
 24PASSWD=password
 25ADDRESS=192.168.0.3:9200
 26INDEXNAME=session_info
</pre>

2.2 Execute (after 1.1-1.7 done)
<pre>
# ./getSessionDataCSv.sh "2019/07/02 00:00" "2019/07/02 23:59"

/mnt/data/ES_Sliced_Scroll/parallel_exporter
== Starting data retrieval: 2019/10/25 17:50:02 ==
--------------------------------------------
-- Level of multiplex: 32
--------------------------------------------
-- The total number of data to be retrieved: 10000
--------------------------------------------
-- Log file: info_getSessionDataCSv.log
--------------------------------------------
-- Output CSV: /mnt/data/ES_Sliced_Scroll/parallel_exporter/Output_SessionData/OUTPUT_20190702_0000-20190702_2359_32.csv
--------------------------------------------
-- Retrieving data... PROGRESS: 288 / [*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+*********+********]
--------------------------------------------
== Data output is finished: 2019/10/25 17:54:58 ==
</pre>
