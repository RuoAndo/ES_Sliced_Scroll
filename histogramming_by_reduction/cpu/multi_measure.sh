date=$(date -d '2 day ago' "+%Y%m%d")
echo $date
REGION_NAME="sinet"

#/mnt/data/Usenix_LISA19/direction_discrimination/cpu/20191108_egress_sinet

mkdir egress_reduced
mkdir ingress_reduced

./build.sh multi_measure
echo "copying..."
cp -r /mnt/data/Usenix_LISA19/direction_discrimination/cpu/sinet_ingress_${date} .

./multi_measure ./sinet_ingress_${date}

echo "timestamp, count" > tmp
cat tmp-counts >> tmp
cp tmp egress_reduced/${date}_egress_sinet

./build.sh multi_measure
echo "copying..."
cp -r /mnt/data/Usenix_LISA19/direction_discrimination/cpu/sinet_egress_${date} .

./multi_measure ./sinet_egress_${date} .

echo "timestamp, count" > tmp
cat tmp-counts >> tmp
cp tmp ingress_reduced/${date}_ingress_sinet 

#rm -rf ${date}
