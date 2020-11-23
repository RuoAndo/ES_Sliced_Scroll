RMDATE=`date --date '4 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
rm -rf $RMDATE

RMDATE=`date --date '60 day ago' +%Y%m%d`

rm -rf egress_sinet/*_${RMDATE}
rm -rf ingress_sinet/*_${RMDATE}

rm -rf egress_sinet_${RMDATE}
rm -rf ingress_sinet_${RMDATE}


#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
