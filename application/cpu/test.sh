./build.sh cpu_reduction

mkdir histo_egress_sinet
mkdir histo_ingress_sinet

date=$(date -d '2 day ago' "+%Y%m%d")
echo $date

./cpu_reduction egress_sinet_${date}
mv tmp-counts ./histo_egress_sinet/${date}

./cpu_reduction ingress_sinet_${date}
mv tmp-counts ./histo_ingress_sinet/${date}

