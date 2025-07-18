# Universal Certificate Chain Extractor for Mac
# Extracts Certificate Authority (CA) certificates from ANY HTTPS server
# Usage: .\extract_certificates.ps1 -ServerUrl "https://your-server.com"

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerUrl,
    
    [string]$OutputDir = ".\certificates",
    
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Universal Certificate Chain Extractor for Mac

USAGE:
    .\extract_certificates.ps1 -ServerUrl "https://your-server.com"
    .\extract_certificates.ps1 -ServerUrl "https://internal-gitlab.company.com" -OutputDir ".\my_certs"

PARAMETERS:
    -ServerUrl    : The HTTPS URL of any server (required)
    -OutputDir    : Directory to save certificates (default: .\certificates)
    -Help         : Show this help message

EXAMPLES:
    .\extract_certificates.ps1 -ServerUrl "https://internal-server.company.com"
    .\extract_certificates.ps1 -ServerUrl "https://dev-api.mycompany.com"
    .\extract_certificates.ps1 -ServerUrl "https://jenkins.company.com"
    .\extract_certificates.ps1 -ServerUrl "https://gitlab.company.com"

WORKS WITH:
    - Internal company websites with private Certificate Authorities
    - Development/staging servers with self-signed certificates
    - Enterprise applications (SAS, GitLab, Jenkins, etc.)
    - IoT devices or network equipment with custom certificates
    - Any HTTPS server causing "certificate chain" errors on Mac

OUTPUT:
    - Individual CA certificate files (.pem format for Mac)
    - Installation guide with step-by-step Mac instructions
    - Summary of certificates found and what to install
"@
    exit
}

function Write-Banner {
    param([string]$Message)
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host $Message -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n>>> $Message" -ForegroundColor Cyan
}

function Extract-Hostname {
    param([string]$Url)
    try {
        $uri = [System.Uri]$Url
        return $uri.Host
    } catch {
        Write-Error "Invalid URL format: $Url"
        exit 1
    }
}

function Test-ServerConnection {
    param([string]$Hostname, [int]$Port = 443)
    
    Write-Step "Testing connection to $Hostname`:$Port"
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($Hostname, $Port)
        $tcpClient.Close()
        Write-Host "✓ Connection successful" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Extract-CertificateChain {
    param([string]$Hostname, [int]$Port = 443, [string]$OutputPath)
    
    Write-Step "Extracting certificate chain from $Hostname`:$Port"
    
    try {
        # Connect and get certificate
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($Hostname, $Port)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, {$true})
        $sslStream.AuthenticateAsClient($Hostname)
        
        # Get certificate and build chain
        $cert = $sslStream.RemoteCertificate
        $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
        $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
        $chain.Build($cert2)
        
        Write-Host "✓ Certificate chain has $($chain.ChainElements.Count) certificates" -ForegroundColor Green
        
        $certificates = @()
        $caCount = 0
        
        # Process each certificate in chain
        for ($i = 0; $i -lt $chain.ChainElements.Count; $i++) {
            $certInChain = $chain.ChainElements[$i].Certificate
            $subject = $certInChain.Subject
            $issuer = $certInChain.Issuer
            $isCA = ($i -gt 0)  # First cert is server cert, rest are CAs
            
            # Create PEM format
            $pemCert = "-----BEGIN CERTIFICATE-----`n" + 
                       [System.Convert]::ToBase64String($certInChain.RawData, [System.Base64FormattingOptions]::InsertLineBreaks) + 
                       "`n-----END CERTIFICATE-----"
            
            if ($isCA) {
                # Save CA certificates
                $filename = "$OutputPath\ca_certificate_$caCount.pem"
                [System.IO.File]::WriteAllText($filename, $pemCert)
                $caCount++
                
                $certificates += [PSCustomObject]@{
                    Index = $i
                    Type = "Certificate Authority"
                    Subject = $subject
                    Issuer = $issuer
                    Filename = Split-Path $filename -Leaf
                    InstallOnMac = $true
                }
                
                Write-Host "  ✓ CA $($caCount): $subject" -ForegroundColor Yellow
            } else {
                # Server certificate - save for reference but not needed on Mac
                $filename = "$OutputPath\server_certificate.pem"
                [System.IO.File]::WriteAllText($filename, $pemCert)
                
                $certificates += [PSCustomObject]@{
                    Index = $i
                    Type = "Server Certificate"
                    Subject = $subject
                    Issuer = $issuer
                    Filename = Split-Path $filename -Leaf
                    InstallOnMac = $false
                }
                
                Write-Host "  ✓ Server: $subject" -ForegroundColor Blue
            }
        }
        
        # Cleanup
        $sslStream.Close()
        $tcpClient.Close()
        
        return $certificates
        
    } catch {
        Write-Host "✗ Certificate extraction failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Generate-MacInstallationGuide {
    param([array]$Certificates, [string]$ServerUrl, [string]$OutputPath)
    
    Write-Step "Generating Mac installation guide"
    
    $caCerts = $Certificates | Where-Object { $_.InstallOnMac -eq $true }
    
    $guide = @"
# Certificate Installation Guide for Mac

## Server Information
- **Server URL**: $ServerUrl
- **Certificates Found**: $($Certificates.Count) total ($($caCerts.Count) CAs + $($Certificates.Count - $caCerts.Count) server)
- **Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Certificate Details
"@

    foreach ($cert in $Certificates) {
        $guide += @"

### $($cert.Type) - $($cert.Filename)
- **Subject**: $($cert.Subject)
- **Issuer**: $($cert.Issuer)
- **Install on Mac**: $($cert.InstallOnMac)
"@
    }

    $guide += @"

## Files to Transfer to Mac
Copy these files from Windows to your Mac:
"@

    foreach ($ca in $caCerts) {
        $guide += "`n- ✅ **$($ca.Filename)** (Certificate Authority)"
    }

    $guide += @"
- 📋 **mac_installation_guide.md** (this file)

## Installation Steps on Mac

### Step 1: Transfer Files
Transfer the CA certificate files to your Mac using:
- Email attachments
- Cloud storage (Google Drive, OneDrive, iCloud)
- USB drive
- AirDrop
- File sharing over network

### Step 2: Install Certificate Authorities

1. **Open Keychain Access** on Mac:
   - Press `Cmd + Space`, type "Keychain Access", press Enter

2. **Import CA certificates** (IMPORTANT: Install in **System** keychain):
"@

    $step = 1
    foreach ($ca in $caCerts) {
        $guide += "`n   $step. Drag **$($ca.Filename)** into **System** keychain"
        $step++
    }

    $guide += @"

### Step 3: Trust the Certificate Authorities

For each CA certificate you installed:

1. **Find the certificate** in System keychain
2. **Double-click** on it to open
3. **Expand the "Trust" section**
4. **Set "When using this certificate" to "Always Trust"**
5. **Close and enter admin password** when prompted

### Step 4: Test Your Application

1. **Restart your application** after installing certificates
2. **Try connecting** to the server
3. **Should work without certificate errors!** ✅

## Alternative: Command Line Installation

If you prefer command line installation on Mac:

```bash
# Install CA certificates (requires admin password)
"@

    foreach ($ca in $caCerts) {
        $guide += "`nsudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $($ca.Filename)"
    }

    $guide += @"
```

## Troubleshooting

If you still get certificate errors:

1. **Verify certificates are in System keychain** (not Login keychain)
2. **Ensure "Always Trust" is set** for all CA certificates
3. **Restart your application** completely
4. **Clear application certificate caches** if available

## Certificate Chain Validation

Your Mac will now validate certificates like this:
```
Server Certificate ($ServerUrl)
├── Issued by: [Intermediate CA if present]
│   └── Issued by: [Root CA] ✅ (Trusted)
└── Certificate chain valid ✅
```
"@

    $guideFile = "$OutputPath\mac_installation_guide.md"
    [System.IO.File]::WriteAllText($guideFile, $guide)
    Write-Host "✓ Installation guide saved: $guideFile" -ForegroundColor Green
}

function Show-Summary {
    param([array]$Certificates, [string]$OutputPath)
    
    Write-Banner "CERTIFICATE EXTRACTION COMPLETE"
    
    Write-Host "`nSUMMARY:" -ForegroundColor White
    Write-Host "- Server certificates: $($Certificates.Count)" 
    Write-Host "- CA certificates to install: $(($Certificates | Where-Object InstallOnMac).Count)"
    Write-Host "- Output directory: $OutputPath"
    
    Write-Host "`nFILES CREATED:" -ForegroundColor White
    Get-ChildItem $OutputPath | ForEach-Object {
        if ($_.Name -like "ca_certificate_*.pem") {
            Write-Host "  ✅ $($_.Name) (Install on Mac)" -ForegroundColor Green
        } elseif ($_.Name -like "server_certificate.pem") {
            Write-Host "  📄 $($_.Name) (Reference only)" -ForegroundColor Blue  
        } else {
            Write-Host "  📋 $($_.Name) (Instructions)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nNEXT STEPS:" -ForegroundColor White
    Write-Host "1. Transfer CA certificate files (.pem) to your Mac"
    Write-Host "2. Follow instructions in mac_installation_guide.md"
    Write-Host "3. Install certificates in Mac System keychain"
    Write-Host "4. Set certificates to 'Always Trust'"
    Write-Host "5. Test your application connection"
    
    Write-Host "`n" + "=" * 60 -ForegroundColor Green
}

# Main execution
try {
    Write-Banner "UNIVERSAL CERTIFICATE CHAIN EXTRACTOR"
    
    # Parse server URL
    $hostname = Extract-Hostname -Url $ServerUrl
    Write-Host "Target server: $hostname" -ForegroundColor White
    
    # Create output directory
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        Write-Host "Created output directory: $OutputDir" -ForegroundColor Green
    }
    
    # Test connection
    if (!(Test-ServerConnection -Hostname $hostname)) {
        Write-Error "Cannot connect to server. Check VPN/network connection."
        exit 1
    }
    
    # Extract certificates
    $certificates = Extract-CertificateChain -Hostname $hostname -OutputPath $OutputDir
    
    # Generate installation guide
    Generate-MacInstallationGuide -Certificates $certificates -ServerUrl $ServerUrl -OutputPath $OutputDir
    
    # Show summary
    Show-Summary -Certificates $certificates -OutputPath $OutputDir
    
} catch {
    Write-Error "Script failed: $($_.Exception.Message)"
    exit 1
}
