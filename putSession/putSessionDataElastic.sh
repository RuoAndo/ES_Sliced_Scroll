DIR=$(cd $(dirname $0);pwd)/

USR=user_name
ADDRESS=192.168.0.3:9200

EL_CONF=${DIR}/conf/putSessionDataElastic.conf

CSV_DIR=${DIR}/Output_SessionData
WK_DIR=${DIR}/ElasticBulk_Data

if [ $# -ne 1  ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] invalid parameter"
  echo "--------------------------------------------"
  exit 1
fi

INDEXNAME=$1

expr "${INDEXNAME}" + 1 >/dev/null 2>&1
if [ $? -ge 2 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] invalid argument"
  echo "--------------------------------------------"
  exit 1
fi
if [ ${#INDEXNAME} -ne 8 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] invalid number of digits"
  echo "--------------------------------------------"
  exit 1
fi

if [ ! -d ${CSV_DIR} ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] ${CSV_DIR} directory not found"
  echo "--------------------------------------------"
  exit 1
fi
if [ ! -d ${WK_DIR} ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] ${WK_DIR} directory not found"
  echo "--------------------------------------------"
  exit 1
fi

if [ ! -f ${EL_CONF} ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] ${EL_CONF} file not found"
  echo "--------------------------------------------"
  exit 1
fi

#PG=`cat ${EL_CONF}`
#NOWTIME_AGO=`date -d "${INDEXNAME} 28day ago" +%Y%m%d`
#curl -XDELETE "http://${USR}:${PG}@${ADDRESS}/import_sessionlog_${NOWTIME_AGO}" -sS -m 60 --retry 3
#echo ""
#if [ $? -ne 0 ]; then
#  echo "--------------------------------------------"
#  echo "-- [ERROR] faliture: index deletion"
#  echo "--------------------------------------------"
#  exit 1
#fi

####################################
echo "--------------------------------------------"
echo "-- putSessionDataElastic.sh (start) ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"
echo "--------------------------------------------"
echo "-- getSessionDataCSv.sh: checking process ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

while :
do
  exec_num=`ps -ef | grep "getSessionData" | grep -v grep | wc -l`
  
  if [ ${exec_num} -eq 0 ]; then
    break
  fi
  
  sleep 30
  
done

\rm ${WK_DIR}/INPUT_* >/dev/null 2>&1

echo "--------------------------------------------"
echo "-- splitSessionData.py(start) ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

./splitSessionData.py ${CSV_DIR} ${WK_DIR}

if [ $? -ne 0 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] splitSessionData.py terminted"
  echo "--------------------------------------------"
  exit 1
fi

echo "--------------------------------------------"
echo "-- splitSessionData.py: finished ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

wk_num=`find ${WK_DIR}/INPUT_* -type f | wc -l`

if [ ${wk_num} -eq 0 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] ${WK_DIR} Data not found"
  echo "--------------------------------------------"
  exit 1
fi

echo "--------------------------------------------"
echo "-- putSessionDataElasticBulk.py (start) ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

./putSessionDataElasticBulk.py ${WK_DIR} ${USR} ${ADDRESS} ${INDEXNAME} ${EL_CONF}

if [ $? -ne 0 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] putSessionDataElasticBulk.py terminated"
  echo "--------------------------------------------"
  exit 1
fi

echo "--------------------------------------------"
echo "-- putSessionDataElasticBulk.py finished ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

curl -XPUT "http://${USR}:${PG}@${ADDRESS}/import_sessionlog_${INDEXNAME}/_settings" -sS -m 10 --retry 3 -H 'Content-Type: application/json' -d '{"index" : {"number_of_replicas" : 1}}'
if [ $? -ne 0 ]; then
  echo "--------------------------------------------"
  echo "-- [ERROR] failure: changing the number of replicas"
  echo "--------------------------------------------"
  exit 1
fi
echo ""

echo "--------------------------------------------"
echo "-- putSessionDataElastic.sh (finished) ["`date +"%Y/%m/%d %H:%M:%S"`"]"
echo "--------------------------------------------"

exit 0
