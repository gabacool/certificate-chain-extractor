# Certificate Chain Extractor for Mac

A PowerShell tool that automatically extracts Certificate Authority (CA) certificates from any HTTPS server and prepares them for installation on macOS.

## 🎯 Problem Solved

When connecting to internal corporate servers, development environments, or any HTTPS endpoint using private/self-signed Certificate Authorities, macOS shows errors like:
- "self signed certificate in certificate chain"
- "certificate verify failed" 
- "unable to verify the first certificate"

This tool automates the process of extracting and preparing the necessary CA certificates for macOS trust installation.

## ✨ Features

- 🔍 **Automatic CA Detection** - Analyzes certificate chains and identifies required Certificate Authorities
- 🍎 **Mac-Ready Format** - Converts certificates to PEM format compatible with macOS Keychain
- 📋 **Smart Filtering** - Extracts only CA certificates (skips server certificates that aren't needed on clients)
- 📖 **Generated Instructions** - Creates detailed step-by-step installation guides for macOS
- 🔧 **Error Handling** - Tests connections and provides clear error messages
- 🎨 **User-Friendly** - Both GUI launcher and command-line interface

## 🚀 Quick Start

### Option 1: GUI Launcher (Easiest)
1. Double-click `universal_certificate_extractor.bat`
2. Enter your HTTPS server URL when prompted
3. Follow the generated instructions

### Option 2: PowerShell Command Line
```powershell
.\extract_certificates.ps1 -ServerUrl "https://your-server.com"
```

## 📁 What It Creates

```
certificates/
├── ca_certificate_0.pem          # Intermediate CA (install on Mac)
├── ca_certificate_1.pem          # Root CA (install on Mac)
├── server_certificate.pem        # Server cert (reference only)
└── mac_installation_guide.md     # Complete installation instructions
```

## 💡 Use Cases

### Enterprise & Corporate
- Internal company websites with private Certificate Authorities
- Corporate applications (GitLab, Jenkins, SAS, etc.)
- Development and staging environments
- BYOD (Bring Your Own Device) setup for employee personal Macs

### Development & DevOps
- Self-signed certificates in development environments
- Staging servers with custom CAs
- API endpoints with private certificates
- Docker containers with self-signed certificates

### Network & IoT
- Network equipment management interfaces
- IoT devices with custom certificates
- Home lab servers
- Network attached storage (NAS) devices

## 📋 Usage Examples

```powershell
# Basic usage
.\extract_certificates.ps1 -ServerUrl "https://internal-gitlab.company.com"

# Custom output directory
.\extract_certificates.ps1 -ServerUrl "https://dev-api.company.com" -OutputDir "C:\my_certs"

# Show help and all options
.\extract_certificates.ps1 -Help
```

## 🛠️ Installation

1. **Download** or clone this repository
2. **Extract** to any folder (e.g., `C:\tools\certificate-extractor`)
3. **Run** either the batch file or PowerShell script

### Requirements
- Windows with PowerShell 5.0+
- Network access to the target HTTPS server
- Administrator privileges (for some certificate operations)

## 🍎 macOS Installation Process

The tool generates detailed instructions, but here's the overview:

1. **Transfer** the generated `.pem` CA certificate files to your Mac
2. **Open Keychain Access** on Mac
3. **Import** CA certificates into the **System** keychain
4. **Set each CA to "Always Trust"**
5. **Test** your application - certificate errors should be resolved

### Command Line Alternative (macOS)
```bash
# Install CA certificates via command line
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca_certificate_0.pem
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca_certificate_1.pem
```

## 🔧 How It Works

1. **Connects** to the target HTTPS server via standard SSL/TLS handshake
2. **Extracts** the complete certificate chain sent by the server
3. **Analyzes** the chain to identify Certificate Authorities vs server certificates
4. **Converts** CA certificates to PEM format (macOS compatible)
5. **Generates** detailed installation instructions with certificate details

## 🎯 Why This Tool Exists

**Certificate chain validation errors** are common when working with:
- Private/internal Certificate Authorities
- Self-signed certificates
- Enterprise environments with custom PKI
- Development environments

Manually extracting and installing certificates is tedious and error-prone. This tool automates the entire process and ensures you install only what's necessary.

## 🔒 Security Considerations

- **Only extracts CA certificates** that the server already sends during normal SSL handshake
- **Does not bypass security** - it helps establish proper trust relationships
- **Requires explicit user action** to mark certificates as trusted on macOS
- **Generated certificates** should only be trusted for servers you control or trust

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- Support for other operating systems (Linux trust stores)
- Additional certificate formats
- Batch processing for multiple servers
- Certificate validation and expiry warnings

## 📝 License

MIT License - feel free to use, modify, and distribute.

## 🐛 Troubleshooting

### Common Issues

**"Cannot connect to server"**
- Verify the URL is correct and accessible
- Check VPN/network connectivity
- Ensure Windows can reach the target server

**"Certificate extraction failed"**
- Server might not be sending complete certificate chain
- Try connecting with a web browser first to verify SSL works
- Check if server requires specific SSL/TLS versions

**"Certificate errors persist on Mac"**
- Verify certificates were installed in **System** keychain (not Login)
- Ensure certificates are set to "Always Trust"
- Restart the application after installing certificates
- Clear application certificate caches if needed

### Getting Help

1. Run with `-Help` flag to see all options
2. Check the generated `mac_installation_guide.md` for detailed instructions
3. Verify certificate details match what your server actually uses

---

**Made with ❤️ for the macOS + Enterprise software community**
