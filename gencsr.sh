#!/bin/bash

export NAMES_C=${NAMES_C:-RU}
export NAMES_L=${NAMES_L:-Moscow}
export NAMES_O=${NAMES_O:-Company}
export EXPIRY=${EXPIRY:-8760h}

if which cfssl
then 
	export cfssl_binary=$(which cfssl)
else
	if ! stat cfssl
	then 
		wget https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 -O cfssl
		export cfssl_binary=./cfssl
	fi
fi

if which cfssljson
then 
	export cfssljson_binary=$(which cfssljson)
else
	if ! stat cfssljson
	then 
		wget https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64 -O cfssljson
		export cfssljson_binary=./cfssljson
	fi
fi

chmod a+x cfssl cfssljson

cat <<EOF > cfssl-cfg.json
{
  "signing": {
    "default": {
      "expiry": "${EXPIRY}",
      "usages": ["signing", "key encipherment", "server auth"],
    }
  }
}
EOF

cat <<EOF > csr.json
{
    "hosts": [
        "$1",
        "*.$1"
    ],
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "names": [
        {
            "C": "${NAMES_C}",
            "L": "${NAMES_L}",
            "O": "${NAMES_O}"
        }
    ]
}
EOF

${cfssl_binary} genkey csr.json | ${cfssljson_binary} -bare $1

echo
echo Certificate signing requested generated
echo
echo When requesting cert on AD cert services pass the following string for additional attributes:
echo 
echo "'san:dns=$1&dns=*.$1´"
echo
echo After generating certs, decode them with ./decode.sh. Example usage:
echo
echo ./decode.sh certnew.p7b subdomain.company.com-chain.pem
