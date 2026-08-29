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
echo "to finish the installation of the CLI"
echo "===================================================="
echo ""

# Constants
readonly DEFAULT_INSTALL_DIR="/opt/yams"
readonly DEFAULT_MEDIA_DIR="/srv/media"
readonly SUPPORTED_MEDIA_SERVICES=("jellyfin" "emby" "plex")
readonly DEFAULT_MEDIA_SERVICE="jellyfin"
readonly DEFAULT_VPN_SERVICE="protonvpn"
readonly MEDIA_SUBDIRS=("tvshows" "movies" "music" "books" "downloads/usenet/complete" "downloads/usenet/incomplete" "downloads/torrents" "blackhole")
# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Dependencies
readonly REQUIRED_COMMANDS=("curl" "sed" "awk")
readonly REPO_RAW_URL="https://raw.githubusercontent.com/rogsme/yams/v4/src"

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

confirm_configuration_overwrite() {
    local install_dir="$1"
    local file

    for file in .env docker-compose.yaml docker-compose.custom.yaml yams; do
        if [ -e "$install_dir/$file" ]; then
            log_warning "Existing YAMS configuration found in $install_dir."
            read -p "Overwrite the existing configuration? (y/N) [Default = n]: " overwrite_configuration
            overwrite_configuration=${overwrite_configuration:-"n"}
            [ "${overwrite_configuration,,}" = "y" ] || \
                log_error "Installation cancelled without changing the existing configuration"
            return
        fi
    done
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
    local missing_packages=()

    # Check for required commands and collect missing ones
    for pkg in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        else
            log_success "$pkg exists ✅"
        fi
    done

    # If there are missing packages, offer to install them
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_warning "Missing required packages: ${missing_packages[*]}"
        read -p "Would you like to install the missing packages? (y/N) [Default = n]: " install_deps
        install_deps=${install_deps:-"n"}

        if [ "${install_deps,,}" = "y" ]; then
            echo "Installing missing packages..."
            if ! (sudo apt update && sudo apt install -y "${missing_packages[@]}"); then
                log_error "Failed to install missing packages. Please install them manually: ${missing_packages[*]}"
            fi

            for pkg in "${missing_packages[@]}"; do
                if ! command -v "$pkg" &> /dev/null; then
                    log_error "Package installation completed, but required command \"$pkg\" is still unavailable. Please install it manually."
                fi
            done

            log_success "Successfully installed missing packages ✅"
        else
            log_error "Please install the required packages manually: ${missing_packages[*]}"
        fi
    fi

    # Check Docker and Docker Compose
    if command -v docker &> /dev/null; then
        # Check if Docker is installed via snap
        if [[ $(which docker) == "/snap/bin/docker" ]]; then
            log_error "Docker is installed via snap. YAMS requires the official Docker installation from docker.com. Please remove snap Docker and install Docker from https://docs.docker.com/engine/install/ or install docker using YAMS"
        fi
        log_success "docker exists ✅"
    fi

    if docker compose version &> /dev/null; then
        log_success "docker compose exists ✅"

        # Explicitly check and log docker permissions
        if docker ps &> /dev/null; then
            log_success "docker permissions are correct ✅"
            return 0
        else
            log_warning "docker permissions are inactive ❌"

            # If they are missing from the system database entirely, add them
            if ! groups "$USER" | grep -qw docker; then
                log_info "Adding $USER to the docker group..."
                sudo usermod -aG docker "$USER"
                log_success "Successfully added $USER to the docker group ✅"
            fi

            echo
            log_info "===================================================="
            log_info "We need to refresh your terminal session to apply your new Docker permissions."
            log_info "Please run the following command:"
            echo
            log_warning "newgrp docker"
            echo
            log_info "After running that command, run this installation script again!"
            log_info "===================================================="
            exit 1
        fi
    fi

    log_warning "⚠️  Docker/Docker Compose not found! ⚠️"
    read -p "Install Docker and Docker Compose? (y/N) [Default = n]: " install_docker
    install_docker=${install_docker:-"n"}

    if [ "${install_docker,,}" = "y" ]; then
        log_info "Downloading and running the official Docker installation script (give it some time!)..."
        curl -fsSL https://get.docker.com -o get-docker.sh

        # run the script silently, but save the output to a log file
        if sudo sh get-docker.sh > /tmp/yams_docker_install.log 2>&1; then
            rm get-docker.sh
            log_info "Adding $USER to the docker group..."
            sudo usermod -aG docker "$USER"
            log_success "Docker installed successfully! ✅"
        else
            # if the script fails, tell the user the logfile
            log_error "Docker installation failed! Please check /tmp/yams_docker_install.log for details."
            rm get-docker.sh
            exit 1
        fi

        echo
        log_info "===================================================="
        log_info "We need to refresh your terminal session to apply your new Docker permissions."
        log_info "Please run the following command:"
        echo
        log_warning "newgrp docker"
        echo
        log_info "After running that command, simply run this installation script again!"
        log_info "===================================================="
        exit 1
    else
        log_error "Please install Docker and Docker Compose first, then rerun the script."
    fi
}

configure_media_service() {
    echo
    echo
    echo
    log_info "Time to choose your media service."
    log_info "Your media service is responsible for serving your files to your network."
    log_info "Supported media services:"
    log_info "- jellyfin (recommended)"
    log_info "- emby"
    log_info "- plex"

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
    log_info "Supported VPN providers: https://yams.media/docs/advanced/concept-explanations/vpn"

    read -p "Configure VPN? (Y/n) [Default = y]: " setup_vpn
    setup_vpn=${setup_vpn:-"y"}

    is_protonvpn_free_tier="n"
    enable_port_forwarding="n"

    if [ "${setup_vpn,,}" != "y" ]; then
        export setup_vpn="n"
        export enable_port_forwarding="n"
        export is_protonvpn_free_tier="n"
        return 0
    fi

    read -p "VPN service? (with spaces) [$DEFAULT_VPN_SERVICE]: " vpn_service
    vpn_service=${vpn_service:-$DEFAULT_VPN_SERVICE}
    vpn_service=$(echo "$vpn_service" | awk '{print tolower($0)}')

    local default_vpn_type="openvpn"
    if [ "$vpn_service" = "mullvad" ]; then
        default_vpn_type="wireguard"
    fi

    echo
    log_info "VPN type selection:"
    if [ "$vpn_service" = "mullvad" ]; then
        log_info "  openvpn:  Unsupported by Mullvad."
        log_info "  wireguard: Required for Mullvad."
    else
        log_info "  openvpn:  Default. Works with most providers."
        log_warning "  wireguard: Only available for some providers. Only pick if you have your WireGuard credentials ready."
    fi
    read -p "VPN type? (openvpn/wireguard) [Default = $default_vpn_type]: " vpn_type
    vpn_type=${vpn_type:-"$default_vpn_type"}
    vpn_type=$(echo "$vpn_type" | awk '{print tolower($0)}')

    if [ "$vpn_type" != "openvpn" ] && [ "$vpn_type" != "wireguard" ]; then
        log_error "Invalid VPN type. Choose \"openvpn\" or \"wireguard\""
    fi

    if [ "$vpn_service" = "mullvad" ] && [ "$vpn_type" != "wireguard" ]; then
        log_error "Mullvad requires WireGuard. Choose \"wireguard\"."
    fi

    wg_private_key=""
    wg_addresses=""
    wg_preshared_key=""

# Clear screen and show dramatic warning
    printf "\033c"

    cat << "EOF"


██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗
██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝
██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║
╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝
 ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝


EOF
    log_warning "READ THIS EXTREMELY CAREFULLY"
    log_warning "YOU MUST READ YOUR VPN DOCUMENTATION!"
    echo
    log_info "Most VPN setup failures happen because users don't read the documentation"
    log_info "for their specific VPN provider. Each VPN has different requirements!"
    echo
    log_warning "YOUR VPN DOCUMENTATION IS HERE:"
    echo "https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/${vpn_service// /-}.md"
    echo

    if [ "$vpn_service" = "protonvpn" ]; then
       log_warning "DO NOT USE YOUR PROTON ACCOUNT USERNAME AND PASSWORD. REFER TO THE DOCUMENTATION ABOVE TO OBTAIN THE CORRECT VPN USERNAME AND PASSWORD."
       echo

       read -p "Are you using a free ProtonVPN account? (y/N) [Default = n]: " reply
       is_protonvpn_free_tier="${reply:-n}"
       is_protonvpn_free_tier="${is_protonvpn_free_tier,,}"

       if [ "$is_protonvpn_free_tier" = "y" ]; then
           log_warning "⚠️ ProtonVPN Free Tier Users: If you plan to use a free ProtonVPN account, please be aware that port forwarding is not supported. See our ProtonVPN Free Tier guide here: https://yams.media/advanced/vpn/#protonvpn-free-tier for more details."
           echo
       fi
    fi

    export is_protonvpn_free_tier

    log_info "The next steps WILL FAIL if you don't follow the documentation correctly."
    read -p "Press ENTER after you've READ the VPN documentation to continue..." -r

    echo

    if [ "$vpn_type" = "wireguard" ]; then
        log_info "WireGuard selected. You will need your private key and addresses."
        echo

        read -p "WireGuard private key: " wg_private_key
        [ -z "$wg_private_key" ] && log_error "WireGuard private key cannot be empty"

        read -p "WireGuard addresses (comma separated): " wg_addresses
        [ -z "$wg_addresses" ] && log_error "WireGuard addresses cannot be empty"

        read -p "WireGuard preshared key (enter only if your provider uses it, otherwise leave blank): " wg_preshared_key

        vpn_user=""
        vpn_password=""
    else
        read -p "VPN username (without spaces): " vpn_user
        vpn_user=$(echo "$vpn_user" | tr -d '[:space:]')
        [ -z "$vpn_user" ] && log_error "VPN username cannot be empty"

        # Handle password input based on VPN service
        if [ "$vpn_service" = "mullvad" ]; then
            vpn_password="$vpn_user"
            log_info "Using Mullvad username as password"
        else
            read -s -p "VPN password: " vpn_password
            echo

            [ -z "$vpn_password" ] && log_error "VPN password cannot be empty"
        fi
    fi

    # Port forwarding configuration
    if [ "$is_protonvpn_free_tier" = "y" ]; then
        log_warning "Port forwarding is automatically disabled for ProtonVPN Free Tier accounts"
        enable_port_forwarding="n"
    elif [ "$vpn_service" = "mullvad" ]; then
        log_warning "Port forwarding is not supported by Mullvad and has been disabled"
        enable_port_forwarding="n"
    else
        echo
        log_info "Port forwarding allows for better connectivity in certain applications."
        log_info "However, not all VPN providers support this feature."
        log_info "Please check your VPN provider's documentation to see if they support port forwarding."
        read -p "Enable port forwarding? (y/N) [Default = n]: " user_enable_port_forwarding
        enable_port_forwarding=${user_enable_port_forwarding:-"n"}
    fi

    # Handle special cases for ProtonVPN usernames that require the +pmp suffix for port forwarding
    if [ "$vpn_type" = "openvpn" ] && [ "$vpn_service" = "protonvpn" ] && [ "${enable_port_forwarding,,}" = "y" ] && [ "$is_protonvpn_free_tier" != "y" ] && [[ ! "$vpn_user" =~ \+pmp$ ]]; then
        vpn_user="${vpn_user}+pmp"
        log_info "Added +pmp suffix to username for ProtonVPN port forwarding"
    fi

    # Export for use in other functions
    export vpn_service vpn_user vpn_password setup_vpn enable_port_forwarding vpn_type wg_private_key wg_addresses wg_preshared_key
}

configure_usenet() {
    echo
    echo
    echo
    log_info "Time to set up Usenet."
    log_info "Usenet allows you to download content via SABnzbd."
    log_info "You can change this later by editing docker-compose.yaml."
    log_info "You can skip this if you only plan to use torrents."

    read -p "Enable Usenet/SABnzbd? (Y/n) [Default = y]: " setup_usenet
    setup_usenet=${setup_usenet:-"y"}

    export setup_usenet
}

configure_lidarr() {
    echo
    echo
    echo
    log_info "Time to set up Lidarr."
    log_info "Lidarr is used to query, add downloads to the download queue and index Music."
    log_info "You can change this later by editing docker-compose.yaml."

    read -p "Enable Lidarr? (Y/n) [Default = y]: " setup_lidarr
    setup_lidarr=${setup_lidarr:-"y"}

    export setup_lidarr
}

running_services_location() {
    local host_ip
    host_ip=$(hostname -I | awk '{ print $1 }')

    local -A services=(
        ["qBittorrent"]="8081"
        ["SABnzbd"]="8090"
        ["Radarr"]="7878"
        ["Sonarr"]="8989"
        ["Lidarr"]="8686"
        ["Prowlarr"]="9696"
        ["Bazarr"]="6767"
        ["$media_service"]="$media_service_port"
        ["Dozzle"]="8777"
    )

    echo -e "Service URLs:"
    for service in "${!services[@]}"; do
        if [ "$service" = "plex" ]; then
            echo "$service: http://$host_ip:${services[$service]}/web"
        else
            echo "$service: http://$host_ip:${services[$service]}/"
        fi
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
    confirm_configuration_overwrite "$install_directory"

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
        ["docker-compose.template.yaml"]="docker-compose.yaml"
        [".env.template"]=".env"
        ["docker-compose.custom.yaml"]="docker-compose.custom.yaml"
        ["yams"]="yams"
    )

    for src in "${!files[@]}"; do
        local dest="$install_directory/${files[$src]}"
        echo
        log_info "Downloading $src to $dest..."

        if curl -fsSL "$REPO_RAW_URL/$src" -o "$dest"; then
            log_success "$src downloaded successfully ✅"
        else
            log_error "Failed to download $src from $REPO_RAW_URL. Check your internet connection ❌"
        fi
    done
}

update_configuration_files() {
    local filename="$install_directory/docker-compose.yaml"
    local env_file="$install_directory/.env"
    local yams_script="$install_directory/yams"

    # Auto-detect timezone from system
    local tz="${TZ:-$(readlink /etc/localtime | sed 's/.*zoneinfo\///' || echo 'UTC')}"

    # Update .env file with universal settings
    log_info "Updating environment configuration..."
    local selected_vpn_type="${vpn_type:-openvpn}"
    sed -i -e "s|<your_PUID>|$puid|g" \
           -e "s|<your_PGID>|$pgid|g" \
           -e "s|<your_timezone>|$tz|g" \
           -e "s|<media_directory>|$media_directory|g" \
           -e "s|<install_directory>|$install_directory|g" \
           -e "s|vpn_enabled|$setup_vpn|g" \
           -e 's|^#WIREGUARD_PRIVATE_KEY=.*|#WIREGUARD_PRIVATE_KEY=|' \
           -e 's|^#WIREGUARD_PRESHARED_KEY=.*|#WIREGUARD_PRESHARED_KEY=|' \
           -e 's|^#WIREGUARD_ADDRESSES=.*|#WIREGUARD_ADDRESSES=|' "$env_file" || \
        log_error "Failed to update .env file"

    sed -i -e "s|^VPN_TYPE=.*|VPN_TYPE=$selected_vpn_type|g" "$env_file" || \
        log_error "Failed to update VPN type in .env file"

    # Handle Media Service Name in docker-compose.yaml
    log_info "Updating docker-compose configuration..."
    sed -i "s|<media_service>|$media_service|g" "$filename" || \
        log_error "Failed to update docker-compose.yaml"

    # Handle Plex-Specific Networking
    if [ "$media_service" == "plex" ]; then
        log_info "Configuring Plex-specific settings..."
        sed -i -e 's|# network_mode: host # only required for Plex|network_mode: host # required for Plex|g' \
               -e 's|ports: # not needed for Plex|# ports: # not needed for Plex|g' \
               -e 's|      - 8096:8096 # required for Jellyfin and Emby|    # - 8096:8096 # not needed for Plex|g' "$filename" || \
            log_error "Failed to configure Plex settings"
    fi

    # Handle VPN Configuration
    if [ "${setup_vpn,,}" == "y" ]; then
        log_info "Configuring VPN settings in .env..."

        local port_forward_settings="off"
        if [ "${enable_port_forwarding,,}" = "y" ] && [ "${is_protonvpn_free_tier,,}" != "y" ]; then
            port_forward_settings="on"
        fi

        sed -i -e "/^VPN_SERVICE=/d" -e "/^VPN_USER=/d" -e "/^VPN_PASSWORD=/d" "$env_file"
        printf 'VPN_SERVICE=%s\n' "$vpn_service" >> "$env_file"
        printf 'VPN_USER=%s\n' "$vpn_user" >> "$env_file"
        printf 'VPN_PASSWORD=%s\n' "$vpn_password" >> "$env_file"

        # Apply ProtonVPN specific subnets if free tier
        if [ "${is_protonvpn_free_tier,,}" = "y" ]; then
            sed -i 's|#- FREE_ONLY=true|- FREE_ONLY=true|' "$filename"
            sed -i "s|PORT_FORWARD_ONLY=on|PORT_FORWARD_ONLY=off|g" "$filename"
            sed -i "s|VPN_PORT_FORWARDING=on|VPN_PORT_FORWARDING=off # ProtonVPN Free Tier unsupported|g" "$filename"
            else
            sed -i "s|PORT_FORWARD_ONLY=on|PORT_FORWARD_ONLY=$port_forward_settings|g" "$filename"
            sed -i "s|VPN_PORT_FORWARDING=on|VPN_PORT_FORWARDING=$port_forward_settings|g" "$filename"
        fi

        # Apply WireGuard settings if selected
        if [ "$vpn_type" = "wireguard" ]; then
            log_info "Configuring WireGuard settings..."
            sed -i 's|.*- OPENVPN_USER=.*|      #- OPENVPN_USER=${VPN_USER}|' "$filename"
            sed -i 's|.*- OPENVPN_PASSWORD=.*|      #- OPENVPN_PASSWORD=${VPN_PASSWORD}|' "$filename"
            sed -i 's|.*- OPENVPN_CIPHERS=.*|      #- OPENVPN_CIPHERS=AES-256-GCM|' "$filename"
            # Uncomment WireGuard variable references in docker-compose.yaml
            sed -i 's|      #- WIREGUARD_PRIVATE_KEY=.*|      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}|' "$filename"
            sed -i 's|      #- WIREGUARD_ADDRESSES=.*|      - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}|' "$filename"
            if [ -n "$wg_preshared_key" ]; then
                sed -i 's|      #- WIREGUARD_PRESHARED_KEY=.*|      - WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}|' "$filename"
            fi
            # Populate WireGuard secrets in .env
            sed -i -e "/^WIREGUARD_PRIVATE_KEY=/d" -e "/^#WIREGUARD_PRIVATE_KEY=/d" "$env_file"
            sed -i -e "/^WIREGUARD_ADDRESSES=/d" -e "/^#WIREGUARD_ADDRESSES=/d" "$env_file"
            sed -i -e "/^WIREGUARD_PRESHARED_KEY=/d" -e "/^#WIREGUARD_PRESHARED_KEY=/d" "$env_file"
            printf 'WIREGUARD_PRIVATE_KEY=%s\n' "$wg_private_key" >> "$env_file"
            printf 'WIREGUARD_ADDRESSES=%s\n' "$wg_addresses" >> "$env_file"
            if [ -n "$wg_preshared_key" ]; then
                printf 'WIREGUARD_PRESHARED_KEY=%s\n' "$wg_preshared_key" >> "$env_file"
            else
                printf '#WIREGUARD_PRESHARED_KEY=\n' >> "$env_file"
            fi
        fi

    else
        # IF THEY OPT OUT OF VPN: We must disconnect qBittorrent from Gluetun
        log_info "Disabling VPN configuration..."

        sed -i -e "s|^VPN_SERVICE=.*|VPN_SERVICE=|g" \
               -e "s|^VPN_USER=.*|VPN_USER=|g" \
               -e "s|^VPN_PASSWORD=.*|VPN_PASSWORD=|g" \
               -e "s|^VPN_TYPE=.*|VPN_TYPE=|g" "$env_file"

        # 1. Comment out the gluetun network mode on qBittorrent and SABnzbd
        # 2. Uncomment the local ports so qBittorrent and SABnzbd are accessible on the host
        # 3. Use Docker profiles to hide the Gluetun container
        sed -i -e 's|network_mode: "service:gluetun"|#network_mode: "service:gluetun"|g' \
             -e 's|^[[:space:]]*#ports: # qbittorrent_ports.*|    ports:|g' \
             -e 's|^[[:space:]]*#[[:space:]]*- 8081:8081.*|    - 8081:8081|' \
             -e 's|^[[:space:]]*#ports: # sabnzbd_ports.*|    ports:|g' \
             -e 's|^[[:space:]]*#[[:space:]]*- 8090:8080.*|    - 8090:8080|' \
               -e '/disable the VPN container/s|^[[:space:]]*#profiles:|    profiles:|' "$filename" || \
            log_error "Failed to remove VPN settings from docker-compose.yaml"
    fi

    # Handle Usenet/SABnzbd configuration
    if [ "${setup_usenet,,}" != "y" ]; then
        log_info "Disabling Usenet/SABnzbd..."
        sed -i '/disable the SABnzbd container/s|^[[:space:]]*#profiles:|    profiles:|' "$filename" || \
            log_error "Failed to disable SABnzbd in docker-compose.yaml"
    fi

    # Handle Lidarr configuration
    if [ "${setup_lidarr,,}" != "y" ]; then
        log_info "Disabling Lidarr..."
        sed -i '/disable the Lidarr container/s|^[[:space:]]*#profiles:|    profiles:|' "$filename" || \
            log_error "Failed to disable Lidarr in docker-compose.yaml"
    fi

    # Update YAMS CLI script
    log_info "Updating YAMS CLI configuration..."
    sed -i -e "s|<filename>|$filename|g" \
           -e "s|<custom_file_filename>|$install_directory/docker-compose.custom.yaml|g" \
           -e "s|<install_directory>|$install_directory|g" "$yams_script" || \
        log_error "Failed to update YAMS CLI script"

    chmod 600 "$env_file" || log_error "Failed to secure .env file"
}

install_cli() {
    echo
    log_info "Installing YAMS CLI..."
    if sudo mv "$install_directory/yams" /usr/local/bin/yams && sudo chmod +x /usr/local/bin/yams; then
        log_success "YAMS CLI installed successfully ✅"
    else
        log_error "Failed to install YAMS CLI. Check permissions ❌"
    fi
}

setup_dozzle_users() {
    local dozzle_config_dir="$install_directory/config/dozzle"
    local dozzle_users_file="$dozzle_config_dir/users.yml"
    mkdir -p "$dozzle_config_dir"

    if [ -s "$dozzle_users_file" ]; then
        log_info "Keeping existing Dozzle users.yml"
        return
    fi

    # bcrypt hash generated from a random 64 character string
    local dummy_hash='$2b$11$8HxXT0N1zo5yE4Gdkh7Flu0dIj2vo.D9lqpduBpg/frXkySMjb7g6'

    cat > "$dozzle_users_file" << YAMLEOF
users:
  yams:
    email: ""
    name: ""
    password: $dummy_hash
    filter: ""
    roles: none
YAMLEOF
    chmod 600 "$dozzle_users_file" || \
        log_error "Failed to secure Dozzle users.yml"

    log_success "Dozzle users.yml created ✅"
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
configure_usenet
configure_lidarr

log_info "Configuring the docker-compose file for user \"$username\" in \"$install_directory\"..."

# Copy and update configuration files
copy_configuration_files
update_configuration_files

# Create locked Dozzle placeholder user so simple auth can boot
setup_dozzle_users

log_success "Everything installed correctly! 🎉"

# Start services
log_info "Starting YAMS services..."
log_info "This may take a while..."

if ! docker compose \
    --env-file "$install_directory/.env" \
    -f "$install_directory/docker-compose.yaml" \
    -f "$install_directory/docker-compose.custom.yaml" \
    up -d; then
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
log_info "You might need to wait for a couple of minutes while everything gets initialized"
echo
log_info "All the service locations are also saved in ~/yams_services.txt"
running_services_location > ~/yams_services.txt

log_info "========================================================"
echo
log_info "To configure YAMS, check out the documentation at"
log_info "https://yams.media/docs/configure/dozzle/"
echo
log_info "Make sure to enter your server's local IP, config and media directories into the documentation for the best experience"
log_info "========================================================"

exit 0
