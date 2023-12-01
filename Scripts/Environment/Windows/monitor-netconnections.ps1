while ($true) {
    Clear-Host
    Write-Host "Monitoring Network Connections..."

    $establishedConnections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }

    if ($establishedConnections.Count -gt 0) {
        Write-Host "New Established Connections Detected! Taking action..."
        # Add your specific actions here, such as sending an alert or logging the information.
    }

    $establishedConnections | Format-Table -AutoSize
    Start-Sleep -Seconds 5
}
