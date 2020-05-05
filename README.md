# public-provisioning-scripts
Public Provisioning Scripts

These scripts are required to bring a tik online in Minim. 

How to use this to configure a MikroTik for Minim in DHCP.

Login to your MikroTik and load a terminal. 

Paste the following 3 lines into the terminal, this will set the WAN port to ether1 (you can change this if you desire).

`
/interface set ether1 comment=WAN

/tool fetch url="https://raw.githubusercontent.com/violetatrium/public-provisioning-scripts/master/remote-dhcp-minim.rsc" dst-path=/flash/dhcp-minim.rsc mode=https

/system script add name=dhcp-minim.rsc owner=admin policy=password,policy,read,reboot,sensitive,sniff,test,write source=[/file get flash/dhcp-minim.rsc contents]
`

Once the script has downloaded and installed itself, you can run the script.

`
/system script run dhcp-minim.rsc
`

#Add your stuff here






They should be executed in the following order:

* remote-dhcp-minim.rsc
* firewall-minim.rsc
* minim-networks.rsc

remote-dhcp-minim will expect firewall-minim and minim-networks to exist.

remote-static-minim will expect firewall-minim and minim-networks to exist.

remote-pppoe-minim will expect firewall-minim and minim-networks to exist.
