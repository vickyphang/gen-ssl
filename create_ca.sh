#!/bin/bash

# Script to create a Certificate Authority (CA) and use it to sign server certificates
# Usage:
#   1. Create a CA: ./create_ca.sh init
#   2. Generate a server certificate: ./create_ca.sh sign <domain>

CA_DIR="my_ca"
DOMAIN="$2"

fail_if_error() {
  if [ "$1" -ne 0 ]; then
    echo "Error: $2"
    exit 1
  fi
}

if [ "$1" == "init" ]; then
  echo "Initializing the Certificate Authority (CA)..."
  mkdir -p $CA_DIR
  cd $CA_DIR

  echo "Step 1: Generating the CA private key..."
  openssl genpkey -algorithm RSA -out ca.key -pkeyopt rsa_keygen_bits:4096
  fail_if_error $? "Failed to generate CA private key."

  echo "Step 2: Generating the CA certificate..."
  openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=ID/ST=Jakarta/L=Jakarta/O=My Company/OU=IT Dept/CN=My Company/emailAddress=support@domain.com"
  fail_if_error $? "Failed to generate CA certificate."

  echo "CA created successfully! Files:"
  echo "- Private key: $CA_DIR/ca.key"
  echo "- Certificate: $CA_DIR/ca.crt"
  exit 0

elif [ "$1" == "sign" ]; then
  if [ -z "$DOMAIN" ]; then
    echo "Usage: ./create_ca.sh sign <domain>"
    exit 1
  fi

  echo "Generating and signing a certificate for $DOMAIN..."
  mkdir -p $CA_DIR/$DOMAIN
  cd $CA_DIR/$DOMAIN

  echo "Step 1: Generating the private key for $DOMAIN..."
  openssl genpkey -algorithm RSA -out $DOMAIN.key -pkeyopt rsa_keygen_bits:4096
  fail_if_error $? "Failed to generate private key."

  echo "Step 2: Generating the CSR for $DOMAIN..."
  openssl req -new -key $DOMAIN.key -out $DOMAIN.csr -subj "/C=ID/ST=Jakarta/L=Jakarta/O=My Company/OU=IT Dept/CN=$DOMAIN/emailAddress=support@domain.com"
  fail_if_error $? "Failed to generate CSR."

  echo "Step 3: Signing the certificate with the CA..."
  openssl x509 -req -in $DOMAIN.csr -CA ../ca.crt -CAkey ../ca.key -CAcreateserial -out $DOMAIN.crt -days 3650 -sha256
  fail_if_error $? "Failed to sign certificate."

  echo "Certificate created for $DOMAIN! Files:"
  echo "- Private key: $CA_DIR/$DOMAIN/$DOMAIN.key"
  echo "- Certificate: $CA_DIR/$DOMAIN/$DOMAIN.crt"
  echo "- CSR: $CA_DIR/$DOMAIN/$DOMAIN.csr"
  exit 0

else
  echo "Usage:"
  echo "  1. Create a CA: ./create_ca.sh init"
  echo "  2. Generate a server certificate: ./create_ca.sh sign <domain>"
  exit 1
fi
