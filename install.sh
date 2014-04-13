#!/bin/sh
# Downloads and installs DNS Tunnel.

# Configuration Variables
SNIPROXY_VERSION=0.3.2

# Check Root
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

# Create & Swap To Directory
mkdir ~/temp
cd ~/temp

# Update Package List
apt-get update

###############
## SNI Proxy ##
###############

# Install Build Essential
apt-get install build-essential cdbs debhelper dh-autoreconf dpkg-dev libev-dev libpcre3-dev libudns-dev pkg-config

# Download SNI Proxy Source
wget -O sniproxy.tar.gz https://github.com/dlundquist/sniproxy/archive/$SNIPROXY_VERSION.tar.gz

# Extract SNI Proxy Source
tar xfvz sniproxy.tar.gz

# Change To Directory
cd sniproxy

# Build Package
dpkg-buildpackage

# Install Package
dpkg -i ../sniproxy_<version>_<arch>.deb

#############
## DNSMasq ##
#############

# Install DNSMasq
apt-get install dnsmasq

# Stop DNSMasq
/etc/init.d/dnsmasq stop

################
## DNS Tunnel ##
################

# Download & Install
wget -O /etc/rc.local https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/conf/rc.local
wget -O /usr/local/bin/dnstun https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun

# Update Boot Script
wget -O /usr/local/bin/dnstun-init https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun-init

# Update Crontab
wget -O crontab https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/conf/crontab
crontab -u root crontab

# Run DNS Tunnel
dnstun
