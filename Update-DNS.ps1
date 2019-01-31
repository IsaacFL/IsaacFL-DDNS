[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# File Name
$File_IP="$PSScriptRoot\IP.txt"
$File_IDS="$PSScriptRoot\Cloudflare.ids"
$File_LOG="$PSScriptRoot\Cloudflare.log"
$File_Config="$PSScriptRoot\Config.json"
$DATE=Get-Date -Format g
$Config = (Get-Content -Path $File_Config -Raw) | ConvertFrom-Json
$Header = @{"X-Auth-Email" = $Config.auth_email; "X-Auth-Key" = $Config.auth_key; "Content-Type" = "application/json" }

function Write-Log {
    Param ($Text)
    Write-Host $Text
    Add-Content -Path $File_LOG -Value ($DATE + ", " + $Text)
}

Write-Log "Check Initiated"

$IP = Invoke-RestMethod -Uri "http://ipv4.icanhazip.com"
$IP = $IP.Trim()

if (Test-Path $File_IP)
{
    $IP_Old = Get-Content $File_IP
    $IP_Old = $IP_Old.Trim()
    if ($IP -eq $IP_Old)
    {
        Write-Log "IP does not change, Quitting."
        Exit
    }
}

if (-NOT ($IP -match '^([0-9]{1,3}\.){3}[0-9]{1,3}$'))
{
    Write-Log "Fetched IP does not valid! Quitting."
    Exit
}

Set-Content -Path $File_IP -Value $IP

if (Test-Path $File_IDS)
{
    $Zone_Identifier = Get-Content -Path $File_IDS | Out-String
} else {
    $Uri = "https://api.cloudflare.com/client/v4/zones?name=" + $Config.zone_name
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Header
    $Zone_Identifier = $Response.result[0].id
    Set-Content -Path $File_IDS -Value $Zone_Identifier
}
$Zone_Identifier = $Zone_Identifier.Trim()

$Config.records | ForEach-Object {
    $Record_Name = $_
    $Uri = "https://api.cloudflare.com/client/v4/zones/" + $Zone_Identifier + "/dns_records?name=" + $Record_Name
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Header
    $Record_Identifier = $Response.result[0].id

    $Uri = "https://api.cloudflare.com/client/v4/zones/" + $Zone_Identifier + "/dns_records/" + $Record_Identifier
    $Body = @{"id" = $Zone_Identifier; "type" = "A"; "name" = $Record_Name; "content" = $IP; "proxied" = $FALSE} | ConvertTo-Json
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

$Message = "IP changed to " + $IP
Write-Log $Message