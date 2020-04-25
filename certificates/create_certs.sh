#!/bin/bash

readonly ca_name="EC2CA"
readonly domain_name="local.app"
declare -i days=365
declare -i key_length=2048
declare -a server_names=(
  "flask"
  "backend-1"
  "backend-2"
)
# Generate own CA
if [[ ! -f "./${ca_name}.pem" ]]; then
  openssl genrsa -des3 -out "${ca_name}.key" $key_length
  # openssl genrsa -des3 -nodes -out "${ca_name}.key" $key_length
  openssl req -x509 -new -key "${ca_name}.key" -subj "/C=ZZ/ST=ST/L=L/O=O/OU=OU/CN=EC2 Testing Root CA" -sha256 -days $days -out "${ca_name}.pem"
fi
# Create certificate keys and CSRs
for server_name in "${server_names[@]}"; do
  openssl genrsa -out "${server_name}.${domain_name}.key" $key_length
  openssl req -new -key "${server_name}.${domain_name}.key" -subj "/C=ZZ/ST=ST/L=L/O=O/OU=OU/CN=${server_name}.${domain_name}" -out "${server_name}.${domain_name}.csr"
done
# Create certificates using CSRs and CA key
for server_name in "${server_names[@]}"; do
  openssl x509 -req -in "${server_name}.${domain_name}.csr" -CA "${ca_name}.pem" -CAkey "${ca_name}.key" -CAcreateserial -out "${server_name}.${domain_name}.crt" -days $days -sha256
  cat "${server_name}.${domain_name}.crt" "${server_name}.${domain_name}.key" > "${server_name}.${domain_name}.pem"
done

# sudo cp EC2CA.pem /usr/local/share/ca-certificates/EC2CA.crt && sudo update-ca-certificates
