#!/bin/bash


subkey='000102030405060708090a0b0c'
constant_m0='a'

# Primera generació de iv 01FF00 a 01FFFF

iv_base='01ff'
echo "IV,Ciphertext" > data_m0.txt

for iv in {0..255};
do
    iv_hex=$(printf "%02x" $iv)
    key="$iv_base$iv_hex$subkey"
    #echo "$key"
    echo -n $iv_base$iv_hex"," >> data_m0.txt
    echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd -p >> data_m0.txt
done


iv_base='03ff'
echo "IV,Ciphertext" > data_k0.txt

for iv in {0..255};
do
    iv_hex=$(printf "%02x" $iv)
    key="$iv_base$iv_hex$subkey"
    #echo "$key"
    echo -n $iv_base$iv_hex"," >> data_k0.txt
    echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd -p >> data_k0.txt
done

iv_base='04ff'
echo "IV,Ciphertext" > data_k1.txt

for iv in {0..255};
do
    iv_hex=$(printf "%02x" $iv)
    key="$iv_base$iv_hex$subkey"
    #echo "$key"
    echo -n $iv_base$iv_hex"," >> data_k1.txt
    echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd -p >> data_k1.txt
done


# Old interest
# iv_hex=$(printf "%06x" $iv) (padding with 6 0s maximum)