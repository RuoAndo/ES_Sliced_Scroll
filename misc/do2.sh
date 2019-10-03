i=0
j=100000000
while [ $i -ne 6 ]
do
    result=`./$1 $j`
    echo $j","$result
    j=`expr 10000000 + $j`
    i=`expr 1 + $i`
done
