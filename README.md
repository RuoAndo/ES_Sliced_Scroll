# ES_Sliced_Scroll - rev.2019.06.26

Elasticsearch provides scroll API for retrieving large numbers of results (or even all results) from a single search request, in much the same way as you would use a cursor on a traditional database. Unfortunately, in sequential manner, single scroll API invocation takes long time (more than 24 hours in general) to retrieve huge data data ranging from millions to billions.

<img src="scrollAPI.jpg" width=80%>

This figure depicts multiplexed scroll API of Elasticsearch. Key technique here is sliced scroll which is introduced in Elasticserch 5.0.0. Usually scroll queries return a lot of documents.By using sliced scroll, it is possible to split the scroll in multiple slices which can be consumed independently As shown in this figure, each process 1-6 is responsible for slices 1-6. Concerning process1 (slice1), it issues the query for ﬁve shards in data nodes. In total, 6(slices)∗5(shards) = 30(threads) are launched.

# Usage:

<pre>
# Elasticsearch connection parameters
# Please change these four itmes in your environment
USR= # user name #
PASSWD= # password of Elasticsearch #
ADDRESS= X.X.X.X:9200 # IP address and port number "
INDEXNAME= # index name #

# Output file directory 
OUTPUT_DIR= # /root/Output_SessionData #
</pre>