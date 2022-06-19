## OpenVPN Client to authenticate with SAML 2.0 to AWS Client VPN

### Note ###

* The idea is based on [samm-git/aws-vpn-client](https://github.com/samm-git/aws-vpn-client)

### About ###

* It is [Docker image](https://hub.docker.com/r/mtilson/clientvpn-with-saml/) of [OpenVPN client](https://openvpn.net) with auxiliary services build to be able to connect to [AWS Client VPN](https://aws.amazon.com/vpn/client-vpn/) using SAML 2.0 protocol for authentication and authorization
* Configuration file for *Client VPN endpoint* and *username/password* for SSO authentication are provided to the container as command line parameters (or as environment variables) to pass SAML authentication and authorization in unattended way

### Usage ###

``` bash
user@runner:~/.tmp/openvpn/docker$ docker run \
  -d \
  --rm \
  -p 35001:35001 \
  -e OVPN_CONF=/srv/aws-client-vpn.ovpn \
  -v"$(pwd)/aws-client-vpn.ovpn":"/srv/aws-client-vpn.ovpn" \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --name ovpn-saml \
  mtilson/clientvpn-with-saml
```

### Debugging ###

``` bash
### session 1
user@runner:~/.tmp/openvpn/docker$ docker exec -ti  ovpn-saml bash

bash-5.1# ip r sh
default via 172.17.0.1 dev eth0
172.17.0.0/16 dev eth0 scope link  src 172.17.0.2

bash-5.1# cat /etc/resolv.conf
nameserver 172.31.0.2
search us-east-2.compute.internal

bash-5.1# ./wrapper.sh
2022-06-14 11:13:03 AUTH: Received control message: AUTH_FAILED,CRV1:R:instance-1/7109**************6/cd*****0-6**9-4**e-9*67-b**********6:b'T**B':https://portal.sso.us-east-2.amazonaws.com/saml/assertion/M***********************************MjEzZTM1?SAMLRequest=f***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************5vO3XP4B
===
URL: https://portal.sso.us-east-2.amazonaws.com/saml/assertion/M***********************************MjEzZTM1?SAMLRequest=f***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************5vO3XP4B
===
VPN_SID: instance-1/7109**************6/cd*****0-6**9-4**e-9*67-b**********6
===
Opening browser and wait for the response file...
Waiting fo file: ./saml-response.txt
>> 295 ... sleep 5
>> 290 ... sleep 5
>> 285 ... sleep 5
>> 280 ... sleep 5
>> 275 ... sleep 5
>> 270 ... sleep 5
>> 265 ... sleep 5
>> 260 ... sleep 5
>> 255 ... sleep 5
>> 250 ... sleep 5
>> 245 ... sleep 5
>> 240 ... sleep 5
>> 235 ... sleep 5
>> 230 ... sleep 5
>> 225 ... sleep 5
>> 220 ... sleep 5
>> 215 ... sleep 5
>> 210 ... sleep 5
>> 205 ... sleep 5
>> 200 ... sleep 5
>> 195 ... sleep 5
>> 190 ... sleep 5
Running OpenVPN
2022-06-14 11:14:53 OpenVPN 2.5.7 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [MH/PKTINFO] [AEAD] built on Jun 14 2022
2022-06-14 11:14:53 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2022-06-14 11:14:53 NOTE: the current --script-security setting may allow this configuration to call user-defined scripts
2022-06-14 11:14:53 TCP/UDP: Preserving recently used remote address: [AF_INET]a.bb.ccc.ddd:443
2022-06-14 11:14:53 Socket Buffers: R=[131072->131072] S=[16384->16384]
2022-06-14 11:14:53 Attempting to establish TCP connection with [AF_INET]a.bb.ccc.ddd:443 [nonblock]
2022-06-14 11:14:53 TCP connection established with [AF_INET]a.bb.ccc.ddd:443
2022-06-14 11:14:53 TCP_CLIENT link local: (not bound)
2022-06-14 11:14:53 TCP_CLIENT link remote: [AF_INET]a.bb.ccc.ddd:443
2022-06-14 11:14:53 TLS: Initial packet from [AF_INET]a.bb.ccc.ddd:443, sid=63b3c712 0ff1a66c
2022-06-14 11:14:54 VERIFY OK: depth=1, CN=OVPN-*********-RSA-CA
2022-06-14 11:14:54 VERIFY KU OK
2022-06-14 11:14:54 Validating certificate extended key usage
2022-06-14 11:14:54 ++ Certificate has EKU (str) TLS Web Server Authentication, expects TLS Web Server Authentication
2022-06-14 11:14:54 VERIFY EKU OK
2022-06-14 11:14:54 VERIFY OK: depth=0, CN=OVPN-*********-Server
2022-06-14 11:14:54 Control Channel: TLSv1.2, cipher TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384, peer certificate: 2048 bit RSA, signature: RSA-SHA256
2022-06-14 11:14:54 [OVPN-*********-Server] Peer Connection Initiated with [AF_INET]a.bb.ccc.ddd:443
2022-06-14 11:14:55 SENT CONTROL [OVPN-*********-Server]: 'PUSH_REQUEST' (status=1)
2022-06-14 11:15:00 SENT CONTROL [OVPN-*********-Server]: 'PUSH_REQUEST' (status=1)
2022-06-14 11:15:00 PUSH: Received control message: 'PUSH_REPLY,dhcp-option DNS 10.231.0.2,route 10.231.0.0 255.255.0.0,route-gateway 10.0.2.161,topology subnet,ping 1,ping-restart 20,echo,ifconfig 10.0.2.162 255.255.255.224,peer-id 0,cipher AES-256-GCM'
2022-06-14 11:15:00 OPTIONS IMPORT: timers and/or timeouts modified
2022-06-14 11:15:00 OPTIONS IMPORT: --ifconfig/up options modified
2022-06-14 11:15:00 OPTIONS IMPORT: route options modified
2022-06-14 11:15:00 OPTIONS IMPORT: route-related options modified
2022-06-14 11:15:00 OPTIONS IMPORT: --ip-win32 and/or --dhcp-option options modified
2022-06-14 11:15:00 OPTIONS IMPORT: peer-id set
2022-06-14 11:15:00 OPTIONS IMPORT: adjusting link_mtu to 1626
2022-06-14 11:15:00 OPTIONS IMPORT: data channel crypto options modified
2022-06-14 11:15:00 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2022-06-14 11:15:00 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2022-06-14 11:15:00 net_route_v4_best_gw query: dst 0.0.0.0
2022-06-14 11:15:00 net_route_v4_best_gw result: via 172.17.0.1 dev eth0
2022-06-14 11:15:00 TUN/TAP device tun0 opened
2022-06-14 11:15:00 net_iface_mtu_set: mtu 1500 for tun0
2022-06-14 11:15:00 net_iface_up: set tun0 up
2022-06-14 11:15:00 net_addr_v4_add: 10.0.2.162/27 dev tun0
2022-06-14 11:15:00 net_route_v4_add: 10.231.0.0/16 via 10.0.2.161 dev [NULL] table 0 metric -1
2022-06-14 11:15:00 Initialization Sequence Completed
...
... have to switch to anotheh term session
...
```

``` bash
### session 2
user@runner:~/.tmp/openvpn/docker$ docker exec -ti  ovpn-saml bash

/srv # ip r sh
default via 172.17.0.1 dev eth0
10.0.2.160/27 dev tun0 scope link  src 10.0.2.162
10.231.0.0/16 via 10.0.2.161 dev tun0
172.17.0.0/16 dev eth0 scope link  src 172.17.0.2

/srv # cat /etc/resolv.conf
nameserver 172.31.0.2
search us-east-2.compute.internal
```

``` bash
### session 1
...
... return to initial term session
...
^C
2022-06-14 11:34:16 event_wait : Interrupted system call (code=4)
2022-06-14 11:34:16 net_route_v4_del: 10.231.0.0/16 via 10.0.2.161 dev [NULL] table 0 metric -1
2022-06-14 11:34:16 Closing TUN/TAP interface
2022-06-14 11:34:16 net_addr_v4_del: 10.0.2.162 dev tun0
2022-06-14 11:34:16 SIGINT[hard,] received, process exiting

bash-5.1# ip r sh
default via 172.17.0.1 dev eth0
172.17.0.0/16 dev eth0 scope link  src 172.17.0.2
```
