if [ "$1" = "" ]
then
    echo "usage: ./10 nLines nFiles"
    exit 1
fi

./build.sh 10

nLines=$1
nFiles=$2

rm -rf random_data-all
touch random_data-all

for i in `seq 1 $nFiles`
do
    echo "$i 回目のループです。"
    time ./10 $nLines
    num=`expr $nLines \* $nFiles`
    cat random_data.txt >> random_data-all
done

wc -l random_data-all
