# public-provisioning-scripts
Public Provisioning Scripts

These scripts are required to bring a tik online in Minim. 

They should be executed in the following order:

* remote-dhcp-minim.rsc
* firewall-minim.rsc
* minim-networks.rsc

remote-dhcp-minim will expect firewall-minim and minim-networks to exist.

remote-static-minim will expect firewall-minim and minim-networks to exist.

remote-pppoe-minim will expect firewall-minim and minim-networks to exist.
