date=$(date -d '3 day ago' "+%Y%m%d")
echo $date
REGION_NAME=$1

./build-reduction.sh multi13
./multi13 ./ingress_${REGION_NAME}_${date}
cp tmp_counts ./ingress_${REGION_NAME}/${date}


