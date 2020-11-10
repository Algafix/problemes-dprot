#!/bin/bash

############## KEY GEN #############

key_gen() {
    openssl genpkey -genparam -algorithm dh -pkeyopt dh_rfc5114:3 -out param.pem

    # Alice
    openssl genpkey -paramfile param.pem -out alice_pkey.pem
    openssl pkey -in alice_pkey.pem -pubout -out alice_pubkey.pem
}

############# Encrypt B -> A #################

encrypt() {
    # Generate keys
    openssl genpkey -paramfile param.pem -out ephpkey.pem
    openssl pkey -in ephpkey.pem -pubout -out ephpubkey.pem

    # Generae common secret
    openssl pkeyutl -inkey ephpkey.pem -peerkey alice_pubkey.pem -derive -out common.bin
    cat common.bin | openssl dgst -sha256 -binary > commonkey.bin
    head -c 16 commonkey.bin > k1.bin
    tail -c 16 commonkey.bin > k2.bin

    # Encryption & Authentication

    openssl rand 16 > iv.bin
    openssl enc -aes-128-cbc -K `cat k1.bin | xxd -p` -iv `cat iv.bin | xxd -p` -in secret.txt -out ciphertext.bin
    cat iv.bin ciphertext.bin | openssl dgst -sha256 -binary -mac hmac -macopt hexkey:`cat k2.bin | xxd -p` -out tag.bin

    # Generate the cipher file

    cat ephpubkey.pem > cipher.pem
    echo "-----BEGIN AES-128-CBC IV-----" >> cipher.pem 
    openssl enc -a -in iv.bin >> cipher.pem
    echo "-----END AES-128-CBC IV-----" >> cipher.pem
    echo "-----BEGIN AES-128-CBC CIPHERTEXT-----" >> cipher.pem
    openssl enc -a -in  ciphertext.bin >> cipher.pem
    echo "-----END AES-128-CBC CIPHERTEXT-----" >> cipher.pem
    echo "-----BEGIN SHA256-HMAC TAG-----" >> cipher.pem
    openssl enc -a -in tag.bin >> cipher.pem
    echo "-----END SHA256-HMAC TAG-----" >> cipher.pem
}

############### Decrypt A ##################

decrypt() {
    # Parse file
    sed -n '/^-----BEGIN PUBLIC KEY-----/,/^-----END PUBLIC KEY-----/p' cipher.pem > d_ephpubkey.pem
    sed '/^-----BEGIN AES-128-CBC IV-----/,/^-----END AES-128-CBC IV-----/{//!b};d' cipher.pem | openssl enc -d -a > d_iv.bin
    sed '/^-----BEGIN AES-128-CBC CIPHERTEXT-----/,/^-----END AES-128-CBC CIPHERTEXT-----/{//!b};d' cipher.pem | openssl enc -d -a > d_ciphertext.bin
    sed '/^-----BEGIN SHA256-HMAC TAG-----/,/^-----END SHA256-HMAC TAG-----/{//!b};d' cipher.pem | openssl enc -d -a > d_tag.bin

    # Generate common secret
    openssl pkeyutl -inkey alice_pkey.pem -peerkey d_ephpubkey.pem -derive -out d_common.bin
    cat d_common.bin | openssl dgst -sha256 -binary > d_commonkey.bin
    head -c 16 d_commonkey.bin > d_k1.bin
    tail -c 16 d_commonkey.bin > d_k2.bin

    # Authenticate and decrypt
    cat d_iv.bin d_ciphertext.bin | openssl dgst -sha256 -binary -mac hmac -macopt hexkey:`cat d_k2.bin | xxd -p` -out d_tag.bin
    openssl enc -d -aes-128-cbc -K `cat d_k1.bin | xxd -p` -iv `cat d_iv.bin | xxd -p` -in d_ciphertext.bin -out decrypted.txt
}


case $1 in
    keys)
    echo "Generating Keys"
    key_gen
    ;;
    encrypt)
    echo "Encrypting from B to A"
    encrypt
    ;;
    decrypt)
    echo "Decrypting from B to A"
    decrypt
    ;;
    *)
    echo "Unknown action"
    ;;
esac
