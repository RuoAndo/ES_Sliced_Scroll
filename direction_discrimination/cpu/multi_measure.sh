date=$(date -d '5 day ago' "+%Y%m%d")
echo $date

time ./multi_measure $date list-eu-west-1

mkdir ${date}_ingress
mv ./$date/*ingress ${date}_ingress

mkdir ${date}_egress
mv ./$date/*egress ${date}_egress
