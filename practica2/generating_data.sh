#!/bin/bash

# AES key file generation
openssl rand -out key.dat 16
hexdump -e '"%2.2x"' key.dat > hexkey.dat

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







