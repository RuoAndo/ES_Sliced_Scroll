./build.sh reduce_by_key
./build-traverse.sh reduce_by_key_gpu

i=0
j=100000000
while [ $i -ne 6 ]
do
    echo "-CPU: "$j"-"
    ./reduce_by_key $j
    echo "-GPU: "$j"-"
    ./reduce_by_key_gpu $j
    j=`expr 100000000 + $j`
    i=`expr 1 + $i`
done
