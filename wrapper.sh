#!/usr/bin/env sh

set -e

wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  echo "Waiting fo file: $file"

  until test $((wait_seconds-=5)) -le 0 -o -f "$file" ; do
    echo ">> $wait_seconds ... sleep 5"
    sleep 5
  done
}

OVPN_CONF=${OVPN_CONF:-./ovpn.conf}
RESP_FILE=${RESP_FILE:-./saml-response.txt}

HOST=$(cat ${OVPN_CONF} | grep ^remote | head -n1 | cut -d" " -f2)
PORT=$(cat ${OVPN_CONF} | grep ^remote | head -n1 | cut -d" " -f3)
PROTO=$(cat ${OVPN_CONF} | grep ^proto | head -n1 | cut -d" " -f2)
RAND=$(openssl rand -hex 12)
SRV=$(dig a +short "${RAND}.${HOST}" | head -n1)

sed \
    -e '/^proto .*/d' \
    -e '/^remote .*/d' \
    -e '/^remote-random-hostname.*/d' \
    -e '/^nobind.*/a persist-key\npersist-tun' \
    ${OVPN_CONF} > ${OVPN_CONF}-${SRV}

OVPN_OUT=$(openvpn --config "${OVPN_CONF}-${SRV}" \
  --proto "$PROTO" --remote "${SRV}" "${PORT}" \
  --auth-user-pass <( printf "%s\n%s\n" "N/A" "ACS::35001" ) 2>&1 | grep AUTH_FAILED,CRV1)
echo $OVPN_OUT
echo "==="

URL=$(echo "$OVPN_OUT" | grep -Eo 'https://.+')
echo "URL: $URL"
echo "==="

VPN_SID=$(echo "$OVPN_OUT" | awk -F : '{print $7}')
echo "VPN_SID: $VPN_SID"
echo "==="

# Delete stale SAML files
rm -f ${RESP_FILE} ${RESP_FILE}.cred

echo "Opening browser and wait for the response file..."
wait_file ${RESP_FILE} 300 || {
  echo "SAML Authentication time out"
  exit 1
}

printf "%s\n%s\n" "N/A" "CRV1::${VPN_SID}::$(cat ${RESP_FILE})" > ${RESP_FILE}.cred
chmod 600 ${RESP_FILE}.cred

echo "Running OpenVPN"
openvpn --config "${OVPN_CONF}-${SRV}" --inactive 3600 \
  --proto "$PROTO" --remote "${SRV}" "${PORT}" \
  --script-security 2 --route-up '/usr/bin/env rm -f ${RESP_FILE} ${RESP_FILE}.cred' \
  --auth-user-pass ${RESP_FILE}.cred
