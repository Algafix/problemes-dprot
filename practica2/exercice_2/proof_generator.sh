#!/bin/bash

IFS=":";
read -r name alg doc_pre node_pre n max_i root < merkle_tree.txt;

doc_k=$1
j=$1
i=0
max_j=$n

echo "$name:$alg:$doc_pre:$node_pre:$n:$max_i:$root" > proof_doc$doc_k.txt

while [ $i -lt $max_i ]
do
    if [ $((j%2)) -eq 0 ]
    then
        if [ $(($j+1)) -lt $max_j ]
        then
            echo "$i:$(($j+1)):$(cat nodes/node$i.$(($j+1)) | xxd -p)" >> proof_doc$doc_k.txt
        fi
    else
        echo "$i:$(($j-1)):$(cat nodes/node$i.$(($j-1)) | xxd -p)" >> proof_doc$doc_k.txt
    fi

    j=$(($j/2))
    i=$(($i+1))
    max_j=$(($max_j/2+$max_j%2))
done;


