#!/bin/bash

my_keys=$1
peer_keys=$2
cipherFile=$3

# Parse file
sed -n '/^-----BEGIN PUBLIC KEY-----/,/^-----END PUBLIC KEY-----/p' $cipherFile > d_${peer_keys}_pubkey.pem
sed '/^-----BEGIN AES-128-CBC IV-----/,/^-----END AES-128-CBC IV-----/{//!b};d' $cipherFile | openssl enc -d -a > d_iv.bin
sed '/^-----BEGIN AES-128-CBC CIPHERTEXT-----/,/^-----END AES-128-CBC CIPHERTEXT-----/{//!b};d' $cipherFile | openssl enc -d -a > d_ciphertext.bin
sed '/^-----BEGIN SHA256-HMAC TAG-----/,/^-----END SHA256-HMAC TAG-----/{//!b};d' $cipherFile | openssl enc -d -a > d_tag.bin

# Generate common secret
openssl pkeyutl -inkey ${my_keys}_pkey.pem -peerkey d_${peer_keys}_pubkey.pem -derive -out d_common.bin
cat d_common.bin | openssl dgst -sha256 -binary > d_commonkey.bin
head -c 16 d_commonkey.bin > d_k1.bin
tail -c 16 d_commonkey.bin > d_k2.bin

# Authenticate and decrypt
cat d_iv.bin d_ciphertext.bin | openssl dgst -sha256 -binary -mac hmac -macopt hexkey:`cat d_k2.bin | xxd -p` -out recomputed_tag.bin

STATUS="$(cmp --silent d_tag.bin recomputed_tag.bin; echo $?)"
if [[ $STATUS -ne 0 ]]
then
    echo "Diferent Tag! Not authenticated."
else
    echo "Same Tag."
    openssl enc -d -aes-128-cbc -K `cat d_k1.bin | xxd -p` -iv `cat d_iv.bin | xxd -p` -in d_ciphertext.bin -out decrypted.txt
    echo "Decrypted text in decrypted.txt"
fi
