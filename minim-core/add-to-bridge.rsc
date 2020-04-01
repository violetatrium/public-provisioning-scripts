:log info "Adding interfaces to the bridge";

:foreach iface in=[/interface find type=ether] do={
  :global portName [/interface get value-name=name $iface];
  :local interfaceIsWAN [:len [/interface find name=$portName comment=WAN]];
  :local interfaceAlreadyBridged [:len [/interface bridge port find interface=$portName]];
  :if (( $interfaceIsWAN = 0 ) && ( $interfaceAlreadyBridged = 0)) do={
    :log info ("Adding " . $portName . " to bridge. interfaceIsWAN = " . $interfaceIsWAN . " interfaceAlreadyBridged = " . $interfaceAlreadyBridged );
    /interface bridge port add bridge=bridge comment=defconf interface=$portName;
  } else={
    :log info ("Not adding " . $portName . " to bridge as it is considered the WAN port or already bridged. interfaceIsWAN = " . $interfaceIsWAN . " interfaceAlreadyBridged = " . $interfaceAlreadyBridged);
  }
}

:foreach iface in=[/interface find type=sfp] do={
  :global portName [/interface get value-name=name $iface];
  :local interfaceIsWAN [:len [/interface find name=$portName comment=WAN]];
  :local interfaceAlreadyBridged [:len [/interface bridge port find interface=$portName]];
  :if (( $interfaceIsWAN = 0 ) && ( $interfaceAlreadyBridged = 0)) do={
    :log info ("Adding " . $portName . " to bridge. interfaceIsWAN = " . $interfaceIsWAN . " interfaceAlreadyBridged = " . $interfaceAlreadyBridged );
    /interface bridge port add bridge=bridge comment=defconf interface=$portName;
  } else={
    :log info ("Not adding " . $portName . " to bridge as it is considered the WAN port or already bridged. interfaceIsWAN = " . $interfaceIsWAN . " interfaceAlreadyBridged = " . $interfaceAlreadyBridged);
  }
}

# conditionally add wireless ifaces to bridge and config authentication settings
:local interfaceAlreadyBridged [:len [/interface bridge port find interface=wlan1]];
:if (([:len [/interface find where name="wlan1"]] = 1) && ( $interfaceAlreadyBridged = 0)) do={
  /interface bridge port add bridge=bridge comment=defconf interface=wlan1;
  /interface wireless set wlan1 mode=ap-bridge hide-ssid=no disabled=no ssid="NewTik";
}
:local interfaceAlreadyBridged [:len [/interface bridge port find interface=wlan2]];
:if (([:len [/interface find where name="wlan2"]] = 1) && ( $interfaceAlreadyBridged = 0)) do={
  /interface bridge port add bridge=bridge comment=defconf interface=wlan2;
  /interface wireless set wlan2 mode=ap-bridge hide-ssid=no disabled=no ssid="NewTik";
}
