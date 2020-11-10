#!/bin/bash

my_keys=$1
peer_keys=$2

# Generae common secret
openssl pkeyutl -inkey ${my_keys}_pkey.pem -peerkey ${peer_keys}_pubkey.pem -derive -out common.bin
cat common.bin | openssl dgst -sha256 -binary > commonkey.bin
head -c 16 commonkey.bin > k1.bin
tail -c 16 commonkey.bin > k2.bin

# Encryption & Authentication

openssl rand 16 > iv.bin
openssl enc -aes-128-cbc -K `cat k1.bin | xxd -p` -iv `cat iv.bin | xxd -p` -in secret.txt -out ciphertext.bin
cat iv.bin ciphertext.bin | openssl dgst -sha256 -binary -mac hmac -macopt hexkey:`cat k2.bin | xxd -p` -out tag.bin

# Generate the cipher file

cat ${my_keys}_pubkey.pem > cipher.pem
echo "-----BEGIN AES-128-CBC IV-----" >> cipher.pem 
openssl enc -a -in iv.bin >> cipher.pem
echo "-----END AES-128-CBC IV-----" >> cipher.pem
echo "-----BEGIN AES-128-CBC CIPHERTEXT-----" >> cipher.pem
openssl enc -a -in  ciphertext.bin >> cipher.pem
echo "-----END AES-128-CBC CIPHERTEXT-----" >> cipher.pem
echo "-----BEGIN SHA256-HMAC TAG-----" >> cipher.pem
openssl enc -a -in tag.bin >> cipher.pem
echo "-----END SHA256-HMAC TAG-----" >> cipher.pem