#!/bin/sh
# Download & Install DNS Tunnel

# Check Root
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

# Check Arguments
if [ -z "$1" ]; then
	echo "No configuration URL supplied."
	exit 1
fi

# Check Configuration URL
#if ! curl -f -I -o /dev/null -s --head "$1"; then
#	echo "Invalid configuration URL supplied."
#	exit 1
#fi

# Configuration Variables
CONFIGURATION_DIR=/etc/dnstun
CONFIGURATION_URL="$1"
DEBIAN_FRONTEND=noninteractive
SNIPROXY_VERSION=0.3.5

# Create & Swap To Directory
mkdir ~/temp
cd ~/temp

# Update Package List
apt-get update

# Install Build Essential
apt-get -q -y install build-essential cdbs debhelper dh-autoreconf dpkg-dev libev-dev libpcre3-dev pkg-config

##########
## UDNS ##
##########

# Create & Swap To Directory
mkdir udns
cd udns

# Download Source
wget http://archive.ubuntu.com/ubuntu/pool/universe/u/udns/udns_0.4-1.dsc
wget http://archive.ubuntu.com/ubuntu/pool/universe/u/udns/udns_0.4.orig.tar.gz
wget http://archive.ubuntu.com/ubuntu/pool/universe/u/udns/udns_0.4-1.debian.tar.gz

# Extract Source
tar xfz udns_*.orig.tar.gz

# Change Directory
cd udns-*/

# Extract Source
tar xfz ../udns_*.debian.tar.gz

# Build Package
dpkg-buildpackage

# Install Package
dpkg -i ../libudns-dev_*.deb ../libudns0_*.deb

# Exit Directory
cd ~/temp

###############
## SNI Proxy ##
###############

# Create & Swap To Directory
mkdir sniproxy
cd sniproxy

# Download Source
wget https://www.github.com/dlundquist/sniproxy/archive/$SNIPROXY_VERSION.tar.gz

# Extract Source
tar xfz $SNIPROXY_VERSION.tar.gz

# Change To Directory
cd sniproxy-*

# Build Package
dpkg-buildpackage

# Install Package
dpkg -i ../sniproxy_*.deb

#############
## DNSMasq ##
#############

# Install DNSMasq
apt-get -q -y install dnsmasq

# Stop DNSMasq
/etc/init.d/dnsmasq stop

################
## DNS Tunnel ##
################

# Download
wget -O /etc/rc.local https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/conf/rc.local
wget -O /usr/local/bin/dnstun https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun
wget -O /usr/local/bin/dnstun-init https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun-init

# Set Permissions
chmod +x /usr/local/bin/dnstun /usr/local/bin/dnstun-init

# Make Directory
mkdir /etc/dnstun

# Download Configuration
wget -O $CONFIGURATION_DIR/host $CONFIGURATION_URL/host
wget -O $CONFIGURATION_DIR/user $CONFIGURATION_URL/user

# Update Crontab
echo "*/15 * * * * /usr/local/bin/dnstun \"$CONFIGURATION_URL\" >/dev/null 2>&1" > crontab
crontab -u root crontab

# Change Directory & Remove Temp Directory
cd ~
rm -rf temp

# Initialise DNS Tunnel
dnstun-init

# Start DNS Tunnel
dnstun "$CONFIGURATION_URL"
