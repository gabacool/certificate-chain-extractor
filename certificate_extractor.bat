@echo off
title Universal Certificate Chain Extractor for Mac

echo =============================================
echo Universal Certificate Chain Extractor for Mac
echo =============================================
echo.
echo This script extracts Certificate Authority (CA) certificates
echo from ANY HTTPS server for installation on Mac.
echo.
echo Common use cases:
echo - Internal company websites with private CAs
echo - Development/staging servers with self-signed certificates  
echo - Enterprise applications (SAS, GitLab, Jenkins, etc.)
echo - IoT devices or network equipment with custom certificates
echo.
echo This script will:
echo 1. Connect to your HTTPS server
echo 2. Extract all Certificate Authority (CA) certificates
echo 3. Convert them to Mac-compatible format (.pem)
echo 4. Generate step-by-step installation instructions for Mac
echo.

set /p SERVER_URL="Enter HTTPS server URL (e.g., https://internal-server.company.com): "

if "%SERVER_URL%"=="" (
    echo Error: Server URL is required
    pause
    exit /b 1
)

echo.
echo Extracting certificates from: %SERVER_URL%
echo Output directory: .\certificates
echo.

powershell -ExecutionPolicy Bypass -File ".\extract_certificates.ps1" -ServerUrl "%SERVER_URL%"

echo.
echo =============================================
echo Certificate extraction complete!
echo.
echo Next steps:
echo 1. Check .\certificates\ for CA certificate files
echo 2. Transfer .pem files to your Mac
echo 3. Follow instructions in mac_installation_guide.md
echo =============================================
pause
