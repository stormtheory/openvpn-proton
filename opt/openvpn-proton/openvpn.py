#!/usr/bin/python3
# Written by StormTheory DEC2024

import argparse
import subprocess
import time
import sys
import os
import threading
import logging
from subprocess import check_output


# TEXT COLORS
class bcolors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    NC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Defaults
VPN_DEV='tun0'
DNS_IP='1.1.1.1'
EXIT_PYTHON = 'FALSE'


SCRIPT = subprocess.run(["basename {}".format(__file__)], shell=True, stdout=subprocess.PIPE).stdout.decode('ascii').rstrip('\r\n')
print(SCRIPT)

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--debug", action='store_true', help='Run program in debug mode')
parser.add_argument("--gw", help='Routers default GW')
parser.add_argument("--inet", help='Routers INET')
parser.add_argument("--killswitch", action='store_true', help='Turn killswitch on')
parser.add_argument("--config", help='openvpn config file location')
parser.add_argument("--auth-user-pass", help='username and password file location')
args = parser.parse_args()

### SET LOGGING LEVEL
if args.debug:
    lLevel = logging.DEBUG     # INFO, DEBUG
else:
    lLevel = logging.INFO     # INFO, DEBUG

### LOGGER CONFIG
logger = logging.getLogger()
logger.setLevel(lLevel)

logging.debug('debug')

if args.killswitch:
    if args.gw:
        if args.inet:
            print('Killswitch Mode')
        else:
            print('--killswitch option requires --gw and --inet')
            sys.exit(1)
    else:
        print('--killswitch option requires --gw and --inet')
        sys.exit(1)



def THERE_ONLY_CAN_BE_ONE():
  global EXIT_PYTHON
  RUNNING_TEST = subprocess.run(["ps -ef|grep python3|grep './{}'|grep -v grep|wc -l".format(SCRIPT)], shell=True, stdout=subprocess.PIPE).stdout
  COUNT = str(RUNNING_TEST.decode('ascii').rstrip('\r\n'))
  logging.debug('App PID Run Count: ' + COUNT)
  if COUNT > str('1'):
    print(bcolors.YELLOW + 'App is already running. Exiting...' + bcolors.NC)
    EXIT_PYTHON = 'True'
    sys.exit(1)
  else:
    EXIT_PYTHON = 'False'
THERE_ONLY_CAN_BE_ONE()

#### ERROR CHECK FOR IF FILES ARE PRESENT
def check_file_exists_exit(FILE):
  try:
    with open(FILE) as f:
      pass
  except FileNotFoundError:
    print('ERROR: ' + FILE + ' was not found!... exiting')
    sys.exit(1)
def check_dir_exists_exit(DIR):
  if not os.path.exists(DIR):
    print('ERROR: ' + DIR + ' was not found!... exiting')
    sys.exit(1)


def start_vpn_with_killswitch(LOGIN_CREDS_FILE, OPENVPN_CONFIG, GW_IP, INET):
    subprocess.run(['openvpn --auth-nocache --auth-user-pass {} --config {}'.format(LOGIN_CREDS_FILE, OPENVPN_CONFIG)], shell=True)
    global EXIT_PYTHON
    EXIT_PYTHON == 'TRUE'
    sys.exit()

def start_vpn_with_no_killswitch(LOGIN_CREDS_FILE, OPENVPN_CONFIG):
    subprocess.run(['openvpn --auth-nocache --auth-user-pass {} --config {}'.format(LOGIN_CREDS_FILE, OPENVPN_CONFIG)], shell=True)
    global EXIT_PYTHON
    EXIT_PYTHON == 'TRUE'
    sys.exit()

 
def exit_app(icon, item):
    print('Exit called')
    global EXIT_PYTHON
    EXIT_PYTHON = 'TRUE'
    sys.exit(0)



LOGIN_CREDS_FILE = vars(args)['auth_user_pass']
OPENVPN_CONFIG = vars(args)['config']
check_file_exists_exit(LOGIN_CREDS_FILE)
check_file_exists_exit(OPENVPN_CONFIG)


if args.killswitch:
    GW_IP = vars(args)['gw']
    INET = vars(args)['inet']
    t1 = threading.Thread(target=start_vpn_with_killswitch, args=(LOGIN_CREDS_FILE,OPENVPN_CONFIG,GW_IP,INET,), daemon=False)
    t1.start()
    while True:
        time.sleep(2)
        service = subprocess.run(["ip link show {}".format(VPN_DEV)], shell=True, stdout=subprocess.PIPE)
        ReturnCode = service.returncode
        if str(ReturnCode) == '0':
            print('Installing Killswitch')
            subprocess.run(['route del -net 0.0.0.0 gw {} netmask 0.0.0.0 dev {}'.format(GW_IP,INET)], shell=True)
            subprocess.run(['resolvectl dns {} {}'.format(VPN_DEV,DNS_IP)], shell=True)
            break
        else:
            continue
else:
    t2 = threading.Thread(target=start_vpn_with_no_killswitch, args=(LOGIN_CREDS_FILE,OPENVPN_CONFIG,), daemon=False)
    t2.start()

while True:
    time.sleep(5)
    if EXIT_PYTHON == 'TRUE':
        print('Need to Exit GUI')
        PID = subprocess.run(["ps -ef|grep python3|grep './{}'|grep -v grep|awk '{print $2}'".format(SCRIPT)], shell=True, stdout=subprocess.PIPE).stdout.decode('ascii').rstrip('\r\n')
        print('PID')
        EXIT_OUTPUT = subprocess.run(["kill -9 {}".format(PID)], shell=True)
        print(EXIT_OUTPUT)
        sys.exit(0)
