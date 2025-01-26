# openvpn-proton
# In Beta Testing

A non-proprietary, open source, small but mighty Proton Ghost client with System Tray GUI and Service. Using AES-256 encryption to create a secure VPN tunnel to the internet, sleep peacefully at night knowing your privacy is just that much safer. You must have an active Proton subscription.

![Screenshot from 2025-01-04 21-42-54](https://github.com/user-attachments/assets/29066e4f-9906-4869-8320-adeae1067028)

# Features
1) Killswitch if enabled, will tempoaray remove the Default Gateway of your network. This prevents other connections outside of the VPN other than your normal LAN connections to include DNS connections. Sets a DNS for the 1.1.1.1 DNS across the VPN.
2) A system tray user interface is python program that allows you to control the VPN without root privileged access.
3) Disable/Enable Killswitch
4) Allows normal LAN traffic
5) Checks to make sure your connection is working and your Public IP has changed.
6) Persistent settings and Default settings.
7) Only when ran as non-privileged user will the client reach out using 'curl ipinfo.io/ip' to pull your NEW public IP address to compare and alert you if your public IP did not change or is not what is expected. **This will soon be able to be disabled**
8) Very light with only ~600 lines of code plus comments and no unexplained network traffic, not listed above. No hidden privacy issues and can be fully audited by anyone.

# Limitation
1) Only one computer on a network per VPN location. For example: two computers at your home can't be both connected to Chicago's Proton Server from the same network at the same time. This seems to be an issue with openvpn and Proton, still looking into the issue.

# Coming-Soon
1) More configurations for locations around the world.
2) Anything else, just ask. Feedback is greatly needed.

# System Requirements
In order to use this, will need openvpn 2.4 or better, becuase of the openvpn configs from Proton.

At this time Ubuntu/Mint is only tested, but should work on RHEL/Rocky/CentOS, no Yum/DNF package support yet. Please feedback if you want a YUM/DNF .rpm package. If there is interest in other Linux flavors/families please let me know or it's just a project for me and my family :P as our daily drivers.

# How it Works
Creates a service proton-vpn-ghost.service and two files in /etc/openvpn/proton-creds and /opt/openvpn-proton/proton.conf is a softlink to Proton's config file in /opt/openvpn-proton/Proton. Adds in the sudoers file for all users to systemctl start and stop proton-vpn-ghost.service. 

# INSTALL
1) Download the latest released .deb package file off of github and install on your system.

		sudo apt deb openvpn-proton-ghost-client*.deb

	Add your username and password for Proton in /etc/openvpn/proton-creds. This file can only be read by your local root user. Account information can be found at https://account.protonvpn.com/login

	NOTE: Pystray is a dependant for this program. This can be done by running command: 'pip install pystray' or 'apt install python3-pystray' depends on your distro.

		pip install pystray
		apt install python3-pystray
	
 	To always be on VPN run command:

  		systemctl enable proton-vpn-ghost.service

3) Build DEB Install file:

   NOTE: Pystray is a dependant for this program. This can be done by running command: 'pip install pystray' or 'apt install python3-pystray' depends on your distro.

		pip install pystray
		apt install python3-pystray

   Download the zip file of the code, off of Github. This is found under the [<> Code] button on https://github.com/stormtheory/openvpn-proton.

   Extract directory from the zip file. Run the build script in the directory.

        	./build

   Install the outputted .deb file.

   		sudo apt deb openvpn-proton-ghost-client*.deb

   Add your username and password for Proton in /etc/openvpn/proton-creds. This file can only be read by your local root user. Account information can be found at https://account.protonvpn.com/login

   To always be on VPN run command:

   		systemctl enable proton-vpn-ghost.service

5) Install without Package Manager, run commands:
	
   NOTE: Pystray is a dependant for this program. This can be done by running command: 'pip install pystray' or 'apt install python3-pystray' depends on your distro.

		pip install pystray
		apt install python3-pystray

   Download the zip file of the code, off of Github. This is found under the [<> Code] button on https://github.com/stormtheory/openvpn-proton.

   Extract directory from the zip file. Run the following commands within the directory.

        opt/openvpn-proton/SETUP/install-configure-proton-vpn-ghost.sh 

   Add your username and password for Proton in /etc/openvpn/proton-creds. This file can only be read by your local root user. Account information can be found at https://account.protonvpn.com/login

   To always be on VPN run command:

   		systemctl enable proton-vpn-ghost.service

# User Agreement:
This project is not a company or business. By using this project’s works, scripts, or code know that you, out of respect are entitled to privacy to highest grade. This product will not try to steal, share, collect, or sell your information. However 3rd parties such at Github may try to use your data without your consent. Users or admins should make reports of issue(s) related to the project’s product to the project to better equip or fix issues for others who may run into the same issue(s). By using this project’s works, scripts, code, or ideas you as the end user or admin agree to the GPL-2.0 License statements and acknowledge the lack of Warranty. As always, give us a Star on Github if you find this useful, and come help us make it better.

As stated in the GPL-2.0 License:
    "This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details." Also "ABSOLUTELY NO WARRANTY".
