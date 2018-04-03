# Vars
$hostname  = "isv6.psp.iznmort.com"
$user  = "s8V2ThySz2z9Wz2L"
$pass  = "7X5SPwl0xQlMJqaA"

# Get Current IP Addresses
$ip4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip6 = Get-NetIPAddress -AddressFamily ipv6 -AddressState Preferred -PrefixOrigin RouterAdvertisement -SuffixOrigin link

    
# Basic Auth Formatting
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)


# Get IP4 First
$ipPub = $ip4

# Output
"Updating Host " + $hostname + " to: " + $ipPub
$URL = "https://domains.google.com/nic/update?hostname=" + $hostname + "&myip=" + $ipPub
$result = Invoke-RestMethod $URL -Credential $credential
"Server Response: " + $result


# Get IP6 First
$ipPub = $ip6.ipaddress

# Output
"Updating Host " + $hostname + " to: " + $ipPub
$URL = "https://domains.google.com/nic/update?hostname=" + $hostname + "&myip=" + $ipPub
$result = Invoke-RestMethod $URL -Credential $credential
"Server Response: " + $result
