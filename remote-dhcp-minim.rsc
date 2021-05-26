# set Minim data center, no need to change for most users
:global tikvpnHostname "tikvpn.minim.co";

:log info "Minim setup initiated"

:beep frequency=523 length=300ms;
delay 1000ms;
:if ([:len [/interface get [/interface find comment=WAN] name]] = 0 ) do={
  :log error ("No WAN interface defined");
  exit;
}
:global WANInterfaceName [/interface get [/interface find comment=WAN] name];

# clean up previous versions - won't work if they don't exist, do at end
#/system script remove firewall-minim.rsc
#/system script remove minim-networks.rsc
#/system script remove add-to-bridge.rsc

:log info ("Downloading Bridge Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/minim-core/add-to-bridge.rsc" dst-path=/flash/add-to-bridge.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

:log info ("Downloading IP & DHCP Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/ip-dhcp.rsc" dst-path=/flash/ip-dhcp.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;


:log info ("Downloading Firewall Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/minim-core/firewall-minim.rsc" dst-path=/flash/firewall-minim.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

:log info ("Downloading Minim Tools");
/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/minim-core/minim-networks.rsc" dst-path=/flash/minim-networks.rsc mode=https
delay 500ms;
:beep frequency=500 length=200ms;
:beep frequency=600 length=200ms;

/system script add name=add-to-bridge.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/add-to-bridge.rsc contents]
/system script add name=ip-dhcp.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/ip-dhcp.rsc contents]
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
:log info "running ip-dhcp.rsc script"
/system script run ip-dhcp.rsc
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
/system script remove ip-dhcp.rsc
/system script remove dhcp-minim.rsc
:beep frequency=523 length=600ms;
