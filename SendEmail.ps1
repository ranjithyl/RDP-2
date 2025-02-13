param (
    [string]$Recipient = "ranjithyl95@yahoo.com"
)

$smtpServer = "smtp.gmail.com"
$from = "noreply@example.com"

$subject = "Windows Server Validation Report"
$body = "Attached are the latest validation reports for the servers after patching."

$attachments = @("PingResults.csv", "RDPStatus.csv", "LastReboot.csv", "RDPEventLog.csv")

Send-MailMessage -To $Recipient -From $from -Subject $subject -Body $body -SmtpServer $smtpServer -Attachments $attachments
