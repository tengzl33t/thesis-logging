#!/usr/bin/env bash

# Generates your own Certificate Authority for development.
# This script should be executed just once.

while getopts s:e:a: flag
do
    case "${flag}" in
        s) subject=${OPTARG};;
        e) expiration=${OPTARG};;
        a) addext=${OPTARG};;
        *) echo "Usage: $0 [-s] [-e] [-a]" >&2
               exit 1 ;;
    esac
done

set -e

ca_cert="ca.crt"
ca_key="ca.key"

echo "Subject: $subject";
echo "Expiration: $expiration";
echo "AddExt: $addext";

# Generate private key
openssl genrsa -out $ca_key 2048

echo "Generating root certificate..."
echo "Subject: ${subject}"
echo "Expiration: ${expiration} days"

# Generate root certificate
openssl req \
	-x509 \
	-new \
	-nodes \
	-subj "$subject" \
	-addext "$addext" \
	-key $ca_key \
	-sha256 \
	-days "$expiration" \
	-out $ca_cert

chmod 644 ca_key

echo -e "Success!"
echo "The following files have been written:"
echo -e "  - $ca_cert"
echo -e "  -  $ca_key"
