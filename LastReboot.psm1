function Get-LastRebootTime {
    param (
        [string]$ServerList = "servers.txt",
        [string]$Username,
        [string]$Password
    )

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

    $servers = Get-Content $ServerList
    $rebootResults = @()

    foreach ($server in $servers) {
        $lastBoot = Invoke-Command -ComputerName $server -Credential $Cred -ScriptBlock {
            Get-WmiObject Win32_OperatingSystem | Select-Object @{Name="LastBootTime";Expression={$_.LastBootUpTime}}
        }

        $rebootResults += [PSCustomObject]@{
            Server      = $server
            LastReboot  = $lastBoot.LastBootTime
        }
    }

    $rebootResults | Export-Csv -Path "LastReboot.csv" -NoTypeInformation
}
