# Vars
$hostname  = "isaacfl"
$token  = "0ee3b92c-97f6-4555-9e1e-b5483e18ebc6"

$fqdn = $hostname + ".psp.iznmort.com"

# Get Current IP Addresses
$ip4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip6 = (Resolve-DnsName $fqdn -Server "192.168.1.1" -Type AAAA).IPAddress
$onlineip6 = (Resolve-DnsName $fqdn -Server "8.8.8.8" -Type AAAA).IPAddress
$onlineip4 = (Resolve-DnsName $fqdn -Server "8.8.8.8" -Type A).IPAddress

$Change = 0
if ($ip4 -ne $onlineip4) { $Change = $Change + 1 }
if ($ip6 -ne $onlineip6) { $Change = $Change + 1 }

if ($Change -ne 0) {

"Updating Host " + $hostname + " to: "
write-host "Current IP4 " $ip4
write-host "Current IP6 " $ip6

$URL = "https://www.duckdns.org/update?domains=" + $hostname + "&token=" + $token + "&ip=" + $ip4 + "&ipv6=" + $ip6
$result = Invoke-RestMethod $URL -Credential $credential
"Server Response: " + $result
}
else { 
	write-host "No Change"
	write-host "Current IP4 " $onlineip4
	write-host "Current IP6 " $onlineip6
	}

pause
