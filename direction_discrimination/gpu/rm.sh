RMDATE=`date --date '3 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
fm -rf echo $RMDATE

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
