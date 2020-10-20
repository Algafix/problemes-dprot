#!/bin/bash

writehex  ()
{
    local i
    while [ "$1" ]; do
        for ((i=0; i<${#1}; i+=2))
        do
            printf "\x${1:i:2}";
        done;
        shift;
    done
}


# Hash of the document (leaf)
doc_k=$1
IFS=":";
read -r name alg doc_pre node_pre n max_i root < $2;

read -r doc_content < docs/doc${doc_k}.dat
hash=$(echo -n -e "\x${doc_pre}${doc_content}" | openssl dgst -sha1 -binary | xxd -p)

j=$1
i=0

{
read
while IFS=":"; read v_i v_j node_hash;
do
    if [ $((j%2)) -eq 0 ]
    then
        hash=$(writehex ${node_pre}${hash}${node_hash} | openssl dgst -sha1 -binary | xxd -p)
    else
        hash=$(writehex ${node_pre}${node_hash}${hash} | openssl dgst -sha1 -binary | xxd -p)
    fi
    j=$(($j/2))
    i=$(($i+1))
done;
} < $2

if [ $hash == $root ]
then
    echo "Document $doc_k verified!"
else
    echo "Not verified"
fi


