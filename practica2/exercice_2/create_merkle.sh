#!/bin/bash

n=$1
max_j=$1
i=0
doc_prepend="\x00"
node_prepend="\x01"

rm nodes/*
echo -n -e $doc_prepend > docs/doc.pre
echo -n -e $node_prepend > nodes/node.pre
echo -n "" > merkle_tree.txt

# Generate leaf nodes from the documents
for j in $(seq 0 $(($max_j-1)));
do 
    cat docs/doc.pre docs/doc$j.dat | openssl dgst -sha1 -binary > nodes/node$i.$j;
    echo $i:$j:$(cat nodes/node$i.$j | xxd -p) >> merkle_tree.txt
done;

# Iterate over the tree levels
# Each level has half (ceiled) the nodes of the previous one
while [ $(($max_j/2)) -gt 0 ]
do
i=$(($i+1))
odd=$(($max_j%2))
max_j=$(($max_j/2 + $odd))

for j in $(seq 0 $(($max_j-1)));
do
    if [ $j -eq $(($max_j-1)) ] && [ $odd -eq 1 ] # If there is no right node
    then
        cat nodes/node.pre nodes/node$(($i-1)).$((2*$j)) | openssl dgst -sha1 -binary > nodes/node$i.$j;
    else
        cat nodes/node.pre nodes/node$(($i-1)).$((2*$j)) nodes/node$(($i-1)).$((2*$j+1)) | openssl dgst -sha1 -binary > nodes/node$i.$j;
    fi
    echo $i:$j:$(cat nodes/node$i.$j | xxd -p) >> merkle_tree.txt
done;
done;

echo -e "MerkleTree:sha1:${doc_prepend:2}:${node_prepend:2}:$n:$(($i+1)):$(cat nodes/node$i.$j | xxd -p)\n$(cat merkle_tree.txt)" > merkle_tree.txt

## OLD

# j_float=$(echo "l($n)/l(2)" | bc -l)
# j_float=${j_float%?}
# j=$(echo "scale = 0; $j_float/1" | bc -l)

# if echo "$j_float > $j" | bc -l | grep -q 1
# then
#     j=$(($j+1))
# fi

# echo $j

# max_n_f=$(echo "l($n)/l(2)" | bc -l)
# max_n_f=${max_n_f%?}
# max_n=$(echo "scale = 0; $max_n_f/1" | bc -l)

# if echo "$max_n_f > $max_n" | bc -l | grep -q 1
# then
#     max_n=$(($max_n+1))
# fi

# max_n=$((2**$max_n))