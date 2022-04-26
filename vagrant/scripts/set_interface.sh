ip link
rm /etc/network/interfaces

echo "
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
pre-up sleep 2

iface eth1 inet static
      address 192.168.56.10
      netmask 255.255.255.0
" >> /etc/network/interfaces

#systemctl restart network
ifdown eth0
ifup eth0
ifup eth1