./do.sh ingress_${1} | cut -d "," -f 22 | grep -v ip | tr -d "\"" | uniq > list2
./drem.pl list2 > list3
./search.sh list3 list-${1} | uniq 
