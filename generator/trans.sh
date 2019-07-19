
ls OUTPUT* > list

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    ./trans $line $nLines
    cp $line ${line}.bak
    wc -l trans-tmp 
done < list
