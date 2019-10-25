#!/usr/bin/python
import sys
import os
from multiprocessing import Pool
from elasticsearch import Elasticsearch
from elasticsearch import helpers
import multiprocessing
import time
import datetime
import csv

argvs = sys.argv
argc = len(argvs)

if (argc != 6):
  print('Parameter Error')
  quit(1)

after_path = argvs[1]
user = argvs[2]
address = argvs[3]
indexname = argvs[4]
conf_file = argvs[5]

if (address != '192.168.64.195:9200'):
  print('not allowed address')
  quit(1)

session_indexname = 'import_sessionlog_' + indexname
after_filelist = os.listdir(after_path)

f2 = open(conf_file, "r")
passwd = f2.readline()
f2.close()

passwd = passwd.rstrip()

def generate_actions(search_csv):
  
  with open(search_csv, 'r') as f:
    data = csv.reader(f)
    for row in data:
      yield {
             "_index": session_indexname,
             "_type": "doc",
             "_source": {
                "capture_time": row[0],
                "generated_time": row[1],
                "start_time": row[2],
                "elapsed_time": row[3],
                "source_ip": row[4],
                "source_port": row[5],
                "src_country_code": row[6],
                "destination_ip": row[7],
                "destination_port": row[8],
                "dest_country_code": row[9],
                "protocol": row[10],
                "application": row[11],
                "subtype": row[12],
                "action": row[13],
                "session_end_reason": row[14],
                "repeat_count": row[15],
                "category": row[16],
                "packets": row[17],
                "packets_sent": row[18],
                "packets_received": row[19],
                "bytes": row[20],
                "bytes_sent": row[21],
                "bytes_received": row[22],
                "device_name": row[23]}
      }

def main(search_csv):

  search_csv = search_csv.rstrip()
  search_csv = os.path.join(after_path, search_csv)

  print ("{0} Bulk Start. ({1:%Y-%m-%d %H:%M:%S}) (PID = {2})".format(search_csv, datetime.datetime.now(), os.getpid()))

  es = Elasticsearch(
  [address],
  http_auth=(user, passwd),
  timeout=180)

  for success, info in helpers.parallel_bulk(es, generate_actions(search_csv)):
    if not success:
      print("ERROR : ", info)
  
  print ("{0} Bulk End. ({1:%Y-%m-%d %H:%M:%S}) (PID = {2})".format(search_csv, datetime.datetime.now(), os.getpid()))

if __name__ == '__main__':
    start = time.time()
    pool = Pool(multiprocessing.cpu_count())
    pool.map(main, after_filelist)
    elapsed_time = time.time() - start
    print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")
    pool.close()
