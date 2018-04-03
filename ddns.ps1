# Vars
$hostname  = "isaacfl"
$token  = "0ee3b92c-97f6-4555-9e1e-b5483e18ebc6"

# Get Current IP Addresses
$ip4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip6 = Get-NetIPAddress -AddressFamily ipv6 -AddressState Preferred -PrefixOrigin RouterAdvertisement -SuffixOrigin link


"Updating Host " + $hostname + " to: "
write-host "IP4 " $ip4
write-host "IP6 " $ip6.ipaddress
$URL = "https://www.duckdns.org/update?domains=" + $hostname + "&token=" + $token + "&ip=" + $ip4 + "&ipv6=" + $ip6.ipaddress
$result = Invoke-RestMethod $URL -Credential $credential
"Server Response: " + $result
