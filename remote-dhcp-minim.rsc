:log error "MoM setup initiated"

:beep frequency=523 length=300ms;
delay 1000ms;


# wait for some interfaces to come up
:global secondNumber 0;
:while ($secondNumber <= 30) do={
  :global wlan1Test [:len [/interface find where name="wlan1"]];
  if ($wlan1Test=1) do={
    :set secondNumber 31;
  } else={
    :set secondNumber ($secondNumber + 1);
    :delay 1;
  }
}

:delay 10;

/interface bridge
add comment=defconf name=bridge
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add address-pool=default-dhcp disabled=no interface=bridge name=defconf

:log error "Adding interfaces to the bridge"

:foreach iface in=[/interface find type=ether] do={
  :global portName [/interface get value-name=name $iface];
  :if ($iface != $wanPortName) do={
    :log info ("Adding " . $portName . " to bridge");
    /interface bridge port add bridge=bridge comment=defconf interface=portName;
  } else={
    :log info ("Not adding " . $portName . " to bridge as it is considered the WAN port");
  }
}

# conditionally add wireless ifaces to bridge and config authentication settings
:if ([:len [/interface find where name="wlan1"]] = 1) do={
  /interface bridge port add bridge=bridge comment=defconf interface=wlan1;
  /interface wireless set wlan1 mode=ap-bridge hide-ssid=no disabled=no ssid="NewTik";
}
:if ([:len [/interface find where name="wlan2"]] = 1) do={
  /interface bridge port add bridge=bridge comment=defconf interface=wlan2;
  /interface wireless set wlan2 mode=ap-bridge hide-ssid=no disabled=no ssid="NewTik";
}

/ip neighbor discovery-settings
set discover-interface-list=all
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=$wanPortName list=WAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=192.168.88.0
/ip dhcp-client
add comment=defconf dhcp-options=hostname,clientid disabled=no interface=$wanPortName
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.4.4
/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN
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
:log error "MoM setup completed!"

:beep frequency=523 length=600ms;
delay 1000ms;
