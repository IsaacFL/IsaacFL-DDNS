[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# File Name
$PSWorking="M:\Software and ISOs\PSWorking"
$File_LOG="$PSWorking\Cloudflare.log"
$File_Config="$PSWorking\Config.json"



$Config = (Get-Content -Path $File_Config -Raw) | ConvertFrom-Json
$Header = @{"X-Auth-Email" = $Config.auth_email; "X-Auth-Key" = $Config.auth_key; "Content-Type" = "application/json" }

function Write-Log {
    Param ($Text)
    $DATE=Get-Date -Format g
    Write-Host $Text
    Add-Content -Path $File_LOG -Value ($DATE + ", " + $Text)
}


#Wait for network
Start-Sleep -Seconds 1

do {
#	Start-Sleep -Seconds 1
#    Write-Log ( "Testing Network Connection")
	$ping = test-netconnection -InformationLevel Quiet
  } until ($ping)



$extDNS = ( Resolve-DnsName -Name one.one.one.one -Type AAAA ).IPAddress[1]
$Uri = "https://api.cloudflare.com/client/v4/zones?name=" + $Config.zone_name
$Response = Invoke-RestMethod -Uri $Uri -Headers $Header
$Zone_Identifier = $Response.result[0].id

$Zone_Identifier = $Zone_Identifier.Trim()


$Config.records | ForEach-Object {
    $Record_Name = $_

    # Resolve Current IP Address Externally
    $onlineip = (Resolve-DnsName $Record_Name -Type AAAA -Server $extDNS ).IPAddress


    # Resolve Current IP Address Locally
    $IP = ( Get-NetIPAddress -addressfamily ipv6 -SuffixOrigin link ).IPAddress[1]

    $Uri = "https://api.cloudflare.com/client/v4/zones/" + $Zone_Identifier + "/dns_records?name=" + $Record_Name
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Header
    $Record_Identifier = $Response.result[0].id


    if ($IP -ne $onlineip) {
        $Uri = "https://api.cloudflare.com/client/v4/zones/" + $Zone_Identifier + "/dns_records/" + $Record_Identifier
        $Body = @{"id" = $Zone_Identifier; "type" = "AAAA"; "name" = $Record_Name; "content" = $IP;} | ConvertTo-Json

        $Message = "Updating: " + $Record_NAme + " " + $IP
        Write-Log $Message
            
        try {
            $Response = Invoke-RestMethod -Method Put -Uri $Uri -Headers $Header -Body $Body
            } catch {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $responseBody = $reader.ReadToEnd();
                $Body = $responseBody | ConvertTo-Json

                $Message = "ERROR on " + $Record_Name + " Response: " + $Body
                Write-Log $Message
                }
        }
    else {
        $Message = "No Change: " + $Record_NAme + " " + $onlineip
        Write-Log $Message
        }
}
