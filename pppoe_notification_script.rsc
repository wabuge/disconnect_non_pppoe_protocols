:local pppoeUser
:local pppoePass
:local pppoeService
:local pppoeAddr
:local pppoeSessionTime
:local pppoeUptime
:local pppoeBytesIn
:local pppoeBytesOut

/ppp active find where service=pppoe and !connected do={
  set pppoeUser [/ppp active get $i user]
  set pppoePass [/ppp active get $i password]
  set pppoeService [/ppp active get $i service-name]
  set pppoeAddr [/ppp active get $i address]
  set pppoeSessionTime [/ppp active get $i session-time]
  set pppoeUptime [/ppp active get $i uptime]
  set pppoeBytesIn [/ppp active get $i bytes-in]
  set pppoeBytesOut [/ppp active get $i bytes-out]

  :local pppoeDisconnectedTime
  :set pppoeDisconnectedTime ([:pick [/system clock get time] 0 8] . "T" . [:pick [/system clock get time] 9 17] . "Z")

  /ip hotspot user add name=$pppoeUser password=$pppoePass server=hotspot-pppoe profile=default idle-timeout=5m

  /ip hotspot walled-garden ip add action=accept disabled=no dst-address=pppoe-disconnect.html

  /ip hotspot active add address=$pppoeAddr mac-address=00:00:00:00:00:00 server=hotspot-pppoe login-by=mac

  /ip hotspot user set $pppoeUser idle-timeout=0s

  /ip hotspot user remove $pppoeUser

  /ip hotspot active remove [find where address=$pppoeAddr]

  /tool fetch url="http://pppoe-disconnect.html?user=$pppoeUser&service=$pppoeService&sessionTime=$pppoeSessionTime&uptime=$pppoeUptime&bytesIn=$pppoeBytesIn&bytesOut=$pppoeBytesOut&disconnectedTime=$pppoeDisconnectedTime" keep-result=no
}
