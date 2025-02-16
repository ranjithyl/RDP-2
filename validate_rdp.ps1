param (
    [string]$ServerListPath,
    [string]$OutputCsvPath,
    [string]$Username,
    [string]$Password
)

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

# Read the list of servers
$Servers = Get-Content $ServerListPath

# Initialize results array
$Results = @()

foreach ($server in $Servers) {
    # Check if the server is reachable
    $ping = (Test-Connection -ComputerName $server -Count 2 -Quiet)
    $PingStatus = if ($ping) { "Online" } else { "Offline" }

    # Check if RDP port (3389) is open
    try {
        $RDPPortStatus = Test-NetConnection -ComputerName $server -Port 3389 -InformationLevel Quiet
    } catch {
        $RDPPortStatus = "Error"
    }

    # Get last boot time and RDP service status
    try {
        $remoteResult = Invoke-Command -ComputerName $server -Credential $Credential -ScriptBlock {
            $os = Get-WmiObject -Class Win32_OperatingSystem
            $lastBootTime = $os.LastBootUpTime
            $rdpService = Get-Service -Name TermService -ErrorAction SilentlyContinue
            $rdpStatus = if ($rdpService) { $rdpService.Status } else { "Service Not Found" }

            [PSCustomObject]@{
                LastBootTime = $lastBootTime
                RDPStatus   = $rdpStatus
            }
        }
        $lastBootTime = $remoteResult.LastBootTime
        $rdpStatus = $remoteResult.RDPStatus
    } catch {
        $lastBootTime = "Error"
        $rdpStatus = "Error"
    }

    # Store results
    $Results += [PSCustomObject]@{
        Server       = $server
        PingStatus   = $PingStatus
        RDPPortStatus = $RDPPortStatus
        LastBootTime = $lastBootTime
        RDPStatus   = $rdpStatus
    }
}

# Export results to CSV
$Results | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
Write-Host "Validation complete. Report saved to $OutputCsvPath"
