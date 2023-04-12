#!/usr/bin/env bash

while getopts c:s:e:a: flag
do
    case "${flag}" in
        c) client=${OPTARG};;
        s) subject=${OPTARG};;
        e) expiration=${OPTARG};;
        a) addext=${OPTARG};;
        *) printf "Usage: %s [-s] [-e] [-a]\n""$0" >&2
               exit 1 ;;
    esac
done

set -e

ca_cert="ca.crt"
ca_key="ca.key"

echo "Client: $client";
echo "Subject: $subject";
echo "Expiration: $expiration";
echo "AddExt: $addext";

openssl genrsa -out "$client.key" 2048

openssl req \
	-new \
  -subj "$subject" \
  -addext "$addext" \
	-key "$client.key" \
	-out "$client.csr"

# Create a config file for the extensions
cat > "$client.ext" <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
$addext
EOF

openssl x509 -req \
    -in "$client.csr" \
    -extfile "$client.ext" \
    -CA "$ca_cert" \
    -CAkey "$ca_key" \
    -out "$client.crt" \
	  -days "$expiration" \
    -sha256

rm "$client.csr"
rm "$client.ext"

chmod 644 "$client.crt"
chmod 644 "$client.key"