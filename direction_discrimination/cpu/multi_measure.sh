date=$(date -d '1 day ago' "+%Y%m%d")
echo $date
REGION_NAME="eu-west-1"

./build.sh multi_measure

echo "copying..."
time cp -r /data1/${date} .
time ./multi_measure $date list-${REGION_NAME}


ls ./${date}/*ingress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cp ${fn_src} ./ingress/${REGION_NAME}_${fn_dst}_${date}
done < list

ls ./${date}/*egress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cp ${fn_src} ./egress/${REGION_NAME}_${fn_dst}_${date}
done < list

