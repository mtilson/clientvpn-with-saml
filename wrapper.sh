#!/usr/bin/env bash

set -e

wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout
  until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do sleep 1; done
  ((++wait_seconds))
}

OVPN_CONF=${OVPN_CONF:-./ovpn.conf}
OVPN_OUT=$(openvpn --config "${OVPN_CONF}" --auth-user-pass <( printf "%s\n%s\n" "N/A" "ACS::35001" ) 2>&1 | grep AUTH_FAILED,CRV1)
echo $OVPN_OUT
echo "==="

URL=$(echo "$OVPN_OUT" | grep -Eo 'https://.+')
echo "URL: $URL"
echo "==="

VPN_SID=$(echo "$OVPN_OUT" | awk -F : '{print $7}')
echo "VPN_SID: $VPN_SID"
echo "==="

# Delete stale saml-response.txt if exists
rm -f saml-response.txt

echo "Opening browser and wait for the response file..."
wait_file "saml-response.txt" 300 || {
  echo "SAML Authentication time out"
  exit 1
}

echo "Running OpenVPN with sudo. Enter password if requested"
sudo bash -c "openvpn --config "${OVPN_CONF}" --inactive 3600 \
    --script-security 2 --route-up '/usr/bin/env rm saml-response.txt' \
    --auth-user-pass <( printf \"%s\n%s\n\" \"N/A\" \"CRV1::${VPN_SID}::$(cat saml-response.txt)\" )"
