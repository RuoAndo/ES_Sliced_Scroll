date=$(date -d '3 day ago' "+%Y%m%d")
echo $date

du -h egress_sinet_${date}

cd egress_sinet_${date}

echo "cat..."
time cat sinet* > sinet_egress_all_${date}
mv sinet_egress_all_${date} ../

cd ..
ls -alh sinet_egress_all_${date}

scp sinet_egress_all_${date} 192.168.76.216:/mnt/data/hadoop/
