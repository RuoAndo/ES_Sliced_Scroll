#!/bin/bash
############################################
#
#  Description:
#     Detriveing data from Elasticsearch in CSV format.
#
#
#  usage:
#     ./getSessionDataCSv.sh "start_time" "end_time"
#
#  Argument format:
#     start_time: yyyy/mm/dd hh24:mi
#     end_time: yyyy/mm/dd hh24:mi
#
############################################
# Parameter settings
############################################
# Level of multiplex
MULTIPLE=20

# Elasticsearch connection parameters
# Please change these four itmes in your environment
USR=your_name
PASSWD=your_passwd
ADDRESS=X.X.X.X:9200
INDEXNAME=index_name

# Output file directory 
OUTPUT_DIR=/data1/Output_SessionData

# Flag: whether output file should be decompressed or not 
COMPRESS_FLG=OFF

# Log file name
LOG_FILE=info_getSessionDataCSv.log

# Query Interval
QUERY_EXE_INTERVAL=5

############################################
# Subroutines
############################################
function printParamErr() {
    echo "--------------------------------------------"
    echo "-- [Usage] "
    echo "--     ./getSessionDataCSv.sh \"start_time\" \"end_time\""
    echo "--"
    echo "--     example: ./getSessionDataCSv.sh \"2018/06/22 18:00\" \"2018/06/22 18:59\""
    echo "--"
    echo "--     Argument format:"
    echo "--"
    echo "--         start_time: yyyy/mm/dd hh24:mi - filtering with capture_time"
    echo "--         end_time: yyyy/mm/dd hh24:mi - filtering with capture_time" 
    echo "--------------------------------------------"
    exit 1
}

function printDescription() {
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- Level of multiplex: ${MULTIPLE}"                                                  | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- The total number of data to be retrieved: ${total_num} "                          | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- Log file: ${LOG_FILE}                    "                                        | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- Output CSV: ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}_[Multiplicity].csv"    | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
}

####################################
### Parameter checking
####################################
## Arguments
if [ $# -ne 1 -a $# -ne 2 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError: Invalid parameter"
    echo "$0 $1 $2"
    printParamErr
fi

## Setting start_time
START_TIME=$1

if [ ${#START_TIME} -ne 16 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError: Invalid number of digits of start_time"
    printParamErr
fi

## Setting end_time
END_TIME=$2

if [ ${#END_TIME} -ne 16 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError: Invalid number of digits of end_time"
    printParamErr
fi

## Checking start_time and end_time
## transforming _time into seconds
START_TIME_SECOND=`date -d "${START_TIME}" '+%s'`
END_TIME_SECOND=`date -d "${END_TIME}" '+%s'`

if [ ${START_TIME_SECOND} -ge ${END_TIME_SECOND} ]; then
    echo "--------------------------------------------"
    echo "-- ParamError: Invalid start_time and end_time (identical or upside-down)"
    echo "--------------------------------------------"
    exit 1
fi

# Adding seconds value
START_TIME=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
END_TIME=`date +"%Y/%m/%d %H:%M:%S" -d "${END_TIME}"`

## Directory checking
if [ ! -e "${OUTPUT_DIR}" ]; then
    echo "--------------------------------------------"
    echo "-- OutPutDirectoryError: Output directory not found"
    echo "--------------------------------------------"
    exit 1
fi

############################################
# Pre-processing
############################################
max=${MULTIPLE}
slice_max=`expr ${max} - 1`
# Output file
FILE_START=`date +"%Y%m%d_%H%M" -d "${START_TIME}"`
FILE_END=`date +"%Y%m%d_%H%M" -d "${END_TIME}"`

cd $(dirname $0)

# Delete output file if existed
if [ "$(find ${OUTPUT_DIR} -maxdepth 1 -name OUTPUT_${FILE_START}-${FILE_END}*.csv)" != '' ]; then
    \rm -f ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}*.csv
fi

############################################
# Execution
############################################
echo "== Starting data retrieval: "`date +"%Y/%m/%d %H:%M:%S"`" ==" | tee -a ${LOG_FILE}

# Obtain the total number of data
echo '{"query":{                                              '  > count.json
echo '        "bool":{                                        ' >> count.json
echo '            "must":[                                    ' >> count.json
echo '                {                                       ' >> count.json
echo '                    "range":{                           ' >> count.json
echo '                        "capture_time":{                ' >> count.json
echo '                            "gte":"'$START_TIME'",      ' >> count.json
echo '                            "lt":"'$END_TIME'"          ' >> count.json
echo '                        }                               ' >> count.json
echo '                    }                                   ' >> count.json
echo '                }                                       ' >> count.json
echo '            ]                                           ' >> count.json
echo '        }                                               ' >> count.json
echo '     }                                                  ' >> count.json
echo '}                                                       ' >> count.json

total_num=`/bin/curl -s -u ${USR}:${PASSWD} -XGET "http://${ADDRESS}/${INDEXNAME}/_count" -H 'Content-Type: application/json' -d @count.json | /usr/local/bin/jq -r ".count"`

# Description of outputs
printDescription

# Date retrival time
NOW_TIME=${START_TIME}

## Transforming _time to seconds
NOW_TIME_SECOND=`date -d "${NOW_TIME}" '+%s'`

## The number of query issued
QUERY_EXE_NUM=`expr \( ${END_TIME_SECOND} - ${NOW_TIME_SECOND} \) / \( ${QUERY_EXE_INTERVAL} \* 60 \)`
if [ `expr \( ${END_TIME_SECOND} - ${NOW_TIME_SECOND} \) % \( ${QUERY_EXE_INTERVAL} \* 60 \)` -ne 0 ];then
    QUERY_EXE_NUM=`expr ${QUERY_EXE_NUM} + 1`
fi

## Date for query execution
DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME} ${QUERY_EXE_INTERVAL} minutes"`

## Counter for processing
CNT=0

echo -n "-- Retrieving data... PROGRESS: ${QUERY_EXE_NUM} / ["

while [ ${NOW_TIME_SECOND} -lt ${END_TIME_SECOND} ]
do

  # Obtain remaining time if the DATE_TO exceeds end_time
  if [ `date -d "${DATE_TO}" '+%s'` -gt ${END_TIME_SECOND} ]; then
      DATE_TO=${END_TIME}
  fi
  
  # Obtain the number of retrived data
  echo '{"query":{                                              '  > count.json
  echo '        "bool":{                                        ' >> count.json
  echo '            "must":[                                    ' >> count.json
  echo '                {                                       ' >> count.json
  echo '                    "range":{                           ' >> count.json
  echo '                        "capture_time":{                ' >> count.json
  echo '                            "gte":"'$DATE_FROM'",       ' >> count.json
  echo '                            "lt":"'$DATE_TO'"           ' >> count.json
  echo '                        }                               ' >> count.json
  echo '                    }                                   ' >> count.json
  echo '                }                                       ' >> count.json
  echo '            ]                                           ' >> count.json
  echo '        }                                               ' >> count.json
  echo '     }                                                  ' >> count.json
  echo '}                                                       ' >> count.json

  get_num=`/bin/curl -s -u ${USR}:${PASSWD} -XGET "http://${ADDRESS}/${INDEXNAME}/_count" -H 'Content-Type: application/json' -d @count.json | /usr/local/bin/jq -r ".count"`

  if [ ${get_num} -ne 0 ]; then

    # Data retrieval (async, multiplexed) 
    for i in `seq 0 ${slice_max}`
    do

      echo '{ "slice": { "id": '$i', "max": '$max' },               ' > search_${i}.json
      echo '"query":{                                               ' >> search_${i}.json
      echo '        "bool":{                                        ' >> search_${i}.json
      echo '            "must":[                                    ' >> search_${i}.json
      echo '                {                                       ' >> search_${i}.json
      echo '                    "range":{                           ' >> search_${i}.json
      echo '                        "capture_time":{                ' >> search_${i}.json
      echo '                            "gte":"'$DATE_FROM'",       ' >> search_${i}.json
      echo '                            "lt":"'$DATE_TO'"           ' >> search_${i}.json
      echo '                        }                               ' >> search_${i}.json
      echo '                    }                                   ' >> search_${i}.json
      echo '                }                                       ' >> search_${i}.json
      echo '            ]                                           ' >> search_${i}.json
      echo '        }                                               ' >> search_${i}.json
      echo '     }                                                  ' >> search_${i}.json
      echo '}                                                       ' >> search_${i}.json

      ./getSessionDataSlicedScroll.py search_${i}.json ${USR} ${PASSWD} ${ADDRESS} ${INDEXNAME} | /usr/local/bin/jq -r ".hits.hits[]._source | [\
       .capture_time,                                                                  \
       .generated_time,                                                                \
       .start_time,                                                                    \
       .elapsed_time,                                                                  \
       .source_ip,                                                                     \
       .source_port,                                                                   \
       .src_country_code,                                                              \
       .destination_ip,                                                                \
       .destination_port,                                                              \
       .dest_country_code,                                                             \
       .protocol,                                                                      \
       .application,                                                                   \
       .subtype,                                                                       \
       .action,                                                                        \
       .session_end_reason,                                                            \
       .repeat_count,                                                                  \
       .category,                                                                      \
       .packets,                                                                       \
       .packets_sent,                                                                  \
       .packets_received,                                                              \
       .bytes,                                                                         \
       .bytes_sent,                                                                    \
       .bytes_received,                                                                \
       .device_name                                                                    \
      ] | @csv" >> ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}_${i}.csv &

      # NOTICE): Items not retrived by this script
      #   .flags,                                                                         \
      #   .source_user,                                                                   \
      #   .action_source,                                                                 \
      #   .source_zone,                                                                   \
      #   .virtual_system,                                                                \
      #   .index_day,                                                                     \
      #   .dest_university_id,                                                            \
      #   .rule_name,                                                                     \
      #   .source_location,                                                               \
      #   .src_retention_period,                                                          \
      #   .src_university_id,                                                             \
      #   .host,                                                                          \
      #   .log_forwarding_profile,                                                        \
      #   .dest_retention_period,                                                         \
      #   .destination_zone,                                                              \
      #   .offset,                                                                        \
      #   .destination_location,                                                          \
      #   .source,                                                                        \
      #   .destination_user,                                                              \
      #   .session_id,                                                                    \

    # Synchronizing - checking if the aync threads are all done.
    done

    # Checking output status
    while :
    do
      exec_num=`ps -ef | grep getSessionDataSlicedScroll.py | grep python | wc -l`
      
      if [ ${exec_num} -eq 0 ]; then
        break
      fi
      
      sleep 3
      
    done
  fi
  
  DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_FROM} ${QUERY_EXE_INTERVAL} minutes"`
  DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_TO} ${QUERY_EXE_INTERVAL} minutes"`
  
  NOW_TIME=`date +"%Y/%m/%d %H:%M:%S" -d "${NOW_TIME} ${QUERY_EXE_INTERVAL} minutes"`
  NOW_TIME_SECOND=`date -d "${NOW_TIME}" '+%s'`
  
  # Progress status
  CNT=`expr ${CNT} + 1`
  if [ `expr ${CNT} % 10` -eq 0 ]; then
      echo -n "+"
  else
      echo -n "*"
  fi

# All done
done
echo "]"

echo "--------------------------------------------"
echo "== Data output is finished: "`date +"%Y/%m/%d %H:%M:%S"`" ==" | tee -a ${LOG_FILE}

##############
# Post-processing
##############
if [ ${COMPRESS_FLG} = "ON" ];then
  echo "== Starting the decompression of output fle: "`date +"%Y/%m/%d %H:%M:%S"`" =="
  zip -jqm ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}.zip ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}*.csv
  echo "== Decompresion is done. "`date +"%Y/%m/%d %H:%M:%S"`" =="
fi

# Deleting temporary files
\rm ./count.json 

if [ "$(find . -maxdepth 1 -name "search_*.json")" != '' ]; then
  \rm ./search_*.json
fi

exit 0

