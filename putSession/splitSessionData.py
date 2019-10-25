#!/usr/bin/python

maxline = 1000000

import sys
import os
from multiprocessing import Pool
import multiprocessing
import time
import datetime

argvs = sys.argv
argc = len(argvs)

if (argc != 3):
    print('Parameter Error')
    quit(1)

before_path = argvs[1]
after_path = argvs[2]

before_filelist = os.listdir(before_path)

def generate_actions(search_csv):

  with open(search_csv, 'r') as f:
    for line in f:
      yield line

def main(search_csv):

  search_csv = search_csv.rstrip()

  search_csv = os.path.join(before_path, search_csv)

  print ("{0} Split Start. ({1:%Y-%m-%d %H:%M:%S}) (PID = {2})".format(search_csv, datetime.datetime.now(), os.getpid()))
  cnt = 0

  after_filename = os.path.join(after_path, "INPUT_{0}_{1:%Y%m%d%H%M%S_%f}".format(os.getpid(), datetime.datetime.now()))
  f2 = open(after_filename, 'w')

  for line in generate_actions(search_csv):

    cnt += 1

    if (cnt > maxline):

      after_filename = os.path.join(after_path, "INPUT_{0}_{1:%Y%m%d%H%M%S_%f}".format(os.getpid(), datetime.datetime.now()))
      f2.close()
      f2 = open(after_filename, 'w')
      cnt = 1

    f2.write(line)

  f2.close()
  print ("{0} Split End. ({1:%Y-%m-%d %H:%M:%S}) (PID = {2})".format(search_csv, datetime.datetime.now(), os.getpid()))

if __name__ == '__main__':
    start = time.time()
    pool = Pool(multiprocessing.cpu_count())
    pool.map(main, before_filelist)
    elapsed_time = time.time() - start
    print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")
    pool.close()
