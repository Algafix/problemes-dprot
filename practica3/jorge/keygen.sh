#!/bin/bash

openssl genpkey -genparam -algorithm dh -pkeyopt dh_rfc5114:3 -out param.pem

# Name of the public keys
openssl genpkey -paramfile param.pem -out $1_pkey.pem
openssl pkey -in $1_pkey.pem -pubout -out $1_pubkey.pem
