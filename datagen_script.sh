#!/bin/bash


subkey='000102030405060708090a0b0c'
constant_m0='aa'

# Primera generació de iv 01FF00 a 01FFFF

iv_base='01ff'

for iv in {0..4};
do
    iv_hex=$(printf "%02x" $iv)
    key="$iv_base$iv_hex$subkey"
    echo "$key"
    echo -n $constant_m0 | openssl enc -K $key -rc4 | xxd
done

# TODO: canviar els rangs
# TODO: eliminar el xxd
# TODO: guardar en un fitxer iv i text xifrat


# Old interest
# iv_hex=$(printf "%06x" $iv) (padding with 6 0s maximum)