#!/usr/bin/env bats

load test_helper.bash

setup() {
    setup_installer_test
}

install_without_vpn() {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y \
        "${1:-}" n "${2:-y}" "${3:-y}"
}

@test "installs Jellyfin without VPN with an exact environment file" {
    install_without_vpn "" n n

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin

    diff -u <(cat <<EOF
# Base configuration
PUID=$(id -u)
PGID=$(id -g)
TZ=UTC
MEDIA_DIRECTORY=$MEDIA_DIR
INSTALL_DIRECTORY=$INSTALL_DIR

# VPN configuration
VPN_SERVICE=
VPN_TYPE=

# openvpn specific settings
VPN_USER=
VPN_PASSWORD=

# WireGuard specific settings
#WIREGUARD_PRIVATE_KEY=
#WIREGUARD_PRESHARED_KEY=
#WIREGUARD_ADDRESSES=

# service secrets (remember to uncomment when using them!)
#QBITTORRENT_API_KEY=qbt_your_api_key
EOF
    ) "$INSTALL_DIR/.env"
}

@test "installs the media tree, generated CLI, and service location file" {
    install_without_vpn

    [ "$status" -eq 0 ]
    for directory in \
        tvshows movies music books \
        downloads/usenet/complete downloads/usenet/incomplete \
        downloads/torrents blackhole; do
        [ -d "$MEDIA_DIR/$directory" ]
    done

    grep -Fxq "readonly DC=\"docker compose -f $INSTALL_DIR/docker-compose.yaml -f $INSTALL_DIR/docker-compose.custom.yaml\"" "$YAMS_SYSTEM_BIN/yams"
    grep -Fxq "readonly INSTALL_DIRECTORY=\"$INSTALL_DIR\"" "$YAMS_SYSTEM_BIN/yams"
    bash -n "$YAMS_SYSTEM_BIN/yams"
    [ ! -e "$INSTALL_DIR/yams" ]

    [ -f "$HOME/yams_services.txt" ]
    [ "$(wc -l < "$HOME/yams_services.txt")" -eq 10 ]
    grep -Fxq 'Service URLs:' "$HOME/yams_services.txt"
    grep -Fxq 'jellyfin: http://192.0.2.10:8096/' "$HOME/yams_services.txt"
    grep -Fxq 'qBittorrent: http://192.0.2.10:8081/' "$HOME/yams_services.txt"
    grep -Fxq 'Dozzle: http://192.0.2.10:8777/' "$HOME/yams_services.txt"
    assert_output_contains 'https://yams.media/docs/configure/dozzle/'
}

@test "creates an unusable Dozzle bootstrap user" {
    install_without_vpn

    [ "$status" -eq 0 ]
    grep -Fxq '  yams:' "$INSTALL_DIR/config/dozzle/users.yml"
    grep -Fxq '    password: $2b$11$8HxXT0N1zo5yE4Gdkh7Flu0dIj2vo.D9lqpduBpg/frXkySMjb7g6' \
        "$INSTALL_DIR/config/dozzle/users.yml"
    grep -Fxq '    roles: none' "$INSTALL_DIR/config/dozzle/users.yml"
    [ "$(stat -c %a "$INSTALL_DIR/config/dozzle/users.yml")" = 600 ]
    [ ! -e "$INSTALL_DIR/config/dozzle/bootstrap-password.txt" ]
    ! grep -Fq 'Dozzle bootstrap password:' <<<"$output"
    ! grep -Fq $'\tdocker\trun\t' "$YAMS_DOCKER_LOG"
}

@test "keeps the custom Compose template unchanged and uses it at startup" {
    install_without_vpn

    [ "$status" -eq 0 ]
    cmp /repo/src/docker-compose.custom.yaml "$INSTALL_DIR/docker-compose.custom.yaml"
    grep -Fxq '# services:' "$INSTALL_DIR/docker-compose.custom.yaml"
    assert_command "$YAMS_DOCKER_LOG" docker compose \
        --env-file "$INSTALL_DIR/.env" \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        up -d
}

@test "installs Plex without VPN, Usenet, or Lidarr" {
    install_without_vpn plex n n

    [ "$status" -eq 0 ]
    assert_valid_install plex
    grep -Fxq '    network_mode: host # required for Plex' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    #network_mode: "service:gluetun"' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    image: lscr.io/linuxserver/plex' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    container_name: plex' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    # ports: # not needed for Plex' "$INSTALL_DIR/docker-compose.yaml"
    [ "$(grep -c 'profiles: \["disabled"\]' "$INSTALL_DIR/docker-compose.yaml")" -eq 3 ]
    ! grep -Eq '^[[:space:]]+- 8096:8096' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq 'plex: http://192.0.2.10:32400/web' "$HOME/yams_services.txt"
}

@test "installs Jellyfin with media service ports and without host networking" {
    install_without_vpn

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -Fxq '    image: lscr.io/linuxserver/jellyfin' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    container_name: jellyfin' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    # network_mode: host # only required for Plex' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '    ports: # not needed for Plex' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '      - 8096:8096 # required for Jellyfin and Emby' "$INSTALL_DIR/docker-compose.yaml"
}

@test "installs OpenVPN with valid optional port forwarding callbacks" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y protonvpn openvpn n "" vpn-user vpn-password y y y

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -Fxq 'VPN_SERVICE=protonvpn' "$INSTALL_DIR/.env"
    grep -Fxq 'VPN_TYPE=openvpn' "$INSTALL_DIR/.env"
    grep -Fxq 'VPN_USER=vpn-user+pmp' "$INSTALL_DIR/.env"
    grep -Fxq 'VPN_PASSWORD=vpn-password' "$INSTALL_DIR/.env"
    [ "$(grep -c '^VPN_USER=' "$INSTALL_DIR/.env")" -eq 1 ]
    grep -Fxq '      - PORT_FORWARD_ONLY=on' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '      - VPN_PORT_FORWARDING=on' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '      #- HTTPPROXY=on' "$INSTALL_DIR/docker-compose.yaml"
    sed -i '/VPN_PORT_FORWARDING_\(UP\|DOWN\)_COMMAND/s|^      #- |      - |' "$INSTALL_DIR/docker-compose.yaml"
    QBITTORRENT_API_KEY=test /usr/bin/docker compose \
        --env-file "$INSTALL_DIR/.env" \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        config --quiet
}

@test "comments out port forwarding callbacks when port forwarding is disabled" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y protonvpn openvpn n "" vpn-user vpn-password n y y

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -Fxq '      - PORT_FORWARD_ONLY=off' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '      - VPN_PORT_FORWARDING=off' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq "      #- 'VPN_PORT_FORWARDING_UP_COMMAND=" "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq "      #- 'VPN_PORT_FORWARDING_DOWN_COMMAND=" "$INSTALL_DIR/docker-compose.yaml"
}

@test "defaults Mullvad to WireGuard and disables port forwarding" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y emby \
        y MULLVAD "" "" private-key 10.0.0.2/32 "" y y

    [ "$status" -eq 0 ]
    assert_valid_install emby
    grep -Fxq 'VPN_SERVICE=mullvad' "$INSTALL_DIR/.env"
    grep -Fxq 'VPN_TYPE=wireguard' "$INSTALL_DIR/.env"
    grep -Fxq 'WIREGUARD_PRIVATE_KEY=private-key' "$INSTALL_DIR/.env"
    grep -Fxq 'WIREGUARD_ADDRESSES=10.0.0.2/32' "$INSTALL_DIR/.env"
    grep -Fxq '      - PORT_FORWARD_ONLY=off' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fxq '      - VPN_PORT_FORWARDING=off' "$INSTALL_DIR/docker-compose.yaml"
    assert_output_contains 'Port forwarding is not supported by Mullvad and has been disabled'
}

@test "installs WireGuard and transforms only WireGuard settings" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y emby \
        y mullvad wireguard "" private-key 10.0.0.2/32 preshared-key y y y

    [ "$status" -eq 0 ]
    assert_valid_install emby
    grep -Fxq 'VPN_SERVICE=mullvad' "$INSTALL_DIR/.env"
    grep -Fxq 'VPN_TYPE=wireguard' "$INSTALL_DIR/.env"
    grep -Fxq 'WIREGUARD_PRIVATE_KEY=private-key' "$INSTALL_DIR/.env"
    grep -Fxq 'WIREGUARD_ADDRESSES=10.0.0.2/32' "$INSTALL_DIR/.env"
    grep -Fxq 'WIREGUARD_PRESHARED_KEY=preshared-key' "$INSTALL_DIR/.env"
    grep -Fq -- '- WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq -- '#- OPENVPN_USER=${VPN_USER}' "$INSTALL_DIR/docker-compose.yaml"
    ! grep -Eq 'wireguard_(private_key|preshared_key|addresses)' "$INSTALL_DIR/.env"
}

@test "installs WireGuard without enabling an empty preshared key" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y mullvad wireguard "" private-key 10.0.0.2/32 "" n y y

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -Fxq '#WIREGUARD_PRESHARED_KEY=' "$INSTALL_DIR/.env"
    grep -Fq -- '#- WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}' "$INSTALL_DIR/docker-compose.yaml"
    ! grep -q '^WIREGUARD_PRESHARED_KEY=' "$INSTALL_DIR/.env"
}

@test "ProtonVPN free tier disables port forwarding" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y protonvpn openvpn y "" vpn-user vpn-password y y

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -Fq -- '- FREE_ONLY=true' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq 'VPN_PORT_FORWARDING=off # ProtonVPN Free Tier unsupported' "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq "      #- 'VPN_PORT_FORWARDING_UP_COMMAND=" "$INSTALL_DIR/docker-compose.yaml"
    grep -Fq "      #- 'VPN_PORT_FORWARDING_DOWN_COMMAND=" "$INSTALL_DIR/docker-compose.yaml"
    ! grep -q '^VPN_USER=.*+pmp$' "$INSTALL_DIR/.env"
}

@test "downloads every installer artifact from the v4 raw source" {
    install_without_vpn

    [ "$status" -eq 0 ]
    [ "$(wc -l < "$YAMS_CURL_LOG")" -eq 4 ]
    [ "$(grep -Fc 'https://raw.githubusercontent.com/rogsme/yams/v4/src/' "$YAMS_CURL_LOG")" -eq 4 ]
}

@test "rejects execution as root before creating files" {
    run /usr/bin/sudo -n bash "$INSTALLER"

    [ "$status" -eq 1 ]
    assert_output_contains 'YAMS must run without sudo'
    [ ! -e "$INSTALL_DIR" ]
}

@test "rejects a nonexistent owner" {
    run_installer nobody-who-does-not-exist

    [ "$status" -eq 1 ]
    assert_output_contains "doesn't exist"
    [ ! -e "$INSTALL_DIR" ]
}

@test "rejects an unconfirmed media directory" {
    run_installer "" "$INSTALL_DIR" "$MEDIA_DIR" n

    [ "$status" -eq 1 ]
    assert_output_contains 'Media directory is not correct'
    [ ! -e "$MEDIA_DIR" ]
}

@test "does not overwrite existing configuration without confirmation" {
    mkdir -p "$INSTALL_DIR"
    for file in .env docker-compose.yaml docker-compose.custom.yaml yams; do
        printf 'keep-%s\n' "$file" > "$INSTALL_DIR/$file"
    done

    run_installer "" "$INSTALL_DIR" n

    [ "$status" -eq 1 ]
    assert_output_contains 'Installation cancelled without changing the existing configuration'
    for file in .env docker-compose.yaml docker-compose.custom.yaml yams; do
        grep -Fxq "keep-$file" "$INSTALL_DIR/$file"
    done
    [ ! -e "$MEDIA_DIR" ]
}

@test "rejects an unsupported media service" {
    run_installer "" "$INSTALL_DIR" "$MEDIA_DIR" y kodi

    [ "$status" -eq 1 ]
    assert_output_contains '"kodi" is not supported by YAMS'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "rejects an invalid VPN type" {
    run_installer "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin y mullvad ipsec

    [ "$status" -eq 1 ]
    assert_output_contains 'Invalid VPN type'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "rejects an OpenVPN username containing only whitespace" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y protonvpn openvpn n "" '   '

    [ "$status" -eq 1 ]
    assert_output_contains 'VPN username cannot be empty'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "rejects an empty OpenVPN password" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y protonvpn openvpn n "" vpn-user ""

    [ "$status" -eq 1 ]
    assert_output_contains 'VPN password cannot be empty'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "rejects empty WireGuard credentials" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y mullvad wireguard "" ""

    [ "$status" -eq 1 ]
    assert_output_contains 'WireGuard private key cannot be empty'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "rejects an empty WireGuard address" {
    run_installer \
        "" "$INSTALL_DIR" "$MEDIA_DIR" y jellyfin \
        y mullvad wireguard "" private-key ""

    [ "$status" -eq 1 ]
    assert_output_contains 'WireGuard addresses cannot be empty'
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "reports a configuration download failure without starting Compose" {
    export YAMS_CURL_FAIL=.env.template
    install_without_vpn

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to download .env.template'
    ! grep -Fq $'\tup\t-d\t' "$YAMS_DOCKER_LOG"
}

@test "reports a Compose startup failure without installing the CLI" {
    export YAMS_DOCKER_UP_STATUS=1
    install_without_vpn

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to start YAMS services'
    [ ! -e "$INSTALL_DIR/config/dozzle/bootstrap-password.txt" ]
    ! grep -Fq 'Dozzle bootstrap password:' <<<"$output"
    [ ! -e "$YAMS_SYSTEM_BIN/yams" ]
    [ ! -e "$HOME/yams_services.txt" ]
}

@test "fails dependency installation when apt update fails" {
    export YAMS_MISSING_COMMAND=awk
    export YAMS_SUDO_APT_UPDATE_STATUS=1
    run_installer y

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to install missing packages'
    assert_command "$YAMS_SUDO_LOG" sudo apt update
    refute_command "$YAMS_SUDO_LOG" sudo apt install -y awk
}

@test "revalidates commands after dependency installation" {
    export YAMS_MISSING_COMMAND=awk
    run_installer y

    [ "$status" -eq 1 ]
    assert_output_contains 'Package installation completed, but required command "awk" is still unavailable'
    assert_command "$YAMS_SUDO_LOG" sudo apt update
    assert_command "$YAMS_SUDO_LOG" sudo apt install -y awk
}
