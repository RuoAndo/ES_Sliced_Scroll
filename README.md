# Usenix LISA 2019

<pre>
#cd ./putSession
</pre>

modify USR and ADDRESS:
<pre>
# head -n 4 putSessionDataElastic.sh
1: DIR=$(cd $(dirname $0);pwd)/
2: 
3: USR=user_name
4: ADDRESS=192.168.0.3:9200
</pre>

set password of Elasticsearch:
<pre>
# cd conf/
# head -n 1 putSessionDataElastic.conf
server_password
</pre>

delete index (to make sure):
<pre>
curl -XDELETE username:password@192.168.64.195:9200/import_sessionlog_20190702
</pre>

build the binary:
<pre>
# ./build.sh rand_gen
</pre>

generate random data:
<pre>
# time ./rand_gen 100000

real    0m3.122s
user    0m2.985s
sys     0m0.136s
</pre>

move generated data to ./Output_SessionData
<pre>
# rm -rf Output_SessionData/random_data.txt
# mv random_data.txt ./Output_SessionData/
</pre>

