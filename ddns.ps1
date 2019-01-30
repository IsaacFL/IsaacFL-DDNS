<#
Dynamic DNS - Cloudflare
ipv6 only as ipv4 will be done via pfsense
#>

# Vars

$hostname  = "isaacfl.psp"
$domain = "iznmort.com"
$extDNS = "2606:4700:4700::1111"

$fqdn = $hostname + "." + $domain

# File Name
$PSWorking="M:\Software\PSWorking"
$File_IP="$PSWorking\IP.txt"
$File_IDS="$PSWorking\Cloudflare.ids"
$File_LOG="$PSWorking\Cloudflare.log"
$File_Config="$PSWorking\Config.json"

$DATE=Get-Date -Format g

$Config = (Get-Content -Path $File_Config -Raw) | ConvertFrom-Json
$Header = @{"X-Auth-Email" = $Config.auth_email; "X-Auth-Key" = $Config.auth_key; "Content-Type" = "application/json" }



function Write-Log {
    Param ($Text)
    Write-Host $Text
    Add-Content -Path $File_LOG -Value ($DATE + ", " + $Text)
}


Write-Log "Check Initiated"
Write-Log $fqdn


# Resolve Current IP Address Locally
$ip6 = (Resolve-DnsName $fqdn -Type AAAA).IPAddress

$Message = "Local IP6 " + $ip6
Write-Log $Message



# Resolve Current IP Address Externally
$onlineip6 = (Resolve-DnsName $fqdn -Type AAAA -Server $extDNS ).IPAddress
Write-Log ( "External IP6 " + $onlineip6)



if ($ip6 -ne $onlineip6) {
    $Message = "Updating Host " + $fqdn + " to: " + $ip6
    Write-Log $Message
    }
else {
    $Message = "No Change: Current IP6 " + $onlineip6
    Write-Log $Message
    }



<#
https://gist.github.com/settachok/9023eb08587b02fa4a01f2c0ee8604ea

PUT zones/:zone_identifier/dns_records/:identifier

curl -X PUT "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/dns_records/372e67954025e0ba6aaa6d586b9e0b59" \
     -H "X-Auth-Email: user@example.com" \
     -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"example.com","content":"127.0.0.1","ttl":120,"proxied":false}'


#>