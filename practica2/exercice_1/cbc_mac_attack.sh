#!/bin/bash

# AES key file generation
openssl rand -out key.dat 16
echo -n `cat key.dat | xxd -p` > hexkey.dat

m1='What about joining me tomorrow for dinner?'
m2='Oops, Sorry, I just remember that I have a meeting very soon in the morning.'

echo -n $m1 > mess1.dat
echo -n $m2 > mess2.dat

rm head.dat
touch head.dat
for run in {1..16}; do echo -n -e "\x00" >> head.dat; done

cat head.dat mess1.dat > tmp_message1
cat head.dat mess2.dat > tmp_message2
openssl enc -aes-128-cbc -K `cat hexkey.dat` -iv 0 -in tmp_message1 | tail -c 16 > tag1.dat
openssl enc -aes-128-cbc -K `cat hexkey.dat` -iv 0 -in tmp_message2 | tail -c 16 > tag2.dat
rm tmp_*

# Padding: each padding byte has the value of the number of bytes until 128 bits (16 bytes) multiple.

# Attack: head.dat || mess1.dat || padding || tag1.dat xor head.dat|| mess2.dat -> tag2.dat

# Start of the file
cat head.dat mess1.dat > forgery.dat

# Add padding
size_forge=$(wc -c < forgery.dat)
pad_bytes=$((16 - ${size_forge}%16))
pad_hex=$(printf "%02x" $pad_bytes)
for run in $(seq 1 $pad_bytes); do echo -n -e "\x$pad_hex" >> forgery.dat; done

# Add tag1
cat tag1.dat >> forgery.dat

# Add message 2
cat mess2.dat >> forgery.dat

# Compute the CMAC
openssl enc -aes-128-cbc -K `cat hexkey.dat` -iv 0 -in forgery.dat | tail -c 16 > tag2_forged.dat






