RMDATE=`date --date '3 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
rm -rf $RMDATE

rm -rf egress_sinet
rm -rf ingress_sinet

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
