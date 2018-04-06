# Vars
$hostname  = "isaacfl"
$token  = "0ee3b92c-97f6-4555-9e1e-b5483e18ebc6"

$fqdn = $hostname + ".psp.iznmort.com"

# Get Current IP Addresses
$ip4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip6 = (Resolve-DnsName $fqdn -Server "192.168.1.1" -Type AAAA).IPAddress

"Updating Host " + $hostname + " to: "
write-host "IP4 " $ip4
write-host "IP6 " $ip6

$URL = "https://www.duckdns.org/update?domains=" + $hostname + "&token=" + $token + "&ip=" + $ip4 + "&ipv6=" + $ip6
$result = Invoke-RestMethod $URL -Credential $credential
"Server Response: " + $result
pause
