# Claude Code Development Notes

This file contains important reminders and guidelines for developing and maintaining the SSL Certificate Manager script.

## Version Management

**🚨 CRITICAL REMINDER: Always update the version number when making changes!**

### Version Location
The version number is stored in `ssl-cert-manager.sh` at line 10:
```bash
SCRIPT_VERSION="1.0.0"
```

### Version Update Rules

**MUST UPDATE VERSION when:**
- ✅ Adding new features
- ✅ Fixing bugs 
- ✅ Modifying functionality
- ✅ Changing user interface
- ✅ Updating dependencies
- ✅ Improving error handling
- ✅ Any code changes that affect script behavior

**Version numbering scheme (Semantic Versioning):**
- `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- **MAJOR**: Breaking changes or major rewrites
- **MINOR**: New features, significant improvements
- **PATCH**: Bug fixes, small improvements

### Current Version History
- `1.0.0` - Initial release with all core features
  - Interactive SSL certificate management
  - Support for acme.sh and certbot
  - Path history management
  - Email memory
  - Certificate registry
  - Automatic dependency installation

## Development Guidelines

### File Structure
```
cert-scripts/
├── ssl-cert-manager.sh    # Main script
├── README.md             # User documentation
├── CHANGELOG.md          # Version history and changes
├── CLAUDE.md             # This file - development notes
└── .gitignore           # Git ignore file (if needed)
```

### Key Features to Maintain
1. **Interactive Interface**: Keep the script user-friendly
2. **Path History**: Maintain the recent paths functionality
3. **Email Memory**: Remember last used email
4. **Certificate Registry**: Track all created certificates
5. **Domain Validation**: Support all valid domain formats including subdomains
6. **Error Handling**: Comprehensive error checking and user feedback
7. **Version Display**: Show version in header and via --version flag

### Testing Checklist
Before releasing any version:
- [ ] Test acme.sh certificate creation
- [ ] Test certbot certificate creation
- [ ] Test domain validation with various formats
- [ ] Test path selection and history
- [ ] Test email memory functionality
- [ ] Test certificate listing and removal
- [ ] Test dependency installation
- [ ] Test --version and --help flags
- [ ] Test on fresh Ubuntu/Debian system

### Important Notes

#### Domain Validation
- Must support subdomains (e.g., `api.example.com`, `mzpanel.bime.info`)
- Must support multi-level domains (e.g., `sub.domain.example.co.uk`)
- Current validation logic is in `get_domain()` function

#### Interactive vs Non-Interactive
- Script requires interactive terminal for user input
- Avoid `curl | bash` installation method
- Recommend download-first-then-run approach

#### Security Considerations
- Always validate user input
- Check file permissions when creating certificates
- Ensure paths are absolute to prevent directory traversal
- Don't log sensitive information

### Common Maintenance Tasks

#### Adding New Features
1. Update `SCRIPT_VERSION` 
2. Test thoroughly
3. Update CHANGELOG.md with new features
4. Update README.md if user-facing changes
5. Update help text if adding command line options

#### Bug Fixes
1. Update `SCRIPT_VERSION` (increment PATCH)
2. Test the specific bug scenario
3. Update CHANGELOG.md with fixes
4. Ensure fix doesn't break existing functionality

#### Dependency Updates
1. Update `SCRIPT_VERSION`
2. Test on clean system
3. Update CHANGELOG.md with dependency changes
4. Update README.md if new requirements

### Script Configuration Locations
- Config directory: `~/.ssl-cert-manager/`
- Email memory: `~/.ssl-cert-manager/last_email`
- Path history: `~/.ssl-cert-manager/path_history`
- Certificate registry: `~/.ssl-cert-manager/cert_registry`

### External Dependencies
- `curl` - For downloading acme.sh and certificates
- `wget` - For file downloads
- `socat` - Required for acme.sh standalone mode
- `cron` - For automatic certificate renewals
- `certbot` - Installed only when using certbot method

### GitHub Repository
- Repository: https://github.com/raminrez/cert-scripts
- Main branch: `main`
- Always test changes before pushing to main

---

## Quick Reference

### Update Version Command
```bash
# Edit line 10 in ssl-cert-manager.sh
SCRIPT_VERSION="X.Y.Z"
```

### Test Script
```bash
# Download and test
curl -O https://raw.githubusercontent.com/raminrez/cert-scripts/main/ssl-cert-manager.sh
chmod +x ssl-cert-manager.sh
sudo ./ssl-cert-manager.sh --version
sudo ./ssl-cert-manager.sh --help
```

### Version Check
```bash
./ssl-cert-manager.sh --version
```

---

**Remember: Every change = Version bump! 🚀**