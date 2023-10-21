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

check_dependencides() {
    if command -v $1 &> /dev/null; then
        send_success_message "$1 exists ✅ "
    else
        echo -e $(printf "\e[31m ⚠️ $1 not found! ⚠️\e[0m")
        read -p "Do you want YAMS to install docker and docker-compose? IT ONLY WORKS ON DEBIAN AND UBUNTU! [y/N]: " install_docker
        install_docker=${install_docker:-"n"}

        if [ "$install_docker" == "y" ]; then
            bash ./docker.sh
        else
            send_error_message "Install docker and docker-compose and come back later!"
        fi
    fi
}

running_services_location() {
    host_ip=$(hostname -I | awk '{ print $1 }')
    echo "qBittorrent: http://$host_ip:8080/"
    echo "Radarr: http://$host_ip:7878/"
    echo "Sonarr: http://$host_ip:8989/"
    echo "Lidarr: http://$host_ip:8686/"
    echo "Readarr: http://$host_ip:8787/"
    echo "Prowlarr: http://$host_ip:9696/"
    echo "Bazarr: http://$host_ip:6767/"
    echo "$media_service: http://$host_ip:$media_service_port/"
    echo "Portainer: http://$host_ip:9000/"
}

echo "Checking prerequisites..."


check_dependencides "docker"
check_dependencides "docker-compose"

if [[ "$EUID" = 0 ]]; then
    send_error_message "YAMS has to run without sudo! Please, run it again with regular permissions"
fi

read -p "Where do you want to install the docker-compose file? [/opt/yams]: " install_location

install_location=${install_location:-/opt/yams}
[[ -f "$install_location" ]] || mkdir -p "$install_location" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
install_location=$(realpath "$install_location")
filename="$install_location/docker-compose.yaml"
env_file="$install_location/.env"

read -p "What's the user that is going to own the media server files? [$USER]: " username

username=${username:-$USER}

if id -u "$username" &>/dev/null; then
    puid=$(id -u "$username");
    pgid=$(id -g "$username");
else
    send_error_message "The user \"$username\" doesn't exist!"
fi

read -p "Please, input your media folder [/srv/media]: " media_folder
media_folder=${media_folder:-"/srv/media"}

realpath "$media_folder" &>/dev/null || send_error_message "There was an error with your media folder! The directory \"$media_folder\" does not exist!"

media_folder=$(realpath "$media_folder")

read -p "Are you sure your media folder is \"$media_folder\"? [y/N]: " media_folder_correct
media_folder_correct=${media_folder_correct:-"n"}

if [ "$media_folder_correct" == "n" ]; then
    send_error_message "Media folder is not correct. Please, fix it and run the script again"
fi

echo
echo
echo
echo "Time to choose your media service."
echo "Your media service is the one responsible for serving your files to your network."
echo "By default, YAMS support 3 media services:"
echo "- jellyfin (recommended, easier)"
echo "- emby"
echo "- plex (advanced, always online)"
read -p "Choose your media service [jellyfin]: " media_service
media_service=${media_service:-"jellyfin"}
media_service=$(echo "$media_service" | sed -e 's/\(.*\)/\L\1/')

media_service_port=8096
if [ "$media_service" == "plex" ]; then
    media_service_port=32400
fi

if echo "emby plex jellyfin" | grep -qw "$media_service"; then
    echo "YAMS is going to install \"$media_service\" on port \"$media_service_port\""
else
    send_error_message "\"$media_service\" is not supported by YAMS. Are you sure you chose the correct service?"
fi

echo
echo
echo
echo "Time to set up the VPN."
echo "You can check the supported VPN list here: https://yams.media/advanced/vpn."
read -p "Do you want to configure a VPN? [Y/n]: " setup_vpn
setup_vpn=${setup_vpn:-"y"}

if [ "$setup_vpn" == "y" ]; then
    read -p "What's your VPN service? (with spaces) [mullvad]: " vpn_service
    vpn_service=${vpn_service:-"mullvad"}
    echo
    echo "You should read $vpn_service's documentation in case it has different configurations for username and password."
    echo "The documentation for $vpn_service is here: https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/${vpn_service// /-}.md"
    echo
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

    echo "What country do you want to use?"
    echo "If you are using: NordVPN, Perfect Privacy, Private Internet Access, VyprVPN, WeVPN or Windscribe, then input a region"
    read -p "You can check the countries/regions list for your VPN here: https://github.com/qdm12/gluetun/wiki/$vpn_service#servers [brazil]: " vpn_country
    vpn_country=${vpn_country:-"brazil"}
fi

echo "Configuring the docker-compose file for the user \"$username\" on \"$install_location\"..."

echo ""
echo "Copying $filename..."

cp docker-compose.example.yaml "$filename" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp .env.example "$env_file" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"

# Set PUID
sed -i -e "s/<your_PUID>/$puid/g" "$env_file"

# Set PGID
sed -i -e "s/<your_PGID>/$pgid/g" "$env_file"

# Set media_folder
sed -i -e "s;<media_folder>;$media_folder;g" "$env_file"

# Set media_service
sed -i -e "s;<media_service>;$media_service;g" "$env_file"
sed -i -e "s;<media_service>;$media_service;g" "$filename"
if [ "$media_service" == "plex" ]; then
    sed -i -e "s;#network_mode: host # plex;network_mode: host # plex;g" "$filename"
fi

# Set config folder
sed -i -e "s;<install_location>;$install_location;g" "$env_file"

# Set VPN
if [ "$setup_vpn" == "y" ]; then
    sed -i -e "s;<vpn_service>;$vpn_service;g" "$env_file"
    sed -i -e "s;<vpn_user>;$vpn_user;g" "$env_file"
    sed -i -e "s;<vpn_password>;$vpn_password;g" "$env_file"
    sed -i -e "s;#network_mode: \"service:gluetun\";network_mode: \"service:gluetun\";g" "$filename"
    sed -i -e "s;ports: # qbittorrent;#port: # qbittorrent;g" "$filename"
    sed -i -e "s;- 8080:8080 # qbittorrent;#- 8080:8080 # qbittorrent;g" "$filename"
    sed -i -e "s;#- 8080:8080/tcp # gluetun;- 8080:8080/tcp # gluetun;g" "$filename"
fi

sed -i -e "s;<filename>;$filename;g" yams
sed -i -e "s;<install_location>;$install_location;g" yams

send_success_message "Everything installed correctly! 🎉"

echo "Running the server..."
echo "This is going to take a while..."

docker-compose -f "$filename" up -d

send_success_message "We need your sudo password to install the yams CLI and correct permissions..."
sudo cp yams /usr/local/bin/yams && sudo chmod +x /usr/local/bin/yams
[[ -f "$media_folder" ]] || sudo mkdir -p "$media_folder" || send_error_message "There was an error with your install location!"
sudo chown -R "$puid":"$pgid" "$media_folder"
[[ -f $install_location/config ]] || sudo mkdir -p "$install_location/config"
sudo chown -R "$puid":"$pgid" "$install_location"

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
echo "You can check the installation on $install_location"
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
