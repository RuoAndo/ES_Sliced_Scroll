RMDATE=`date --date '5 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
rm -rf $RMDATE

rm -rf egress_sinet
rm -rf ingress_sinet

#sinet_egress_all_20201220

RMDATE=`date --date '3 day ago' +%Y%m%d`
rm -rf sinet_egress_all_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
