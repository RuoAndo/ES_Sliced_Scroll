#!/bin/bash
############################################
#
# 【概要】
#     ElasticからデータをCSV形式で取得する。
#
# 【使用方法】
#     ./getSessionDataCSv.sh "抽出開始日時" "抽出終了日時"
#
#     ＜各引数の説明＞
#         抽出開始日時：必須 抽出期間の開始日時（yyyy/mm/dd hh24:mi）※capture_timeで絞り込みする
#
#         抽出終了日時：必須 抽出期間の終了日時（yyyy/mm/dd hh24:mi）※capture_timeで絞り込みする
#
############################################
# 定数定義
############################################
# 多重度
MULTIPLE=20

# Elasticsearch接続パラメータ
USR=your_name
PASSWD=your_password
ADDRESS=X.X.X.X:9200
INDEXNAME=session_info

# ファイル出力ディレクトリ
OUTPUT_DIR=./

# 出力ファイル圧縮フラグ
COMPRESS_FLG=OFF

# 実行ログファイル名
LOG_FILE=info_getSessionDataCSv.log

## クエリ実行間隔
QUERY_EXE_INTERVAL=5

############################################
# サブ関数
############################################
function printParamErr() {
    echo "--------------------------------------------"
    echo "-- 【使用方法】"
    echo "--     ./getSessionDataCSv.sh \"抽出開始日時\" \"抽出終了日時\""
    echo "--"
    echo "--     例) ./getSessionDataCSv.sh \"2018/06/22 18:00\" \"2018/06/22 18:59\""
    echo "--"
    echo "--     ＜各引数の説明＞"
    echo "--"
    echo "--         抽出開始日時：必須 抽出期間の開始日時（yyyy/mm/dd hh24:mi）※capture_timeで絞り込みする"
    echo "--"
    echo "--         抽出終了日時：必須 抽出期間の終了日時（yyyy/mm/dd hh24:mi）※capture_timeで絞り込みする"
    echo "--------------------------------------------"
    exit 1
}

function printDescription() {
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- 多重度：${MULTIPLE}"                                                              | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- 取得予定総件数：${total_num} 件"                                                  | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                        | tee -a ${LOG_FILE}
   echo "-- 実行ログファイル：${LOG_FILE}                                                   " | tee -a ${LOG_FILE}
   echo "--------------------------------------------" | tee -a ${LOG_FILE}
   echo "-- 出力CSVファイル：${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}_[多重度].csv" | tee -a ${LOG_FILE}
   echo "--------------------------------------------"                                    | tee -a ${LOG_FILE}
}

####################################
### パラメータチェック
####################################
## 引数
if [ $# -ne 1 -a $# -ne 2 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError：引数が正しくありません"
    echo "$0 $1 $2"
    printParamErr
fi

## 抽出開始日時
START_TIME=$1

if [ ${#START_TIME} -ne 16 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError：抽出開始日時の桁数が正しくありません"
    printParamErr
fi

## 抽出終了日時
END_TIME=$2

if [ ${#END_TIME} -ne 16 ]; then
    echo "--------------------------------------------"
    echo "-- ParamError：抽出終了日時の桁数が正しくありません"
    printParamErr
fi

## 開始、終了チェック
## 時刻を秒に変換する
START_TIME_SECOND=`date -d "${START_TIME}" '+%s'`
END_TIME_SECOND=`date -d "${END_TIME}" '+%s'`

if [ ${START_TIME_SECOND} -ge ${END_TIME_SECOND} ]; then
    echo "--------------------------------------------"
    echo "-- ParamError：開始、終了日時が同じ、もしくは逆転しています"
    echo "--------------------------------------------"
    exit 1
fi

# 秒追加
START_TIME=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
END_TIME=`date +"%Y/%m/%d %H:%M:%S" -d "${END_TIME}"`

## ディレクトリチェック
if [ ! -e "${OUTPUT_DIR}" ]; then
    echo "--------------------------------------------"
    echo "-- OutPutDirectoryError：出力先ディレクトリが見つかりません"
    echo "--------------------------------------------"
    exit 1
fi

############################################
# 前処理
############################################
max=${MULTIPLE}
slice_max=`expr ${max} - 1`
# 出力ファイル用
FILE_START=`date +"%Y%m%d_%H%M" -d "${START_TIME}"`
FILE_END=`date +"%Y%m%d_%H%M" -d "${END_TIME}"`

cd $(dirname $0)

# 出力ファイルが存在している場合は削除する
if [ "$(find ${OUTPUT_DIR} -maxdepth 1 -name OUTPUT_${FILE_START}-${FILE_END}*.csv)" != '' ]; then
    \rm -f ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}*.csv
fi

############################################
# 実行
############################################
echo "== データ出力処理開始: "`date +"%Y/%m/%d %H:%M:%S"`" ==" | tee -a ${LOG_FILE}

# total件数取得
echo '{"query":{                                              '  > count.json
echo '        "bool":{                                        ' >> count.json
echo '            "must":[                                    ' >> count.json
echo '                {                                       ' >> count.json
echo '                    "range":{                           ' >> count.json
echo '                        "capture_time":{                ' >> count.json
echo '                            "gte":"'$START_TIME'",      ' >> count.json
echo '                            "lt":"'$END_TIME'"         ' >> count.json
echo '                        }                               ' >> count.json
echo '                    }                                   ' >> count.json
echo '                }                                       ' >> count.json
echo '            ]                                           ' >> count.json
echo '        }                                               ' >> count.json
echo '     }                                                  ' >> count.json
echo '}                                                       ' >> count.json

total_num=`/bin/curl -s -u ${USR}:${PASSWD} -XGET "http://${ADDRESS}/${INDEXNAME}/_count" -H 'Content-Type: application/json' -d @count.json | /usr/local/bin/jq -r ".count"`

# 出力説明
printDescription

# データ取得処理
NOW_TIME=${START_TIME}

## 時刻を秒に変換する
NOW_TIME_SECOND=`date -d "${NOW_TIME}" '+%s'`

## クエリ実行回数
QUERY_EXE_NUM=`expr \( ${END_TIME_SECOND} - ${NOW_TIME_SECOND} \) / \( ${QUERY_EXE_INTERVAL} \* 60 \)`
if [ `expr \( ${END_TIME_SECOND} - ${NOW_TIME_SECOND} \) % \( ${QUERY_EXE_INTERVAL} \* 60 \)` -ne 0 ];then
    QUERY_EXE_NUM=`expr ${QUERY_EXE_NUM} + 1`
fi

## クエリ実行用日時
DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${START_TIME} ${QUERY_EXE_INTERVAL} minutes"`

## 処理カウンタ
CNT=0

echo -n "-- 対象データを取得しています... 進捗状況：${QUERY_EXE_NUM} / ["

while [ ${NOW_TIME_SECOND} -lt ${END_TIME_SECOND} ]
do

  # クエリのDATE_TOが終了条件を超えていたら、終了条件の時間までを取得する
  if [ `date -d "${DATE_TO}" '+%s'` -gt ${END_TIME_SECOND} ]; then
      DATE_TO=${END_TIME}
  fi
  
  # 件数取得
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

    # データ取得(多重で非同期実行)
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

      # 説明)：出力外項目は以下
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

    # 非同期実行終了
    done

    # 出力状況確認
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
  
  # 進捗状況
  CNT=`expr ${CNT} + 1`
  if [ `expr ${CNT} % 10` -eq 0 ]; then
      echo -n "+"
  else
      echo -n "*"
  fi

# 全処理終了
done
echo "]"

echo "--------------------------------------------"
echo "== データ出力処理終了: "`date +"%Y/%m/%d %H:%M:%S"`" ==" | tee -a ${LOG_FILE}

##############
# 後処理
##############
if [ ${COMPRESS_FLG} = "ON" ];then
  echo "== 出力ファイル圧縮処理開始: "`date +"%Y/%m/%d %H:%M:%S"`" =="
  zip -jqm ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}.zip ${OUTPUT_DIR}/OUTPUT_${FILE_START}-${FILE_END}*.csv
  echo "== 出力ファイル圧縮処理終了: "`date +"%Y/%m/%d %H:%M:%S"`" =="
fi

# 一時ファイル削除
\rm ./count.json 

if [ "$(find . -maxdepth 1 -name "search_*.json")" != '' ]; then
  \rm ./search_*.json
fi

exit 0

