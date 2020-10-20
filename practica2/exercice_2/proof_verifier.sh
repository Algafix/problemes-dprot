#!/bin/bash

doc_k=$1

IFS=":";
read -r name alg doc_pre node_pre n max_i root < $2;

read -r doc_content < docs/doc${doc_k}.dat
hash=$(echo -n -e "\x${doc_pre}${doc_content}" | openssl dgst -sha1 -binary | xxd -p)

j=$1
i=0
max_j=$n

{
read
while IFS=":"; read v_i v_j node_hash;
do
    if [ $((j%2)) -eq 0 ]
    then
        if [ $(($j+1)) -lt $max_j ]
        then
            hash=$(echo -n $(echo -n -e "\x${node_pre}")$(echo -n "${hash}${node_hash}" | xxd -r -p) | openssl dgst -sha1 -binary | xxd -p)
        else
            hash=$(echo -n $(echo -n -e "\x${node_pre}")$(echo -n "${hash}" | xxd -r -p) | openssl dgst -sha1 -binary | xxd -p)
        fi
    else
        hash=$(echo -n $(echo -n -e "\x${node_pre}")$(echo -n "${node_hash}${hash}" | xxd -r -p) | openssl dgst -sha1 -binary | xxd -p)
    fi

    j=$(($j/2))
    i=$(($i+1))
    max_j=$(($max_j/2+$max_j%2))
done;
} < $2

if [ $hash == $root ]
then
    echo "Document $doc_k verified!"
else
    echo "Not verified"
fi


