#!/bin/bash
cd ~

if [ ! -d ~/venv ];then
	sudo apt install python3-venv
	# 1. Create a virtual environment
		python3 -m venv ~/venv

	# 2. Activate it
		source ~/venv/bin/activate

	# 3. Update
		pip install --upgrade pip
		pip install pystray
fi

source ~/venv/bin/activate
python3 /opt/openvpn-proton/vpn_gui.py
