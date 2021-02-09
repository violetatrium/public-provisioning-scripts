# Change these to desired username and password of the speed test user
:global speedtestUser CHANGE_ME;
:global speedtestPass CHANGE_ME;
# Change this to your local timezone (eg. Europe/London)
:global systemTimezone CHANGE_ME;

/user group
add name=speed-testers policy=test,winbox,!local,!telnet,!ssh,!ftp,!reboot,!read,!write,!policy,!password,!web,!sniff,!sensitive,!api,!romon,!dude,!tikapp

/user 
add comment="Minim speed test user" group=speed-testers name=$speedtestUser password=$speedtestPass

# Implement the following to reboot once a day. We've found this to be useful
# in mitigating several problems that spring up with heavy speed test tool use.
/system clock
set time-zone-name=$systemTimezone
/system scheduler
add comment="Reboot daily to mitigate problems with intermittent speedtest failures" interval=1d name="Reboot Daily" on-event="/system reboot" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=jan/01/1970 start-time=00:03:00

# UDP test is not used, but there is no way to prevent it 
# from trying to send the packets anyway.
# Block outgoing UDP
/ip firewall filter 
add action=drop chain=output comment="Drop outgoing UDP packets" protocol=udp
