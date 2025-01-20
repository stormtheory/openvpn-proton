#!/usr/bin/bash
cd "$(dirname "$0")"

###### TEST
####
# curl ipinfo.io/ip  # curls back your IP address, program only does this when not running as root.

#### Options
# start   - to start openvpn
# stop    - to stop and reset interfaces if killswitch is true
# restart - kills program


DEFAULT_LOCATION=us-random.udp.ovpn
DEFAULT_KILLSWITCH=true  ## true or false

quser=$(./sessions-check.sh)
DIR=/etc/openvpn
PROTON_CONFIG_DIR=/opt/openvpn-proton/Proton
OPENVPN_SCRIPT=/opt/openvpn-proton/openvpn.py
OPENVPN_CONFIG=/opt/openvpn-proton/proton.conf
LOGIN_CREDS_FILE=/etc/openvpn/proton-creds
HOME_CONFIG_FILE=.openvpn-proton.conf
DEFAULT_OPENVPN_PROTON_CONFIG=/root/.openvpn-proton.conf

function FIND_USER_CONFIG {
if [ -z "$quser" ];then
        quser=root
        echo "Defualt: $quser"
else
        echo "Session: $quser"
fi

if [ "$quser" != root ];then
        HOME_CONFIG=/home/$quser/$HOME_CONFIG_FILE
else
        HOME_CONFIG=/root/$HOME_CONFIG_FILE
fi
}


function LOADKILLSW {
FIND_USER_CONFIG
if [ -f "$HOME_CONFIG" ];then
        echo "Loading Home Config..."
        KILLSWITCH=$(cat "$HOME_CONFIG" |grep -v "#"|grep killswitch|awk '{print $2}')
else
        ## DEFAULT
        echo "Loading DEFAULT Config..."
        KILLSWITCH=$(echo "$DEFAULT_KILLSWITCH")
fi

# Error check killswitch setting
if [ "$KILLSWITCH" == true ];then
        echo "Killswitch Mode"
elif [ "$KILLSWITCH" != false ];then
        echo "ERROR: Killswitch setting can only be true or false."
        exit
fi

}


function LOAD_CONFIG {
FIND_USER_CONFIG
if [ -f "$HOME_CONFIG" ];then
	echo "Loading Home Config..."
	LOAD=$(cat "$HOME_CONFIG" |grep -v "#"|grep run|awk '{print $2}')
	KILLSWITCH=$(cat "$HOME_CONFIG" |grep -v "#"|grep killswitch|awk '{print $2}')
else
	## DEFAULT
	echo "Loading DEFAULT Config..."
	LOAD=$(echo "$DEFAULT_LOCATION")
	KILLSWITCH=$(echo "$DEFAULT_KILLSWITCH")
fi

if [ ! -d "$DIR" ];then
        echo "ERROR: Openvpn dir missing..."
        exit
fi

# Error check killswitch setting
if [ "$KILLSWITCH" == true ];then
        echo "Killswitch Mode"
elif [ "$KILLSWITCH" != false ];then
        echo "ERROR: Killswitch setting can only be true or false."
        exit
fi

echo "LOAD: $LOAD"
	if [ -z "$LOAD" ];then
		echo "ERROR: Can't find Load"
		exit
	else
		if [ ! -f $OPENVPN_CONFIG ];then
			ln -s $PROTON_CONFIG_DIR/$LOAD $OPENVPN_CONFIG
		fi
		LINKED=$(ls -al $OPENVPN_CONFIG|awk '{print $11}')
		if echo "$LINKED"|grep -q ".ovpn" ;then
			echo "Linked to $LINKED"
		else
			rm $OPENVPN_CONFIG
                        ln -s $PROTON_CONFIG_DIR/$LOAD $OPENVPN_CONFIG
			sed -i "/run/c\\run $LOAD" /root/$HOME_CONFIG_FILE
			exit
		fi
		LINKED=$(basename $LINKED)
		if [ ! -z "$LINKED" ];then
			echo "Linked to $LINKED"
			if [ ! -L $OPENVPN_CONFIG ];then
				rm $OPENVPN_CONFIG
				ln -s $PROTON_CONFIG_DIR/$LOAD $OPENVPN_CONFIG
				sed -i "/run/c\\run $LOAD" /root/$HOME_CONFIG_FILE
			fi
			if [ "$LINKED" != "$LOAD" ];then
				unlink $OPENVPN_CONFIG
				ln -s $PROTON_CONFIG_DIR/$LOAD $OPENVPN_CONFIG
				sed -i "/run/c\\run $LOAD" /root/$HOME_CONFIG_FILE
			else
				echo "Already Linked :)"
			fi
		fi
	fi

if [ ! -f $OPENVPN_CONFIG ];then
	echo "OpenVPN Config File missing..."
	exit
elif [ ! -f $LOGIN_CREDS_FILE ];then
        echo "Login Config File missing..."
        exit
else
	sed -i "/auth-user-pass/c\\auth-user-pass $LOGIN_CREDS_FILE" $PROTON_CONFIG_DIR/$LOAD
fi
}


function RESTART_INTERFACE {

INTERFACES=$(ls /sys/class/net/|egrep -v 'tun0|tun1')

while IFS= read -r eth;do
                echo "$eth"
	if [ "$eth" == lo ];then
		continue
	fi
	CARRIER=$(cat /sys/class/net/$eth/carrier)
	if [ "$CARRIER" == 1 ];then
		ip link set $eth down
		sleep 1
		ip link set $eth up	
	fi

                done <<< "$INTERFACES"
}

function PID {
	SCRIPT=$(echo $OPENVPN_SCRIPT)
	echo "$SCRIPT"
	PID=$(ps -ef|grep python3|grep -v grep|grep root|grep "$SCRIPT"|awk '{print $2}')
	PID2=$(ps -ef|grep -v grep|grep 'bin/openvpn'|awk {'print $2'})
}

function KILL_PID {
        if [ ! -z "$PID" ];then
                echo "$PID"
                kill -9 $PID
        fi
        if [ ! -z "$PID2" ];then
                echo "$PID2"
        	kill -9 $PID2
	fi
}

function GRAB_ASSETS {
ROUTER_GW=$(route -nn|egrep -v 'tun0|tun1' | awk 'FNR==3 {print $2}'|grep -v '0.0.0.0')
INET_DEV=$(route -nn|egrep -v 'tun0|tun1' | awk 'FNR==3 {print $8}')
}

########## RESTART
if [ ! -z "$1" ];then
        if [ "$1" == restart ];then
                PID
		KILL_PID
		LOADKILLSW
		if [ "$KILLSWITCH" == true ];then
                        RESTART_INTERFACE
                        sleep 2
                fi
                exit
        fi
fi

########## STOP
if [ ! -z "$1" ];then
	if [ "$1" == stop ];then
		PID
		KILL_PID
		LOADKILLSW
		if [ "$KILLSWITCH" == true ];then
			RESTART_INTERFACE
			sleep 2
		fi
		exit
	fi
fi


########### START UP

LOAD_CONFIG
GRAB_ASSETS
if [ -z "$ROUTER_GW" ];then
	RESTART_INTERFACE
	sleep 2
        GRAB_ASSETS
elif [ "$ROUTER_GW" == '0.0.0.0' ];then
	RESTART_INTERFACE
        sleep 2
        GRAB_ASSETS
fi

if [ -z "$INET_DEV" ];then
	RESTART_INTERFACE
	sleep 2
	GRAB_ASSETS
fi

echo "GW: $ROUTER_GW"
echo "INET: $INET_DEV"

### OpenVPN command:
#openvpn --auth-nocache --auth-user-pass $LOGIN_CREDS_FILE --config $OPENVPN_CONFIG

if [ "$KILLSWITCH" == true ];then
	$OPENVPN_SCRIPT --auth-user-pass $LOGIN_CREDS_FILE --config $OPENVPN_CONFIG --gw $ROUTER_GW --inet $INET_DEV --killswitch
else
	$OPENVPN_SCRIPT --auth-user-pass $LOGIN_CREDS_FILE --config $OPENVPN_CONFIG
fi

if [ "$KILLSWITCH" == true ];then
	while true;do
		## Keeps the Killswitch from coming undone
		sleep 90
	done
fi
