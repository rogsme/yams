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

send_success_message() {
    echo -e $(printf "\e[32m$1\e[0m")
}

send_error_message() {
    echo -e $(printf "\e[31m$1\e[0m")
    exit 255
}

check_dependencies() {
    if command -v docker &> /dev/null; then
        send_success_message "docker exists ✅ "
        if docker compose version &> /dev/null; then
            send_success_message "docker compose exists ✅ "
        else
            echo -e $(printf "\e[31m ⚠️ docker compose not found! ⚠️\e[0m")
            read -p "Do you want YAMS to install Docker Compose? IT ONLY WORKS ON DEBIAN AND UBUNTU! [y/N]: " install_docker
            install_docker=${install_docker:-"n"}

            if [ "$install_docker" == "y" ]; then
                bash ./docker.sh
            else
                send_error_message "Install Docker Compose and come back later!"
            fi
        fi
    else
        echo -e $(printf "\e[31m ⚠️ docker not found! ⚠️\e[0m")
        read -p "Do you want YAMS to install Docker and Docker Compose? IT ONLY WORKS ON DEBIAN AND UBUNTU! [y/N]: " install_docker
        install_docker=${install_docker:-"n"}

        if [ "$install_docker" == "y" ]; then
            bash ./docker.sh
        else
            send_error_message "Install Docker and Docker Compose and come back later!"
        fi
    fi
}

running_services_location() {
    host_ip=$(hostname -I | awk '{ print $1 }')

    services=(
        "qBittorrent:8080"
        "Radarr:7878"
        "Sonarr:8989"
        "Lidarr:8686"
        "Readarr:8787"
        "Prowlarr:9696"
        "Bazarr:6767"
        "$media_service:$media_service_port"
        "Portainer:9000"
    )

    echo -e "Service URLs:"
    for service in "${services[@]}"; do
        service_name="${service%%:*}"
        service_port="${service##*:}"
        echo "$service_name: http://$host_ip:$service_port/"
    done
}

echo "Checking prerequisites..."


check_dependencies

if [[ "$EUID" = 0 ]]; then
    send_error_message "YAMS has to run without sudo! Please, run it again with regular permissions"
fi

default_install_directory="/opt/yams"

read -p "Where do you want to install the docker-compose file? [$default_install_directory]: " install_directory
install_directory=${install_directory:-$default_install_directory}

if [ ! -d "$install_directory" ]; then
    echo "The directory \"$install_directory\" does not exists. Attempting to create..."
    if mkdir -p "$install_directory"; then
        send_success_message "Directory $install_directory created ✅"
    else
        send_error_message "There was an error creating the installation directory at \"$install_directory\". Make sure you have the necessary permissions ❌"
    fi
fi

if [ ! -w "$install_directory" ] || [ ! -r "$install_directory" ]; then
    send_error_message "The directory \"$install_directory\" is not writable or readable by the current user. Set the correct permissions or try a different directory" ❌
fi

filename="$install_directory/docker-compose.yaml"
custom_file_filename="$install_directory/docker-compose.custom.yaml"
env_file="$install_directory/.env"

read -p "What's the user that is going to own the media server files? [$USER]: " username
username=${username:-$USER}

if id -u "$username" &>/dev/null; then
    puid=$(id -u "$username");
    pgid=$(id -g "$username");
else
    send_error_message "The user \"$username\" doesn't exist!"
fi

read -p "Please, input your media directory [/srv/media]: " media_directory
media_directory=${media_directory:-"/srv/media"}

read -p "Are you sure your media directory is \"$media_directory\"? [y/N]: " media_directory_correct
media_directory_correct=${media_directory_correct:-"n"}

if [ ! -d "$media_directory" ]; then
    echo "The directory \"$media_directory\" does not exists. Attempting to create..."
    if mkdir -p "$media_directory"; then
        send_success_message "Directory $media_directory created ✅"
    else
        send_error_message "There was an error creating the installation directory at \"$media_directory\". Make sure you have the necessary permissions ❌"
    fi
fi

if [ "$media_directory_correct" == "n" ]; then
    send_error_message "Media directory is not correct. Please fix it and run the script again ❌"
fi

echo -e "\n\n\nTime to choose your media service."
echo "Your media service is responsible for serving your files to your network."
echo "By default, YAMS supports 3 media services:"
echo "- jellyfin (recommended, easier)"
echo "- emby"
echo "- plex (advanced, always online)"

read -p "Choose your media service [jellyfin]: " media_service
media_service=${media_service:-"jellyfin"}
media_service=$(echo "$media_service" | awk '{print tolower($0)}')

media_service_port=8096
if [ "$media_service" == "plex" ]; then
    media_service_port=32400
fi

if echo "emby plex jellyfin" | grep -qw "$media_service"; then
    echo -e "\nYAMS is going to install \"$media_service\" on port \"$media_service_port\""
else
    send_error_message "\"$media_service\" is not supported by YAMS. Are you sure you chose the correct service?"
fi

echo -e "\nTime to set up the VPN."
echo "You can check the supported VPN list here: https://yams.media/advanced/vpn."

read -p "Do you want to configure a VPN? [Y/n]: " setup_vpn
setup_vpn=${setup_vpn:-"y"}

if [ "$setup_vpn" == "y" ]; then
    read -p "What's your VPN service? (with spaces) [mullvad]: " vpn_service
    vpn_service=${vpn_service:-"mullvad"}

    echo -e "\nYou should read $vpn_service's documentation in case it has different configurations for username and password."
    echo "The documentation for $vpn_service is here: https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/${vpn_service// /-}.md"

    read -p "What's your VPN username? (without spaces): " vpn_user

    unset vpn_password
    charcount=0
    prompt="What's your VPN password? (if you are using mullvad, just enter your username again): "
    while IFS= read -p "$prompt" -r -s -n 1 char
    do
        if [[ $char == $'\0' ]]
        then
            break
        fi
        if [[ $char == $'\177' ]] ; then
            if [ $charcount -gt 0 ] ; then
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
fi

echo "Configuring the docker-compose file for the user \"$username\" on \"$install_directory\"..."

copy_files=(
    "docker-compose.example.yaml:$filename"
    ".env.example:$env_file"
    "docker-compose.custom.yaml:$custom_file_filename"
)

for file_mapping in "${copy_files[@]}"; do
    source_file="${file_mapping%%:*}"
    destination_file="${file_mapping##*:}"

    echo -e "\nCopying $source_file to $destination_file..."
    if cp "$source_file" "$destination_file"; then
        send_success_message "$source_file was copied successfuly! ✅"
    else
        send_error_message "Failed to copy $source_file to $destination_file. Ensure your user ($USER) has the necessary permissions ❌"
    fi
done

sed -i -e "s|<your_PUID>|$puid|g" "$env_file" \
 -e "s|<your_PGID>|$pgid|g" "$env_file" \
 -e "s|<media_directory>|$media_directory|g" "$env_file" \
 -e "s|<media_service>|$media_service|g" "$env_file" \
 -e "s|<media_service>|$media_service|g" "$filename"

if [ "$media_service" == "plex" ]; then
    sed -i -e "s|#network_mode: host # plex|network_mode: host # plex|g" "$filename" \
     -e "s|ports: # plex|#ports: # plex|g" "$filename" \
     -e "s|- 8096:8096 # plex|#- 8096:8096 # plex|g" "$filename"
fi

sed -i -e "s|<install_directory>|$install_directory|g" "$env_file" \
 -e "s|vpn_enabled|$setup_vpn|g" "$env_file" \

if [ "$setup_vpn" == "y" ]; then
    sed -i -e "s|vpn_service|$vpn_service|g" "$env_file" \
     -e "s|vpn_user|$vpn_user|g" "$env_file" \
     -e "s|vpn_password|$vpn_password|g" "$env_file" \
     -e "s|#network_mode: \"service:gluetun\"|network_mode: \"service:gluetun\"|g" "$filename" \
     -e "s|ports: # qbittorrent|#ports: # qbittorrent|g" "$filename" \
     -e "s|- 8080:8080 # qbittorrent|#- 8080:8080 # qbittorrent|g" "$filename" \
     -e "s|#- 8080:8080/tcp # gluetun|- 8080:8080/tcp # gluetun|g" "$filename"
fi

sed -i -e "s|<filename>|$filename|g" yams \
 -e "s|<custom_file_filename>|$custom_file_filename|g" yams \
 -e "s|<install_directory>|$install_directory|g" yams

send_success_message "Everything installed correctly! 🎉"

echo "Running the server..."
echo "This is going to take a while..."

docker compose -f "$filename" up -d

echo -e "\nWe need your sudo password to install the YAMS CLI and configure permissions..."

if sudo cp yams /usr/local/bin/yams && sudo chmod +x /usr/local/bin/yams; then
    send_success_message "YAMS CLI installed successfully ✅"
else
    send_error_message "Failed to install YAMS CLI. Make sure you have the necessary permissions ❌"
fi

if sudo chown -R "$puid":"$pgid" "$media_directory"; then
    send_success_message "Media directory ownership and permissions set successfully ✅"
else
    send_error_message "Failed to set ownership and permissions for the media directory. Check permissions ❌"
fi

if sudo chown -R "$puid":"$pgid" "$install_directory"; then
    send_success_message "Install directory ownership and permissions set successfully ✅"
else
    send_error_message "Failed to set ownership and permissions for the install directory. Check permissions ❌"
fi

if [[ -d "$install_directory/config" ]]; then
    send_success_message "Configuration folder \"$install_directory/config\" exists ✅"
else
    if sudo mkdir -p "$install_directory/config"; then
        send_success_message "Configuration folder \"$install_directory/config\" created ✅"
    else
        send_error_message "Failed to create or access the configuration folder. Check permissions ❌"
    fi
fi

if sudo chown -R "$puid":"$pgid" "$install_directory/config"; then
    send_success_message "Configuration folder ownership and permissions set successfully ✅"
else
    send_error_message "Failed to set ownership and permissions for the configuration folder. Check permissions ❌"
fi

printf "\033c"

echo "========================================================"
echo "     _____          ___           ___           ___     "
echo "    /  /::\        /  /\         /__/\         /  /\    "
echo "   /  /:/\:\      /  /::\        \  \:\       /  /:/_   "
echo "  /  /:/  \:\    /  /:/\:\        \  \:\     /  /:/ /\  "
echo " /__/:/ \__\:|  /  /:/  \:\   _____\__\:\   /  /:/ /:/_ "
echo " \  \:\ /  /:/ /__/:/ \__\:\ /__/::::::::\ /__/:/ /:/ /\\"
echo "  \  \:\  /:/  \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\/:/ /:/"
echo "   \  \:\/:/    \  \:\  /:/   \  \:\  ~~~   \  \::/ /:/ "
echo "    \  \::/      \  \:\/:/     \  \:\        \  \:\/:/  "
echo "     \__\/        \  \::/       \  \:\        \  \::/   "
echo "                   \__\/         \__\/         \__\/    "
echo "========================================================"
send_success_message "All done!✅  Enjoy YAMS!"
echo "You can check the installation on $install_directory"
echo "========================================================"
echo "Everything should be running now! To check everything running, go to:"
echo
running_services_location
echo
echo
echo "You might need to wait for a couple of minutes while everything gets up and running"
echo
echo "All the services location are also saved in ~/yams_services.txt"
running_services_location > ~/yams_services.txt
echo "========================================================"
echo
echo "To configure YAMS, check the documentation at"
echo "https://yams.media/config"
echo
echo "========================================================"
exit 0
