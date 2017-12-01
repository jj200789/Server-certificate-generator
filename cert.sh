if [ -z "$1" ]
then
  echo "Help: cert.sh [IP address]";
  exit;
fi

# Create v3.ext
cat > /tmp/__v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = IP:$1
EOF

openssl genrsa -out CA.key 2048
openssl req -x509 -new -nodes -key CA.key -sha256 -days 365 -out CA.pem

# Create a new private key if one doesnt exist, or use the existing one if it does
if [ -f server.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

DOMAIN=$1
SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=$1"
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT server.key -subj "$SUBJECT" -out server.csr
openssl x509 -req -in server.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out server.crt -days 365 -sha256 -extfile /tmp/__v3.ext 

rm -f /tmp/__v3.ext

echo 
echo "###########################################################################"
echo "Done!" 
echo "###########################################################################"
echo 
echo "SSLCertificateFile    /path_to_your_files/server.crt"
echo "SSLCertificateKeyFile /path_to_your_files/server.key"