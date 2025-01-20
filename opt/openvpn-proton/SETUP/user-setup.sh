#!/bin/bash
cd "$(dirname "$0")"

USERS=$(grep bash /etc/passwd|grep '/home'|grep '[1-2][0-9][0-9][0-9]'|awk -F':' '{print $1}')
SERVICE_NAME=proton-vpn-ghost.service
WORKING_DIR=/opt/openvpn-proton
LOGIN_CREDS_FILE=/opt/openvpn-proton/proton-creds

if [ ! -d /etc/openvpn ];then
	echo "ERROR: Openvpn dir missing..."
	exit
fi

echo "Home Config..."
if [ ! -f ~/.openvpn-proton.conf ];then
echo "
#switzerland.random.udp.ovpn
#us-chicago-19.ovpn
#us-chicago-22.ovpn
#uk.random.udp.ovpn
#us-chicago-21.ovpn
#us.random.udp.ovpn

run us-random.udp.ovpn

killswitch true" > ~/.openvpn-proton.conf
chmod 600 ~/.openvpn-proton.conf
fi

cp Autostart/openvpn-proton.desktop ~/.config/autostart/
cp Desktop/openvpn-proton.desktop ~/Desktop/

