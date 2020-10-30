ls -alh $1 | grep -v 604 | grep shanghai | sed 's/[\t ]\+/\t/g' | cut -f 9 | uniq > list 

while read line; do
    cat ${1}/${line}
done < list
