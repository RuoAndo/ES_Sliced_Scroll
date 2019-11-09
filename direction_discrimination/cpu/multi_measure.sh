date=$(date -d '1 day ago' "+%Y%m%d")
echo $date
REGION_NAME="ap-southeast-1"

./build.sh multi_measure

echo "copying..."
time cp -r /root/${date} .
time ./multi_measure $date list-${REGION_NAME}

mkdir ${date}_ingress_${REGION_NAME}
mv ./$date/*ingress ${date}_ingress_${REGION_NAME}

mkdir ${date}_egress_${REGION_NAME}
mv ./$date/*egress ${date}_egress_${REGION_NAME}
