# specify readonly mode (no config will be changed on the device)
/interface bridge
  add name="minim-opmode" comment="DO NOT EDIT: readonly" disabled=yes

  # add temporary autoconf user
/user
  add group=full name=autoconf password=autoconf address=10.0.0.0/8,172.16.0.0/12 comment="Minim Setup User"

# add private route for API gateway
/ip route
  add check-gateway=ping distance=1 dst-address=10.0.4.0/22 gateway=10.3.0.1 comment="Minim API Gateway"

# add temporary vpn client
/interface sstp-client
  add connect-to=tikvpn.minim.co disabled=yes name=Minim-setup-VPN password=autoconf \
  profile=default-encryption user=autoconf_minim comment="Minim setup VPN"

# add firewall rule to allow traffic over vpn
/ip firewall filter
  add chain=input action=accept in-interface=Minim-setup-VPN place-before=1 comment="Trust traffic from Minim-setup-VPN"

# enable temporary vpn client
/interface sstp-client
  set disabled=no [ find where name=Minim-setup-VPN ]
