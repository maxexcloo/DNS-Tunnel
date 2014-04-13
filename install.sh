#!/bin/sh
# Downloads and installs DNS Tunnel.

# Configuration Variables
DEBIAN_FRONTEND=noninteractive
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
tar xfz udns_0.4.orig.tar.gz

# Change Directory
cd udns-0.4/

# Extract Source
tar xfz ../udns_0.4-1.debian.tar.gz

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
wget -O sniproxy.tar.gz https://github.com/dlundquist/sniproxy/archive/$SNIPROXY_VERSION.tar.gz

# Extract Source
tar xfvz sniproxy.tar.gz

# Change To Directory
cd sniproxy-*

# Build Package
dpkg-buildpackage

# Install Package
dpkg -i ../sniproxy_*.deb

# Exit Directory
cd ~/temp

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

# Download & Install
wget -O /usr/local/bin/dnstun https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun
wget -O /usr/local/bin/dnstun-init https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/dnstun-init
chmod +x /usr/local/bin/dnstun /usr/local/bin/dnstun-init

# Make Directory
mkdir /etc/dnstun

# Update Boot Script
wget -O /etc/rc.local https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/conf/rc.local

# Update Crontab
wget -O crontab https://raw.githubusercontent.com/maxexcloo/DNS-Tunnel/master/conf/crontab
crontab -u root crontab

# Initialise DNS Tunnel
dnstun-init

# Run DNS Tunnel
dnstun
