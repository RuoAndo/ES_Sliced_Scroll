while read line; do
    #echo $line
    result=`sed -n ${line}P blacklist.txt`
    echo $result",32"
done < $1
