#!/usr/bin/env bash

set -x

# https://gist.github.com/stokito/f2d7ea0b300f14638a9063559384ec89/
# Decode a JWT from stdin and verify it's signature with the JWT issuer public key
# Only RS256 keys are supported for signature check
#
# HOW TO USE:
# $ export JWTTOKEN="eyF...<your token here>...g"
# $ ./jwt-decode.sh https://example.com/keys "${JWTTOKEN}"
# if signature check failed then error code will be non-zero

URL=$1

JWT=$2

if [ -z "$(command -v jq)" ]; then
  echo "This script will NOT work on your machine."
  echo "Please install jq first: https://stedolan.github.io/jq/download/"
  exit 1
fi

base64_padding() {
  local len=$(( ${#1} % 4 ))
  local padded_b64=''
  if [ ${len} = 2 ]; then
    padded_b64="${1}=="
  elif [ ${len} = 3 ]; then
    padded_b64="${1}="
  else
    padded_b64="${1}"
  fi
  echo -n "$padded_b64"
}

base64url_to_b64() {
  base64_padding "${1}" | tr -- '-_' '+/'
}

b2hex() { echo -n "$1"==== | fold -w 4 | sed '$ d' | tr -d '\n' |base64 -d | xxd -p | tr -d \\n; }

mint_rsa_key() {
  JWK=$1

  # Extract the modulus and exponent from the JWK, converting from URL-safe Base64 to standard Base64
  MODULUS=$(echo "$JWK" | jq -r '.n' | tr '_-' '/+')
  EXPONENT=$(echo "$JWK" | jq -r '.e' | tr '_-' '/+')

  modulus=$(b2hex "$MODULUS")
  exponent=$(b2hex "$EXPONENT")

  asnconf=$(mktemp)

  asnconf="asn1=SEQUENCE:pubkeyinfo\n[pubkeyinfo]\nalgorithm=SEQUENCE:rsa_alg\npubkey=BITWRAP,SEQUENCE:rsapubkey\n[rsa_alg]\nalgorithm=OID:rsaEncryption\nparameter=NULL\n[rsapubkey]\nn=INTEGER:0x$modulus\ne=INTEGER:0x$exponent"

  derfile=$(mktemp)
  echo >&2 "derfile: $derfile"
  echo -e "$asnconf" | openssl asn1parse -genconf /dev/stdin -noout -out "$derfile"

  openssl rsa -in "$derfile" -inform DER -pubin
}

# read the JWT from stdin and split by comma into three variables
IFS='.' read -r JWT_HEADER_B64URL JWT_PAYLOAD_B64URL JWT_SIGNATURE_B64URL <<< "${JWT}"

JWT_HEADER_B64=$(base64url_to_b64 "${JWT_HEADER_B64URL}")
JWT_PAYLOAD_B64=$(base64url_to_b64 "${JWT_PAYLOAD_B64URL}")
JWT_SIGNATURE_B64=$(base64url_to_b64 "${JWT_SIGNATURE_B64URL}")

JWT_HEADER=$(echo "${JWT_HEADER_B64}" | base64 -d)
JWT_PAYLOAD=$(echo "${JWT_PAYLOAD_B64}" | base64 -d)

echo "JWT Header:"
echo "${JWT_HEADER}" | jq
echo "JWT Payload:"
echo "${JWT_PAYLOAD}" | jq
echo "JWT Signature (Base 64 padded):"
echo "${JWT_SIGNATURE_B64}"

JWT_ALG=$(echo "$JWT_HEADER" | jq -r .alg)
JWT_KID=$(echo "$JWT_HEADER" | jq -r .kid)
#JWT_TYP=$(echo "$JWT_HEADER" | jq -r .typ)
#JWT_ISS=$(echo "$JWT_PAYLOAD" | jq -r .iss)
JWT_SUB=$(echo "$JWT_PAYLOAD" | jq -r .sub)
JWT_EMAIL=$(echo "$JWT_PAYLOAD" | jq -r .email)
JWT_IAT=$(echo "$JWT_PAYLOAD" | jq -r .iat)
echo "alg: $JWT_ALG kid: $JWT_KID"
echo "sub: $JWT_SUB email: $JWT_EMAIL iat: $JWT_IAT"

echo "URL: ${URL}"
JWK_SET=$(curl -k -s "${URL}")
echo >&2 "JWK_SET: $JWK_SET"
JWK=$(echo "$JWK_SET" | jq -c -r --arg KID "$JWT_KID" '.keys[] | select(.kid==$KID)')
echo >&2 "JWK: $JWK"

PUB_KEY_FILE=$(mktemp)
mint_rsa_key "$JWK" > "$PUB_KEY_FILE"

# verify signature
if [ "${JWT_ALG}" = "RS256" ]; then
  #SIG_FILE="/tmp/$JWT_SUB-$JWT_IAT.sig.dat"
  SIG_FILE=$(mktemp)
  echo -n "$JWT_SIGNATURE_B64" | base64 -d > "${SIG_FILE}"
  JWT_BODY=$(echo -n "$JWT_HEADER_B64URL.$JWT_PAYLOAD_B64URL")
  echo -n "$JWT_BODY" | openssl dgst -sha256 -verify "${PUB_KEY_FILE}" -signature "${SIG_FILE}"
  JWT_SIG_VERIFIED=$?
  rm "${SIG_FILE}"
  if [ ${JWT_SIG_VERIFIED} -ne 0 ]; then
    >&2 echo "Bad Signature"
    exit ${JWT_SIG_VERIFIED};
  fi
else
  >&2 echo "Error 3: Unsupported signature algorithm $JWT_ALG"
  exit 3
fi
