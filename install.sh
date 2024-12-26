#!/bin/bash
set -euo pipefail

printf "\033c"
echo "===================================================="
echo "                 ___           ___           ___    "
echo "     ___        /  /\         /__/\         /  /\   "
echo "    /__/|      /  /::\       |  |::\       /  /:/_  "
echo "   |  |:|     /  /:/\:\      |  |:|:\     /  /:/ /\ "
echo "   |  |:|    /  /:/~/::\   __|__|:|\:\   /  /:/ /::\\"
echo " __|__|:|   /__/:/ /:/\:\ /__/::::| \:\ /__/:/ /:/\:\\"
echo "/__/::::\   \  \:\/:/__\/ \  \:\~~\__\/ \  \:\/:/~/:/"
echo "   ~\~~\:\   \  \::/       \  \:\        \  \::/ /:/ "
echo "     \  \:\   \  \:\        \  \:\        \__\/ /:/  "
echo "      \__\/    \  \:\        \  \:\         /__/:/   "
echo "                \__\/         \__\/         \__\/    "
echo "===================================================="
echo "Welcome to YAMS (Yet Another Media Server)"
echo "Installation process should be really quick"
echo "We just need you to answer some questions"
echo "We are going to ask for your sudo password in the end"
echo "To finish the installation of the CLI"
echo "===================================================="
echo ""

# Constants
readonly DEFAULT_INSTALL_DIR="/opt/yams"
readonly DEFAULT_MEDIA_DIR="/srv/media"
readonly SUPPORTED_MEDIA_SERVICES=("jellyfin" "emby" "plex")
readonly DEFAULT_MEDIA_SERVICE="jellyfin"
readonly DEFAULT_VPN_SERVICE="protonvpn"
readonly MEDIA_SUBDIRS=("tv" "movies" "music" "books" "downloads" "blackhole")

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Dependencies
readonly REQUIRED_COMMANDS=("curl" "docker" "docker" "sed" "awk")

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}" >&2
    exit 1
}

log_warning() {
    echo -e "${YELLOW}$1${NC}"
}

log_info() {
    echo "$1"
}

create_and_verify_directory() {
    local dir="$1"
    local dir_type="$2"

    if [ ! -d "$dir" ]; then
        echo "The directory \"$dir\" does not exist. Attempting to create..."
        if mkdir -p "$dir"; then
            log_success "Directory $dir created ✅"
        else
            log_error "Failed to create $dir_type directory at \"$dir\". Check permissions ❌"
        fi
    fi

    if [ ! -w "$dir" ] || [ ! -r "$dir" ]; then
        log_error "Directory \"$dir\" is not writable or readable. Check permissions ❌"
    fi
}

setup_directory_structure() {
    local media_dir="$1"

    create_and_verify_directory "$media_dir" "media"

    for subdir in "${MEDIA_SUBDIRS[@]}"; do
        create_and_verify_directory "$media_dir/$subdir" "media subdirectory"
    done
}

verify_user_permissions() {
    local username="$1"
    local directory="$2"

    if ! id -u "$username" &>/dev/null; then
        log_error "User \"$username\" doesn't exist!"
    fi

    if ! sudo -u "$username" test -w "$directory"; then
        log_error "User \"$username\" doesn't have write permissions to \"$directory\""
    fi
}

check_dependencies() {
    # Check for required commands
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command '$cmd' not found!"
        fi
    done

    # Check Docker
    if command -v docker &> /dev/null; then
        log_success "docker exists ✅"
        if docker compose version &> /dev/null; then
            log_success "docker compose exists ✅"
            return 0
        fi
    fi

    log_warning "⚠️  Docker/Docker Compose not found! ⚠️"
    read -p "Install Docker and Docker Compose? Only works on Debian/Ubuntu (y/N) [Default = n]: " install_docker
    install_docker=${install_docker:-"n"}

    if [ "${install_docker,,}" = "y" ]; then
        bash ./docker.sh
    else
        log_error "Please install Docker and Docker Compose first"
    fi
}

configure_media_service() {
    echo
    echo
    echo
    log_info "Time to choose your media service."
    log_info "Your media service is responsible for serving your files to your network."
    log_info "Supported media services:"
    log_info "- jellyfin (recommended, easier)"
    log_info "- emby"
    log_info "- plex (advanced, always online)"

    read -p "Choose your media service [$DEFAULT_MEDIA_SERVICE]: " media_service
    media_service=${media_service:-$DEFAULT_MEDIA_SERVICE}
    media_service=$(echo "$media_service" | awk '{print tolower($0)}')

    if [[ ! " ${SUPPORTED_MEDIA_SERVICES[@]} " =~ " ${media_service} " ]]; then
        log_error "\"$media_service\" is not supported by YAMS"
    fi

    # Set media service port
    if [ "$media_service" == "plex" ]; then
        media_service_port=32400
    else
        media_service_port=8096
    fi

    echo
    log_success "YAMS will install \"$media_service\" on port \"$media_service_port\""

    # Export for use in other functions
    export media_service media_service_port
}

configure_vpn() {
    echo
    echo
    echo
    log_info "Time to set up the VPN."
    log_info "Supported VPN providers: https://yams.media/advanced/vpn"

    read -p "Configure VPN? (Y/n) [Default = y]: " setup_vpn
    setup_vpn=${setup_vpn:-"y"}

    if [ "${setup_vpn,,}" != "y" ]; then
        export setup_vpn="n"
        return 0
    fi

    read -p "VPN service? (with spaces) [$DEFAULT_VPN_SERVICE]: " vpn_service
    vpn_service=${vpn_service:-$DEFAULT_VPN_SERVICE}

    echo
    log_info "Please check $vpn_service's documentation for specific configuration:"
    log_info "https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/${vpn_service// /-}.md"

    read -p "VPN username (without spaces): " vpn_user
    [ -z "$vpn_user" ] && log_error "VPN username cannot be empty"

    # Use hidden input for password
    unset vpn_password
    charcount=0
    prompt="VPN password (if using mullvad, enter username again): "
    while IFS= read -p "$prompt" -r -s -n 1 char; do
        if [[ $char == $'\0' ]]; then
            break
        fi
        if [[ $char == $'\177' ]]; then
            if [ $charcount -gt 0 ]; then
                charcount=$((charcount-1))
                prompt=$'\b \b'
                vpn_password="${vpn_password%?}"
            else
                prompt=''
            fi
        else
            charcount=$((charcount+1))
            prompt='*'
            vpn_password+="$char"
        fi
    done
    echo

    [ -z "$vpn_password" ] && log_error "VPN password cannot be empty"

    # Export for use in other functions
    export vpn_service vpn_user vpn_password setup_vpn
}

running_services_location() {
    local host_ip
    host_ip=$(hostname -I | awk '{ print $1 }')

    local -A services=(
        ["qBittorrent"]="8081"
        ["SABnzbd"]="8080"
        ["Radarr"]="7878"
        ["Sonarr"]="8989"
        ["Lidarr"]="8686"
        ["Readarr"]="8787"
        ["Prowlarr"]="9696"
        ["Bazarr"]="6767"
        ["$media_service"]="$media_service_port"
        ["Portainer"]="9000"
    )

    echo -e "Service URLs:"
    for service in "${!services[@]}"; do
        echo "$service: http://$host_ip:${services[$service]}/"
    done
}

get_user_info() {
    read -p "User to own the media server files? [$USER]: " username
    username=${username:-$USER}

    if id -u "$username" &>/dev/null; then
        puid=$(id -u "$username")
        pgid=$(id -g "$username")
    else
        log_error "User \"$username\" doesn't exist!"
    fi

    export username puid pgid
}

get_installation_paths() {
    read -p "Installation directory? [$DEFAULT_INSTALL_DIR]: " install_directory
    install_directory=${install_directory:-$DEFAULT_INSTALL_DIR}
    create_and_verify_directory "$install_directory" "installation"

    read -p "Media directory? [$DEFAULT_MEDIA_DIR]: " media_directory
    media_directory=${media_directory:-$DEFAULT_MEDIA_DIR}

    read -p "Are you sure your media directory is \"$media_directory\"? (y/N) [Default = n]: " media_directory_correct
    media_directory_correct=${media_directory_correct:-"n"}

    if [ "${media_directory_correct,,}" != "y" ]; then
        log_error "Media directory is not correct. Please fix it and run the script again ❌"
    fi

    setup_directory_structure "$media_directory"
    verify_user_permissions "$username" "$media_directory"

    export install_directory media_directory
}

copy_configuration_files() {
    local -A files=(
        ["docker-compose.example.yaml"]="docker-compose.yaml"
        [".env.example"]=".env"
        ["docker-compose.custom.yaml"]="docker-compose.custom.yaml"
    )

    for src in "${!files[@]}"; do
        local dest="$install_directory/${files[$src]}"
        echo
        log_info "Copying $src to $dest..."

        if cp "$src" "$dest"; then
            log_success "$src copied successfully ✅"
        else
            log_error "Failed to copy $src to $dest. Check permissions ❌"
        fi
    done
}

update_configuration_files() {
    local filename="$install_directory/docker-compose.yaml"
    local env_file="$install_directory/.env"
    local yams_script="yams"

    # Update .env file
    log_info "Updating environment configuration..."
    sed -i -e "s|<your_PUID>|$puid|g" \
           -e "s|<your_PGID>|$pgid|g" \
           -e "s|<media_directory>|$media_directory|g" \
           -e "s|<media_service>|$media_service|g" \
           -e "s|<install_directory>|$install_directory|g" \
           -e "s|vpn_enabled|$setup_vpn|g" "$env_file" || \
        log_error "Failed to update .env file"

    # Update VPN configuration in .env file
if [ "${setup_vpn,,}" == "y" ]; then
sed -i -e "s|^VPN_ENABLED=.*|VPN_ENABLED=y|" \
        -e "s|^VPN_SERVICE=.*|VPN_SERVICE=$vpn_service|" \
        -e "s|^VPN_USER=.*|VPN_USER=$vpn_user|" \
        -e "s|^VPN_PASSWORD=.*|VPN_PASSWORD=$vpn_password|" "$env_file" || \
        log_error "Failed to update VPN configuration in .env"
else
sed -i -e "s|^VPN_ENABLED=.*|VPN_ENABLED=n|" "$env_file" || \
        log_error "Failed to update VPN configuration in .env"
fi

    # Update docker-compose.yaml
    log_info "Updating docker-compose configuration..."
    sed -i "s|<media_service>|$media_service|g" "$filename" || \
        log_error "Failed to update docker-compose.yaml"

    # Configure Plex-specific settings
    if [ "$media_service" == "plex" ]; then
        log_info "Configuring Plex-specific settings..."
        sed -i -e 's|#network_mode: host # plex|network_mode: host # plex|g' \
               -e 's|ports: # plex|#ports: # plex|g' \
               -e 's|- 8096:8096 # plex|#- 8096:8096 # plex|g' "$filename" || \
            log_error "Failed to configure Plex settings"
    fi

    # Configure VPN settings if enabled
    if [ "${setup_vpn,,}" == "y" ]; then
        log_info "Configuring VPN settings..."
        sed -i -e "s|vpn_service|$vpn_service|g" \
               -e "s|vpn_user|$vpn_user|g" \
               -e "s|vpn_password|$vpn_password|g" \
               -e 's|#network_mode: "service:gluetun"|network_mode: "service:gluetun"|g' \
               -e 's|ports: # qbittorrent|#ports: # qbittorrent|g' \
               -e 's|ports: # sabnzbd|#ports: # sabnzbd|g' \
               -e 's|- 8081:8081 # qbittorrent|#- 8081:8081 # qbittorrent|g' \
               -e 's|- 8080:8080 # sabnzbd|#- 8080:8080 # sabnzbd|g' \
               -e 's|#- 8080:8080/tcp # gluetun|- 8080:8080/tcp # gluetun|g' \
               -e 's|#- 8081:8081/tcp # gluetun|- 8081:8081/tcp # gluetun|g' "$filename" || \
            log_error "Failed to configure VPN settings"
    fi

    # Update YAMS CLI script
    log_info "Updating YAMS CLI configuration..."
    sed -i -e "s|<filename>|$filename|g" \
           -e "s|<custom_file_filename>|$install_directory/docker-compose.custom.yaml|g" \
           -e "s|<install_directory>|$install_directory|g" "$yams_script" || \
        log_error "Failed to update YAMS CLI script"
}

install_cli() {
    echo
    log_info "Installing YAMS CLI..."
    if sudo cp yams /usr/local/bin/yams && sudo chmod +x /usr/local/bin/yams; then
        log_success "YAMS CLI installed successfully ✅"
    else
        log_error "Failed to install YAMS CLI. Check permissions ❌"
    fi
}

set_permissions() {
    local dirs=("$media_directory" "$install_directory" "$install_directory/config")

    for dir in "${dirs[@]}"; do
        log_info "Setting permissions for $dir..."
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir" || log_error "Failed to create directory $dir"
        fi

        if sudo chown -R "$puid:$pgid" "$dir"; then
            log_success "Permissions set successfully for $dir ✅"
        else
            log_error "Failed to set permissions for $dir ❌"
        fi
    done
}

# Prevent running as root
if [[ "$EUID" = 0 ]]; then
    log_error "YAMS must run without sudo! Please run with regular permissions"
fi

# Check all dependencies
log_info "Checking prerequisites..."
check_dependencies

# Get user information
get_user_info

# Get installation paths
get_installation_paths

# Configure services
configure_media_service
configure_vpn

log_info "Configuring the docker-compose file for user \"$username\" in \"$install_directory\"..."

# Copy and update configuration files
copy_configuration_files
update_configuration_files

log_success "Everything installed correctly! 🎉"

# Start services
log_info "Starting YAMS services..."
log_info "This may take a while..."

if ! docker compose -f "$install_directory/docker-compose.yaml" up -d; then
    log_error "Failed to start YAMS services"
fi

# Install CLI and set permissions
echo
log_info "We need your sudo password to install the YAMS CLI and configure permissions..."
install_cli
set_permissions

printf "\033c"

cat << "EOF"
========================================================
     _____          ___           ___           ___
    /  /::\        /  /\         /__/\         /  /\
   /  /:/\:\      /  /::\        \  \:\       /  /:/_
  /  /:/  \:\    /  /:/\:\        \  \:\     /  /:/ /\
 /__/:/ \__\:|  /  /:/  \:\   _____\__\:\   /  /:/ /:/_
 \  \:\ /  /:/ /__/:/ \__\:\ /__/::::::::\ /__/:/ /:/ /\\
  \  \:\  /:/  \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\/:/ /:/
   \  \:\/:/    \  \:\  /:/   \  \:\  ~~~   \  \::/ /:/
    \  \::/      \  \:\/:/     \  \:\        \  \:\/:/
     \__\/        \  \::/       \  \:\        \  \::/
                   \__\/         \__\/         \__\/
========================================================
EOF

log_success "All done!✅  Enjoy YAMS!"
log_info "You can check the installation in $install_directory"
log_info "========================================================"
log_info "Everything should be running now! To check everything running, go to:"
echo

running_services_location

echo
log_info "You might need to wait for a couple of minutes while everything gets up and running"
echo
log_info "All the service locations are also saved in ~/yams_services.txt"
running_services_location > ~/yams_services.txt

log_info "========================================================"
echo
log_info "To configure YAMS, check the documentation at"
log_info "https://yams.media/config"
echo
log_info "========================================================"

exit 0
