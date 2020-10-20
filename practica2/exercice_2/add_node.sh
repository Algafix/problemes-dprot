#!/bin/bash


IFS=":";
read -r name alg doc_pre node_pre n max_i root < merkle_tree.txt

i=0
cat docs/doc.pre docs/doc$n.dat | openssl dgst -sha1 -binary > nodes/node$i.$n
sed -i "/^$i:$(($n-1)):/a $i:$n:$(cat nodes/node$i.$n | xxd -p)" merkle_tree.txt

j=$n

while [ $j -gt 0 ]
do

i=$(($i+1))
odd=$(($j%2))
j=$(($j/2))

if [ $odd -eq 1 ]
then
cat nodes/node.pre nodes/node$(($i-1)).$((2*$j)) nodes/node$(($i-1)).$((2*$j+1)) | openssl dgst -sha1 -binary > nodes/node$i.$j;
else
cat nodes/node.pre nodes/node$(($i-1)).$((2*$j)) | openssl dgst -sha1 -binary > nodes/node$i.$j;
fi;
sed -i "s/^$i:$j:.*/$i:$j:$(cat nodes/node$i.$j | xxd -p)/g" merkle_tree.txt
done;

sed -i "s/^$name.*/$name:$alg:$doc_pre:$node_pre:$(($n+1)):$(($i+1)):$(cat nodes/node$i.$j | xxd -p)/g" merkle_tree.txt
