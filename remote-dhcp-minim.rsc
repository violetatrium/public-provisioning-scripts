:log error "Minim setup initiated"

:beep frequency=523 length=300ms;
delay 1000ms;

# clean up previous versions
/system script remove firewall-minim.rsc 
/system script remove minim-networks.rsc

/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/firewall-minim.rsc" dst-path=/flash/firewall-minim.rsc mode=https
delay 5000ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/minim-networks.rsc" dst-path=/flash/minim-networks.rsc mode=https
delay 5000ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

/system script add name=firewall-minim.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/firewall-minim.rsc contents]
/system script add name=minim-networks.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/minim-networks.rsc contents]

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

/system script run firewall-minim.rsc
/system script run minim-networks.rsc

delay 2000ms;
:beep frequency=523 length=600ms;

