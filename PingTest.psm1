function Test-ServerPing {
    param (
        [string]$ServerList = "servers.txt"
    )

    $servers = Get-Content $ServerList
    $pingResults = @()

    foreach ($server in $servers) {
        $ping = Test-Connection -ComputerName $server -Count 2 -Quiet
        $status = if ($ping) { "Online" } else { "Offline" }
        $pingResults += [PSCustomObject]@{
            Server = $server
            Status = $status
        }
    }

    $pingResults | Export-Csv -Path "PingResults.csv" -NoTypeInformation
}
