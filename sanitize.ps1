Param (
    [switch]$Strict
)

function Test-PortConnection {
    param(
        [string]$Name,
        [int]$Port
    )

    Write-Host ""
    Write-Host "Testing the '$Name' port: $Port" -ForegroundColor Magenta
    Write-Host ""

    $result = Test-NetConnection -ComputerName localhost -Port $Port -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded)
    {
        Write-Host "Port '$Port' in use!" -ForegroundColor Red

        if ($Strict) { exit }
    }
    else
    {
        Write-Host "Ok!" -ForegroundColor Green
    }
}

Write-Host "Testing the connection to the required ports..."

# Try to stop IIS.

Write-Host ""
Write-Host "Trying to stop IIS if any" -ForegroundColor Magenta
Write-Host ""

try { Invoke-Expression "iisreset /timeout:0 /stop" } catch { Write-Host "No IIS found" }

# Test the local ports required by the project.

Test-PortConnection -Name "Traefik (Local Proxy)" -Port 8079

Test-PortConnection -Name "MSSQL Server" -Port 14330

Test-PortConnection -Name "Solr" -Port 8984

Test-PortConnection -Name "Sitecore xConnect" -Port 8081
