:log error "Setting up Minim VPNs"
:global tikvpnHostname;
if ($tikvpnHostname = "") do={
  :set tikvpnHostname "tikvpn.minim.co";
}
/system routerboard settings
set protected-routerboot=enabled reformat-hold-button=1m
/tool mac-server
set allowed-interface-list=all
/tool mac-server mac-winbox
set allowed-interface-list=all
:if ([:len [/user find name=autoconf]] = 0 ) do={
   /user add group=full name=autoconf password=autoconf address=10.0.0.0/8,172.16.0.0/12 comment="Minim Setup User"
}
:if ([:len [/ip route find gateway=10.3.0.1]] > 0 ) do={
  :log info "Minim route already exists";
} else={
  :log info "Adding Minim API route";
  /ip route add check-gateway=ping distance=1 dst-address=10.0.4.0/22 gateway=10.3.0.1 comment="Minim API Gateway"
}
:if ([:len [/ppp profile find name=Minim]] = 0) do={
  /ppp profile add name=Minim use-encryption=yes comment="Minim setup profile";
}
:if ([:len [/interface sstp-client find name=Minim-setup-VPN]] > 0) do={
  :log info "Minim SSTP already exists";
} else={
  /interface sstp-client add connect-to=$tikvpnHostname disabled=yes name=Minim-setup-VPN password=autoconf profile=Minim user=autoconf_minim comment="Minim secure VPN"
}
# this firewall filter duplicates if run multiple times...
/ip firewall filter add chain=input action=accept in-interface=Minim-setup-VPN place-before=1 comment="Trust traffic from Minim-setup-VPN"
/interface sstp-client set disabled=no [ find where name=Minim-setup-VPN ]
:log error "Finished setting up Minim VPNs"
