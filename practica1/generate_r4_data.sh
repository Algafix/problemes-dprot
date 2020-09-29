#!/bin/bash


subkey='000102030405060708090a0b0c'
constant_m0='a'
echo "IV,Ciphertext" > data_m0.txt

# Primera generació de iv 01FF00 a 01FFFF

iv_base='01ff'

for iv in {0..255};
do
    iv_hex=$(printf "%02x" $iv)
    key="$iv_base$iv_hex$subkey"
    #echo "$key"
    echo -n $iv_base$iv_hex"," >> data_m0.txt
    echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd -p >> data_m0.txt
done


echo "IV,Ciphertext" > data_k.txt

for f_iv in {3..16};
do
    f_iv_hex=$(printf "%02x" $f_iv)
    for l_iv in {0..255};
    do
        l_iv_hex=$(printf "%02x" $l_iv)
        key="$f_iv_hex"ff"$l_iv_hex$subkey"
        echo -n $f_iv_hex"ff"$l_iv_hex"," >> data_k.txt
        echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd -p >> data_k.txt
    done
done


# Old interest
# iv_hex=$(printf "%06x" $iv) (padding with 6 0s maximum)