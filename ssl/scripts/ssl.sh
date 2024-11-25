#!/bin/bash

DOMAIN=$1
FQDNS=$2

# Check if domain name is provided
if [ -z "$DOMAIN" ]; then
  echo "Error: No domain name argument provided"
  echo "Usage: Provide a domain name as an argument"
  exit 1
fi

# If FQDNs is not provided, set it to the main domain
if [ -z "$FQDNS" ]; then
  FQDNS=$DOMAIN
fi

# Convert FQDNS to an array using comma as a separator
IFS=',' read -ra fqdn_array <<< "$FQDNS"

# Generate the SAN entries for csr.conf
SAN=""
for fqdn in "${fqdn_array[@]}"; do
  SAN+="DNS:$fqdn,"
done
SAN=${SAN%,}  # Remove trailing comma

# Create root CA & Private key
openssl req -x509 \
            -sha256 -days 365 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${DOMAIN}/C=AU/L=Melbourne" \
            -keyout rootCA.key -out rootCA.crt 

# Generate private key
openssl genrsa -out ${DOMAIN}.key 2048

# Create csr.conf with the SANs
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = AU
ST = VIC
L = Melbourne
O = Trace It Solutions Pty Ltd
OU = Technology
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = ${SAN}
EOF

# Create CSR request using the private key and csr.conf
openssl req -new -key ${DOMAIN}.key -out ${DOMAIN}.csr -config csr.conf

# Create cert.conf with dynamic FQDNs
cat > cert.conf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
EOF

# Add each FQDN to cert.conf under alt_names
i=1
for fqdn in "${fqdn_array[@]}"; do
  echo "DNS.${i} = ${fqdn}" >> cert.conf
  ((i=i+1))
done

# Create SSL certificate with self-signed CA
openssl x509 -req \
    -in ${DOMAIN}.csr \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out ${DOMAIN}.crt \
    -days 365 \
    -sha256 -extfile cert.conf
