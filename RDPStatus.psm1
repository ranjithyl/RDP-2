function Check-RDPStatus {
    param (
        [string]$ServerList = "servers.txt",
        [string]$Username,
        [string]$Password
    )

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

    $servers = Get-Content $ServerList
    $rdpResults = @()

    foreach ($server in $servers) {
        $serviceStatus = Invoke-Command -ComputerName $server -Credential $Cred -ScriptBlock {
            (Get-Service -Name TermService).Status
        }

        $portStatus = Test-NetConnection -ComputerName $server -Port 3389 -InformationLevel Detailed

        $rdpResults += [PSCustomObject]@{
            Server        = $server
            ServiceStatus = $serviceStatus
            PortStatus    = if ($portStatus.TcpTestSucceeded) { "Open" } else { "Closed" }
        }
    }

    $rdpResults | Export-Csv -Path "RDPStatus.csv" -NoTypeInformation
}
