function Get-RDPEventLog {
    param (
        [string]$ServerList = "servers.txt",
        [string]$Username,
        [string]$Password
    )

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

    $servers = Get-Content $ServerList
    $rdpEvents = @()

    foreach ($server in $servers) {
        $events = Invoke-Command -ComputerName $server -Credential $Cred -ScriptBlock {
            Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=4624]]" -MaxEvents 5
        }

        foreach ($event in $events) {
            $rdpEvents += [PSCustomObject]@{
                Server   = $server
                Time     = $event.TimeCreated
                User     = $event.Properties[5].Value
                LogonType = $event.Properties[8].Value
            }
        }
    }

    $rdpEvents | Export-Csv -Path "RDPEventLog.csv" -NoTypeInformation
}
