#!/bin/sh
openssl pkcs7 -inform PEM -outform PEM -in $1 -print_certs > $2
