#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
This script retrieves whole data from alias in async manner using SclicedScrill
"""
import sys
import logging
import logging.config

argvs = sys.argv
argc = len(argvs)

if (argc != 6):
    print('Parameter Error')
    print('Usage: ./getSessionDataSlicedScroll.py search_X.json user passwd address(IP:port) indexname')
    quit()

search_file = argvs[1]
user = argvs[2]
passwd = argvs[3]
address = argvs[4]
indexname = argvs[5]

from elasticsearch import Elasticsearch
import datetime
import json
 
# Reading JSON file
f = open(search_file)
data = json.load(f)
f.close()

class Search_Sessionlog_Sliced_Scroll(object):
    def main(self):

        # Log output settings
        logging.config.fileConfig('logging.conf')
        logger = logging.getLogger('Search_Sessionlog_Sliced_Scroll')

        logger.info('Starting data output of %s',search_file)

        self.es = Elasticsearch(
            [address],
            http_auth=(user, passwd),
            timeout=180)

        res = self.es.search(
            index=indexname,
            size="10000",
            scroll="30s",
            body=data
            )

        # get scroll id
        scroll_id = res["_scroll_id"]

        # convert json
        response = json.dumps(res, indent=2, separators=(',', ': '))

        # output
        print response

        num=1
        # Searching all data
        while 0 < len(res["hits"]["hits"]):
            res = self.es.scroll(scroll_id=scroll_id, scroll="30s")
            response_scroll = json.dumps(res, indent=2, separators=(',', ': '))

            # output
            print response_scroll

             # Mitigating verbose log output for performace
#            num+=1
#            mod = num % 10
#            if mod == 0:
#                mult = num * 10000
#                logger.info('# of data output of %s: %s',search_file, '{:,}'.format(mult))

        logger.info('Data output of %s is done.',search_file)

if __name__ == '__main__':
    search_sessionlog_all = Search_Sessionlog_Sliced_Scroll()
    search_sessionlog_all.main()


