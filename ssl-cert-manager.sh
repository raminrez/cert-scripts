#!/bin/bash

# SSL Certificate Manager for Marzneshin
# Interactive script to manage SSL certificates using acme.sh or certbot
# Version: 1.0.1

set -e

# Script Information
SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="SSL Certificate Manager"
SCRIPT_AUTHOR="Ramin Rezaei"
SCRIPT_REPO="https://github.com/raminrez/cert-scripts"

# Configuration
CONFIG_DIR="$HOME/.ssl-cert-manager"
EMAIL_FILE="$CONFIG_DIR/last_email"
CERT_REGISTRY="$CONFIG_DIR/cert_registry"
PATH_HISTORY="$CONFIG_DIR/path_history"
DEFAULT_OUTPUT_PATH="/var/lib/marzneshin/certs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create config directory
mkdir -p "$CONFIG_DIR"

# Dependency Management
check_and_install_dependencies() {
    print_header
    echo -e "${BLUE}🔧 Checking and Installing Dependencies${NC}"
    echo "════════════════════════════════════════════════════"
    
    print_info "Updating package lists..."
    if ! apt-get update >/dev/null 2>&1; then
        print_error "Failed to update package lists"
        return 1
    fi
    print_success "Package lists updated"
    
    # Check and install essential tools
    local dependencies=("curl" "wget" "socat" "cron")
    local missing_deps=()
    
    print_info "Checking for required dependencies..."
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
            print_warning "Missing: $dep"
        else
            print_success "Found: $dep"
        fi
    done
    
    # Install missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_info "Installing missing dependencies: ${missing_deps[*]}"
        if apt-get install -y "${missing_deps[@]}" >/dev/null 2>&1; then
            print_success "All dependencies installed successfully"
        else
            print_error "Failed to install some dependencies"
            return 1
        fi
    else
        print_success "All dependencies are already installed"
    fi
    
    # Check if ports 80 and 443 are available
    print_info "Checking port availability..."
    
    if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
        print_warning "Port 80 is already in use - this might cause issues during certificate validation"
        print_info "You may need to temporarily stop the service using port 80"
    else
        print_success "Port 80 is available"
    fi
    
    if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
        print_info "Port 443 is in use (this is normal if you have a web server)"
    else
        print_success "Port 443 is available"
    fi
    
    echo
    print_success "Dependency check completed!"
    
    # Brief pause to let user see the completion message
    sleep 1
}

# Helper Functions
print_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              SSL Certificate Manager             ║${NC}"
    echo -e "${BLUE}║                  for Marzneshin                  ║${NC}"
    echo -e "${BLUE}║                   v${SCRIPT_VERSION}                       ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Email management
get_email() {
    local last_email=""
    if [[ -f "$EMAIL_FILE" ]]; then
        last_email=$(cat "$EMAIL_FILE")
    fi
    
    echo
    if [[ -n "$last_email" ]]; then
        echo -e "Last used email: ${YELLOW}$last_email${NC}"
        read -p "Press Enter to use the same email, or type a new one: " new_email
        if [[ -z "$new_email" ]]; then
            email="$last_email"
        else
            email="$new_email"
        fi
    else
        read -p "Enter your email address: " email
    fi
    
    # Validate email
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid email format"
        return 1
    fi
    
    echo "$email" > "$EMAIL_FILE"
    print_success "Email saved: $email"
}

# Domain validation
get_domain() {
    echo
    read -p "Enter your domain name (e.g., example.com): " domain
    
    # Basic domain validation - supports subdomains and multiple levels
    # Check if domain contains at least one dot and valid characters
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]] || [[ ! "$domain" =~ \. ]] || [[ "$domain" =~ ^\.|\.$|\.\.| ]] ; then
        print_error "Invalid domain format"
        return 1
    fi
    
    # Check if TLD has at least 2 characters
    local tld="${domain##*.}"
    if [[ ${#tld} -lt 2 ]]; then
        print_error "Invalid domain format - TLD too short"
        return 1
    fi
    
    print_success "Domain: $domain"
}

# Path history management
add_to_path_history() {
    local new_path="$1"
    
    # Remove path if it already exists to avoid duplicates
    if [[ -f "$PATH_HISTORY" ]]; then
        grep -v "^$new_path$" "$PATH_HISTORY" > "${PATH_HISTORY}.tmp" 2>/dev/null || true
        mv "${PATH_HISTORY}.tmp" "$PATH_HISTORY" 2>/dev/null || true
    fi
    
    # Add new path to the beginning
    echo "$new_path" >> "$PATH_HISTORY"
    
    # Keep only last 10 paths
    if [[ -f "$PATH_HISTORY" ]]; then
        tail -10 "$PATH_HISTORY" > "${PATH_HISTORY}.tmp"
        mv "${PATH_HISTORY}.tmp" "$PATH_HISTORY"
    fi
}

get_last_used_path() {
    if [[ -f "$PATH_HISTORY" ]] && [[ -s "$PATH_HISTORY" ]]; then
        tail -1 "$PATH_HISTORY"
    else
        echo "$DEFAULT_OUTPUT_PATH"
    fi
}

show_path_history() {
    if [[ ! -f "$PATH_HISTORY" ]] || [[ ! -s "$PATH_HISTORY" ]]; then
        return 1
    fi
    
    echo -e "${BLUE}📁 Recent Paths:${NC}"
    local count=1
    
    # Show paths in reverse order (most recent first)
    tac "$PATH_HISTORY" 2>/dev/null | while read -r path; do
        if [[ -n "$path" ]]; then
            echo -e "${YELLOW}[$count]${NC} $path"
            ((count++))
            if [[ $count -gt 10 ]]; then
                break
            fi
        fi
    done
    echo
}

# Output path selection
get_output_path() {
    local last_path
    last_path=$(get_last_used_path)
    
    echo
    echo -e "Last used path: ${YELLOW}$last_path${NC}"
    
    # Show path history if available
    if show_path_history; then
        echo "Options:"
        echo "• Press Enter to use the last used path"
        echo "• Type a number (1-10) to select from recent paths"
        echo "• Type a custom path"
        echo
        read -p "Your choice: " user_input
    else
        echo -e "Default path: ${YELLOW}$DEFAULT_OUTPUT_PATH${NC}"
        read -p "Press Enter for default, or type custom path: " user_input
    fi
    
    # Process user input
    if [[ -z "$user_input" ]]; then
        # Use last used path
        output_path="$last_path"
    elif [[ "$user_input" =~ ^[0-9]+$ ]] && [[ "$user_input" -ge 1 ]] && [[ "$user_input" -le 10 ]]; then
        # User selected a number from history
        if [[ -f "$PATH_HISTORY" ]]; then
            output_path=$(tac "$PATH_HISTORY" 2>/dev/null | sed -n "${user_input}p")
            if [[ -z "$output_path" ]]; then
                print_error "Invalid selection. Using last used path."
                output_path="$last_path"
            fi
        else
            output_path="$last_path"
        fi
    else
        # User entered custom path
        output_path="$user_input"
    fi
    
    # Validate and create directory
    if [[ ! "$output_path" =~ ^/.* ]]; then
        print_warning "Path should be absolute (starting with /). Converting to absolute path."
        output_path="$(pwd)/$output_path"
    fi
    
    # Create directory if it doesn't exist
    if mkdir -p "$output_path" 2>/dev/null; then
        print_success "Output path: $output_path"
        # Add to history
        add_to_path_history "$output_path"
    else
        print_error "Failed to create directory: $output_path"
        return 1
    fi
}

# Certificate registry management
add_to_registry() {
    local domain="$1"
    local method="$2"
    local cert_path="$3"
    local key_path="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$domain|$method|$cert_path|$key_path|$timestamp" >> "$CERT_REGISTRY"
}

list_certificates() {
    print_header
    echo -e "${BLUE}📜 Certificate Registry${NC}"
    echo "════════════════════════════════════════════════════"
    
    if [[ ! -f "$CERT_REGISTRY" ]] || [[ ! -s "$CERT_REGISTRY" ]]; then
        print_warning "No certificates found in registry"
        return
    fi
    
    local count=1
    while IFS='|' read -r domain method cert_path key_path timestamp; do
        echo -e "${YELLOW}[$count]${NC} Domain: ${GREEN}$domain${NC}"
        echo "    Method: $method"
        echo "    Certificate: $cert_path"
        echo "    Private Key: $key_path"
        echo "    Created: $timestamp"
        
        # Check if files exist
        if [[ -f "$cert_path" ]] && [[ -f "$key_path" ]]; then
            echo -e "    Status: ${GREEN}Files exist${NC}"
        else
            echo -e "    Status: ${RED}Files missing${NC}"
        fi
        echo
        ((count++))
    done < "$CERT_REGISTRY"
}

remove_certificate() {
    list_certificates
    
    if [[ ! -f "$CERT_REGISTRY" ]] || [[ ! -s "$CERT_REGISTRY" ]]; then
        read -p "Press Enter to continue..."
        return
    fi
    
    echo
    read -p "Enter certificate number to remove (or 'q' to quit): " choice
    
    if [[ "$choice" == "q" ]]; then
        return
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        print_error "Invalid selection"
        read -p "Press Enter to continue..."
        return
    fi
    
    local line=$(sed -n "${choice}p" "$CERT_REGISTRY")
    if [[ -z "$line" ]]; then
        print_error "Invalid certificate number"
        read -p "Press Enter to continue..."
        return
    fi
    
    IFS='|' read -r domain method cert_path key_path timestamp <<< "$line"
    
    echo
    echo -e "Selected certificate for domain: ${YELLOW}$domain${NC}"
    echo "Certificate path: $cert_path"
    echo "Private key path: $key_path"
    echo
    
    read -p "Are you sure you want to remove this certificate? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove files
        [[ -f "$cert_path" ]] && rm -f "$cert_path" && print_success "Removed: $cert_path"
        [[ -f "$key_path" ]] && rm -f "$key_path" && print_success "Removed: $key_path"
        
        # Remove from registry
        sed -i "${choice}d" "$CERT_REGISTRY"
        print_success "Removed from registry"
    else
        print_info "Cancelled"
    fi
    
    read -p "Press Enter to continue..."
}

# ACME.sh method
install_acme_certificate() {
    print_header
    echo -e "${BLUE}🔐 Installing SSL Certificate using acme.sh${NC}"
    echo "════════════════════════════════════════════════════"
    
    get_email || return 1
    get_domain || return 1
    get_output_path || return 1
    
    local cert_file="$output_path/${domain}.crt"
    local key_file="$output_path/${domain}.key"
    
    echo
    print_info "Starting certificate installation..."
    
    # Step 1: Install acme.sh
    print_info "Installing acme.sh..."
    curl https://get.acme.sh | sh
    
    # Step 2: Set default CA
    print_info "Setting Let's Encrypt as default CA..."
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    
    # Step 3: Register account
    print_info "Registering account with email: $email"
    ~/.acme.sh/acme.sh --register-account -m "$email"
    
    # Step 4: Issue certificate
    print_info "Issuing certificate for domain: $domain"
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone
    
    # Step 5: Install certificate
    print_info "Installing certificate to: $output_path"
    ~/.acme.sh/acme.sh --installcert -d "$domain" --key-file "$key_file" --fullchain-file "$cert_file"
    
    # Add to registry
    add_to_registry "$domain" "acme.sh" "$cert_file" "$key_file"
    
    print_success "Certificate successfully installed!"
    echo
    echo -e "Certificate file: ${GREEN}$cert_file${NC}"
    echo -e "Private key file: ${GREEN}$key_file${NC}"
    echo
    print_info "Add these paths to your Marzneshin configuration:"
    echo "fullchain: $cert_file"
    echo "privatekey: $key_file"
    echo
    print_warning "Don't forget to restart Marzneshin: marzneshin restart"
    
    read -p "Press Enter to continue..."
}

# Certbot method
install_certbot_certificate() {
    print_header
    echo -e "${BLUE}🔐 Installing SSL Certificate using certbot${NC}"
    echo "════════════════════════════════════════════════════"
    
    get_domain || return 1
    get_output_path || return 1
    
    local cert_file="$output_path/${domain}.crt"
    local key_file="$output_path/${domain}.key"
    
    echo
    print_info "Starting certificate installation..."
    
    # Step 1: Install certbot (if not already installed)
    if ! command -v certbot >/dev/null 2>&1; then
        print_info "Installing certbot..."
        apt-get install certbot -y
    else
        print_success "Certbot already installed"
    fi
    
    # Step 2: Get certificate
    print_info "Getting certificate for domain: $domain"
    certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$domain"
    
    # Step 3: Copy certificates
    print_info "Copying certificates to: $output_path"
    cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$cert_file"
    cp "/etc/letsencrypt/live/$domain/privkey.pem" "$key_file"
    
    # Add to registry
    add_to_registry "$domain" "certbot" "$cert_file" "$key_file"
    
    print_success "Certificate successfully installed!"
    echo
    echo -e "Certificate file: ${GREEN}$cert_file${NC}"
    echo -e "Private key file: ${GREEN}$key_file${NC}"
    echo
    print_info "Add these paths to your Marzneshin configuration:"
    echo "fullchain: $cert_file"
    echo "privatekey: $key_file"
    echo
    print_warning "Don't forget to restart Marzneshin: marzneshin restart"
    
    read -p "Press Enter to continue..."
}

# Main menu
show_main_menu() {
    print_header
    echo -e "${BLUE}📋 Main Menu${NC}"
    echo "════════════════════════════════════════════════════"
    echo "1. Install SSL Certificate using acme.sh"
    echo "2. Install SSL Certificate using certbot"
    echo "3. List existing certificates"
    echo "4. Remove certificate"
    echo "5. Exit"
    echo
}

# Show version information
show_version() {
    echo -e "${BLUE}$SCRIPT_NAME${NC}"
    echo -e "Version: ${GREEN}$SCRIPT_VERSION${NC}"
    echo -e "Author: $SCRIPT_AUTHOR"
    echo -e "Repository: $SCRIPT_REPO"
    echo
}

# Show help information
show_help() {
    show_version
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -v, --version    Show version information"
    echo "  -h, --help       Show this help message"
    echo "  (no options)     Run interactive mode"
    echo
    echo "This script helps you manage SSL certificates for Marzneshin using"
    echo "either acme.sh or certbot methods."
}

main() {
    # Handle command line arguments
    case "${1:-}" in
        -v|--version)
            show_version
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        "")
            # No arguments, continue with interactive mode
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    
    # Check and install dependencies on first run
    check_and_install_dependencies
    
    while true; do
        show_main_menu
        read -p "Select an option (1-5): " choice
        
        case $choice in
            1)
                install_acme_certificate
                ;;
            2)
                install_certbot_certificate
                ;;
            3)
                list_certificates
                read -p "Press Enter to continue..."
                ;;
            4)
                remove_certificate
                ;;
            5)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-5."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"