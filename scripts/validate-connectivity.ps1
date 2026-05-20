# Day 7 validation script (run after terraform apply)
# Requires: OpenSSH client, Terraform outputs

param(
    [string]$TerraformDir = "$PSScriptRoot\..\terraform"
)

$ErrorActionPreference = "Stop"
Push-Location $TerraformDir

try {
    $publicIp   = terraform output -raw public_ec2_public_ip
    $privateIp  = terraform output -raw private_ec2_private_ip
    $keyPath    = terraform output -raw private_key_path

    Write-Host "=== Day 7 Connectivity Validation ===" -ForegroundColor Cyan
    Write-Host "Public instance:  $publicIp"
    Write-Host "Private instance: $privateIp"
    Write-Host "Private key:      $keyPath"
    Write-Host ""

    $sshOpts = @("-i", $keyPath, "-o", "StrictHostKeyChecking=accept-new", "-o", "ConnectTimeout=15")

    Write-Host "[1/4] SSH to public instance..." -ForegroundColor Yellow
    ssh @sshOpts "ec2-user@$publicIp" "hostname && curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/"

    Write-Host "[2/4] Ping private from public (VPC)..." -ForegroundColor Yellow
    ssh @sshOpts "ec2-user@$publicIp" "ping -c 3 $privateIp"

    Write-Host "[3/4] Curl private app from public..." -ForegroundColor Yellow
    ssh @sshOpts "ec2-user@$publicIp" "curl -s --connect-timeout 5 http://${privateIp}:8080/ || curl -s http://${privateIp}/"

    Write-Host "[4/4] Private outbound via NAT..." -ForegroundColor Yellow
    ssh @sshOpts -J "ec2-user@${publicIp}" "ec2-user@$privateIp" "curl -s -o /dev/null -w '%{http_code}' https://aws.amazon.com"

    Write-Host ""
    Write-Host "All validation steps completed." -ForegroundColor Green
}
finally {
    Pop-Location
}
