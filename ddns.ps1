$HostName = "isv6.psp.iznmort.com"
$UserName = "s8V2ThySz2z9Wz2L"
$Password = "7X5SPwl0xQlMJqaA"

$ip4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip6 = Get-NetIPAddress -AddressFamily ipv6 -AddressState Preferred -PrefixOrigin RouterAdvertisement -SuffixOrigin link

    
 
$URL = "https://{0}:{1}@domains.google.com/nic/update?hostname={2}&myip={3}" -F $UserName, $Password, $HostName, $ip6

write-host $URL
Write-host "Sending update request to Google DNS..."

$Response = Invoke-WebRequest $URL
    $Result = $Response.Content
    $StatusCode = $Response.StatusCode

write-host $Result, $StatusCode
pause
    

    switch ($Result) {
      "good*" { 
        $splitResult = $Result.split(" ")
        $newIp = $splitResult[1]
        Write-Verbose "IP successfully updated for $HostName to $newIp."
      }
      "nochg*" {
        $splitResult = $Result.split(" ")
        $newIp = $splitResult[1]
        Write-Verbose "No change to IP for $HostName (already set to $newIp)."
      }
      "badauth" {
        throw "The username/password you provided was not valid for the specified host."
      }
      "nohost" {
        throw "The hostname you provided does not exist, or dynamic DNS is not enabled."
      }
      "notfqdn" {
        throw "The supplied hostname is not a valid fully-qualified domain name."
      }
      "badagent" {
        throw "You are making bad agent requests, or are making a request with IPV6 address (not supported)."
      }
      "abuse" {
        throw "Dynamic DNS access for the hostname has been blocked due to failure to interperet previous responses correctly."
      }
      "911" {
        throw "An error happened on Google's end; wait 5 minutes and try again."
      }
    }
 
 

