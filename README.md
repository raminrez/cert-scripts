# SSL Certificate Manager for Marzneshin

An interactive bash script to easily manage SSL certificates for Marzneshin VPN panel using either `acme.sh` or `certbot`.

## Features

- 🔐 **Two Certificate Methods**: Choose between `acme.sh` and `certbot`
- 📧 **Email Memory**: Remembers and suggests your last used email
- 🌐 **Domain Validation**: Validates domain format before processing
- 📁 **Custom Paths**: Choose where to store your certificates
- 📜 **Certificate Registry**: Track all created certificates
- 🗑️ **Certificate Management**: List and remove existing certificates
- 🎨 **Colorized Output**: Easy-to-read interface with colors
- ✅ **Domain-Named Files**: Certificates named after your domain (e.g., `example.com.crt`)

## Quick Install & Run

> **⚠️ Important:** This script is interactive and requires user input. Avoid using `curl | bash` as it doesn't support interactive prompts properly.

### Method 1: Download, Review, and Execute (Recommended)

```bash
# Download the script
curl -O https://raw.githubusercontent.com/raminrez/cert-scripts/main/ssl-cert-manager.sh

# Make it executable
chmod +x ssl-cert-manager.sh

# Review the script (recommended)
cat ssl-cert-manager.sh

# Run the script
sudo ./ssl-cert-manager.sh
```

### Method 2: One-Line Install and Run

```bash
# Download and run in one command
curl -sSL https://raw.githubusercontent.com/raminrez/cert-scripts/main/ssl-cert-manager.sh -o ssl-cert-manager.sh && chmod +x ssl-cert-manager.sh && sudo ./ssl-cert-manager.sh
```

### Method 3: Clone Repository

```bash
# Clone the repository
git clone https://github.com/raminrez/cert-scripts.git
cd cert-scripts

# Make script executable
chmod +x ssl-cert-manager.sh

# Run the script
sudo ./ssl-cert-manager.sh
```

## Requirements

- **Ubuntu/Debian** based system
- **Root access** (script must run with sudo)
- **Internet connection** for downloading certificates
- **Domain** pointing to your server's IP address

**Note:** The script automatically installs all required dependencies including:

- `curl` - For downloading tools and certificates
- `wget` - For file downloads
- `socat` - Required for acme.sh standalone mode
- `cron` - For automatic certificate renewals
- `certbot` - Installed only when using certbot method

## Usage

1. **Run the script as root:**

   ```bash
   sudo ./ssl-cert-manager.sh
   ```

2. **First run will automatically:**

   - Update system packages
   - Check and install required dependencies
   - Verify port availability (80 and 443)

3. **Choose from the main menu:**

   - `1` - Install SSL Certificate using acme.sh
   - `2` - Install SSL Certificate using certbot
   - `3` - List existing certificates
   - `4` - Remove certificate
   - `5` - Exit

4. **Follow the interactive prompts:**
   - Enter your email (or use the suggested one)
   - Enter your domain name
   - Choose output path (or use default: `/var/lib/marzneshin/certs`)

## Certificate Methods

### Method 1: acme.sh (Recommended)

- More lightweight and flexible
- Better for automation and renewals
- Supports multiple CA providers

**What it does:**

1. Downloads and installs acme.sh
2. Sets Let's Encrypt as default CA
3. Registers your email with Let's Encrypt
4. Issues certificate for your domain
5. Installs certificate to specified location

### Method 2: certbot

- Official Let's Encrypt client
- Well-established and widely used
- Good community support

**What it does:**

1. Installs certbot package (if not already installed)
2. Issues certificate for your domain
3. Copies certificates to specified location

## Output Files

After successful certificate creation, you'll get:

- `yourdomain.com.crt` - Certificate file
- `yourdomain.com.key` - Private key file

## Marzneshin Configuration

After getting your certificates, update your Marzneshin configuration:

1. **Edit the environment file:**

   ```bash
   nano /etc/opt/marzneshin/.env
   ```

2. **Add/update these lines:**

   ```env
   # For default path (/var/lib/marzneshin/certs)
   UVICORN_SSL_CERTFILE=/var/lib/marzneshin/certs/yourdomain.com.crt
   UVICORN_SSL_KEYFILE=/var/lib/marzneshin/certs/yourdomain.com.key

   # Or for custom path
   UVICORN_SSL_CERTFILE=/your/custom/path/yourdomain.com.crt
   UVICORN_SSL_KEYFILE=/your/custom/path/yourdomain.com.key
   ```

3. **Restart Marzneshin:**
   ```bash
   marzneshin restart
   ```

## Certificate Management

### List Certificates

The script maintains a registry of all certificates created, showing:

- Domain name
- Method used (acme.sh or certbot)
- Certificate and key file paths
- Creation timestamp
- File existence status

### Remove Certificates

Safely remove certificates and clean up:

- Deletes certificate and key files
- Removes entry from registry
- Confirms before deletion

## File Locations

- **Certificates**: `/var/lib/marzneshin/certs/` (default) or your custom path
- **Script Config**: `~/.ssl-cert-manager/`
- **Email Memory**: `~/.ssl-cert-manager/last_email`
- **Certificate Registry**: `~/.ssl-cert-manager/cert_registry`

## Troubleshooting

### Common Issues

1. **"This script must be run as root"**

   - Solution: Use `sudo ./ssl-cert-manager.sh`

2. **"Invalid domain format"**

   - Solution: Ensure domain format is correct (e.g., `example.com`, not `https://example.com`)

3. **Certificate issuance fails**

   - Ensure domain points to your server's IP
   - Check if port 80 is available
   - Verify no firewall blocking

4. **Permission denied errors**
   - Ensure script is executable: `chmod +x ssl-cert-manager.sh`
   - Run with sudo for system operations

### Port Requirements

- **Port 80**: Required for domain validation (both methods)
- **Port 443**: Required for HTTPS after certificate installation

### Domain Setup

Before running the script, ensure:

1. Your domain's A record points to your server's IP
2. Port 80 is accessible from the internet
3. No other web server is using port 80

## Security Notes

- Always review scripts before running with sudo
- Keep your certificates secure and backed up
- Regularly renew certificates (Let's Encrypt certificates expire every 90 days)
- Monitor certificate expiration dates

## Certificate Renewal

### For acme.sh certificates:

```bash
# Manual renewal
~/.acme.sh/acme.sh --renew -d yourdomain.com

# Auto-renewal is typically set up automatically
```

### For certbot certificates:

```bash
# Manual renewal
certbot renew

# Test auto-renewal
certbot renew --dry-run
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Ensure all requirements are met
3. Open an issue on GitHub with details about your problem

## Acknowledgments

- [acme.sh](https://github.com/acmesh-official/acme.sh) - A pure Unix shell script ACME client
- [Certbot](https://certbot.eff.org/) - Official Let's Encrypt client
- [Marzneshin](https://github.com/Gozargah/Marzneshin) - Unified GUI Censorship Resistant Solution
