:log info "Minim setup initiated"

:beep frequency=523 length=300ms;
delay 1000ms;
:global WANInterfaceName [/interface get [/interface find comment=WAN] name];

# clean up previous versions - won't work if they don't exist, do at end
#/system script remove firewall-minim.rsc 
#/system script remove minim-networks.rsc
#/system script remove add-to-bridge.rsc

:log info ("Downloading Bridge Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/add-to-bridge.rsc" dst-path=/flash/add-to-bridge.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

:log info ("Downloading Firewall Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/firewall-minim.rsc" dst-path=/flash/firewall-minim.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

:log info ("Downloading Minim Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/minim-networks.rsc" dst-path=/flash/minim-networks.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

/system script add name=add-to-bridge.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/add-to-bridge.rsc contents]
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

:if ( [/interface bridge find where name=bridge] = "") do={
  :log info "Adding bridge"
  /interface bridge add comment=defconf name=bridge
}
:if ( [/interface list find where name=WAN] = "") do={
  :log info "Adding WAN"
  /interface list add comment=defconf name=WAN
}
:if ( [/interface list find where name=LAN] = "") do={
  :log info "Adding LAN"
  /interface list add comment=defconf name=LAN
}

:log info "running add-to-bridge script"
/system script run add-to-bridge.rsc

:if ( [/ip pool find where name=default-dhcp] = "") do={
  :log info "Adding default DHCP pool";
  /ip pool add name=default-dhcp ranges=192.168.88.10-192.168.88.254
} else={
  :log info "Default DHCP Pool Already Exists";
}
:local DHCPPoolExists [:len [/ip dhcp-server find address-pool=default-dhcp]]
:if (($DHCPPoolExists = 0 ) && ([/ip dhcp-server find where name=default-dhcp] = "")) do={
  :log info "Adding DHCP pool to server"
  /ip dhcp-server add address-pool=default-dhcp disabled=no interface=bridge name=defconf
}

/ip neighbor discovery-settings
set discover-interface-list=all

/interface list member
:local $LANBridged [:len [/interface list member find interface=bridge]];
:if ( $LANBridged = 0 ) do={
  /interface list member add comment=defconf interface=bridge list=LAN
}

:local $WANListMember [:len [/interface list member find interface=$WANInterfaceName]];
:if ( $WANListMember = 0 ) do={
  /interface list member add comment=defconf interface=$WANInterfaceName list=WAN
}

/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=192.168.88.0

if ([dhcp-client get [/ip dhcp-client find interface=$WANInterfaceName] value-name=interface]] = "" ) do={
  /ip dhcp-client add comment=defconf dhcp-options=hostname,clientid disabled=no interface=$WANInterfaceName
}
if ([/ip dhcp-server get [/ip dhcp-server find comment=defconf] value-name=address] = "" ) do={
  /ip dhcp-server network add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1
}
/ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.4.4

:log info "running firewall script"
/system script run firewall-minim.rsc
:log info "finished firewall script, started minim-networks"
/system script run minim-networks.rsc

delay 2000ms;
:log info "finished remote-dhcp-minim.rsc"
# clean up 
/system script remove firewall-minim.rsc 
/system script remove minim-networks.rsc
/system script remove add-to-bridge.rsc
:beep frequency=523 length=600ms;
