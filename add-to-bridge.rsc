:log info "Adding interfaces to the bridge";

:foreach iface in=[/interface find type=ether] do={
  :global portName [/interface get value-name=name $iface];
  :if ([:len [/interface find name=$portName comment=WAN]] = 0) do={
    :if ([:len [/interface bridge port find interface=$portName]] = 0 do={
      :put info ("Adding " . $portName . " to bridge");
      /interface bridge port add bridge=bridge comment=defconf interface=$portName;
    }
  } else={
    :log info ("Not adding " . $portName . " to bridge as it is considered the WAN port");
  }
}

:foreach iface in=[/interface find type=sfp] do={
  :global portName [/interface get value-name=name $iface];
  :if ([:len [/interface find name=$portName comment=WAN]] = 0) do={
    :if ([:len [/interface bridge port find interface=$portName]] = 0 do={
      :log info ("Adding " . $portName . " to bridge");
      /interface bridge port add bridge=bridge comment=defconf interface=$portName;
    }
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
