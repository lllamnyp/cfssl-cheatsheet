#!/bin/bash

export NAMES_CN=${NAMES_CN:-company.ru}
export NAMES_C=${NAMES_C:-RU}
export NAMES_L=${NAMES_L:-Moscow}
export NAMES_O=${NAMES_O:-Company}
export NAMES_OU=${NAMES_OU:-WWW}
export NAMES_ST=${NAMES_ST:-Moscow}
export EXPIRY=${EXPIRY:-8760h}
export wildcard=${wildcard:-true}

if $wildcard
then
	export hosts="\"$1\",\"*.$1\""
else
	export hosts="\"$1\""
fi

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

chmod a+x cfssl cfssljson || true

cat <<EOF > cfssl-cfg.json
{
  "signing": {
    "default": {
      "expiry": "${EXPIRY}",
      "usages": ["signing", "key encipherment", "server auth"]
    }
  }
}
EOF

cat <<EOF > csr.json
{
    "CN": "${NAMES_CN}",
    "hosts": [$hosts],
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "names": [
        {
            "C": "${NAMES_C}",
            "L": "${NAMES_L}",
            "O": "${NAMES_O}",
            "OU": "${NAMES_OU}",
            "ST": "${NAMES_ST}"
        }
    ]
}
EOF

${cfssl_binary} genkey -config cfssl-cfg.json csr.json | ${cfssljson_binary} -bare $1

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
