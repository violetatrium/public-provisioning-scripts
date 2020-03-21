:log error "Setting up Minim VPNs"
/system routerboard settings
set protected-routerboot=enabled reformat-hold-button=1m
/tool mac-server
set allowed-interface-list=all
/tool mac-server mac-winbox
set allowed-interface-list=all
/user add group=full name=autoconf password=autoconf address=10.0.0.0/8,172.16.0.0/12 comment="Minim Setup User"
/ip route add check-gateway=ping distance=1 dst-address=10.0.0.113/32 gateway=10.3.0.1 comment="Minim API Gateway"
/interface sstp-client add connect-to=tikvpn.minim.co disabled=yes name=Minim-setup-VPN password=autoconf profile=default-encryption user=autoconf comment="Minim secure VPN"
/ip firewall filter add chain=input action=accept in-interface=Minim-setup-VPN place-before=1 comment="Trust traffic from Minim-setup-VPN"
/interface sstp-client set disabled=no [ find where name=Minim-setup-VPN ]
:log error "Finished setting up Minim VPNs"
