#!/usr/bin/env bats

load test_helper.bash

setup() {
    setup_installer_test
}

@test "installs Jellyfin with the default OpenVPN configuration" {
    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "" \
        "" \
        "" \
        "" \
        "n" \
        "" \
        "vpn-user" \
        "vpn-password" \
        "n" \
        "" \
        ""

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -q '^VPN_SERVICE=protonvpn$' "$INSTALL_DIR/.env"
    grep -q '^VPN_TYPE=openvpn$' "$INSTALL_DIR/.env"
    grep -q '^VPN_USER=vpn-user$' "$INSTALL_DIR/.env"
    grep -q '^VPN_PASSWORD=vpn-password$' "$INSTALL_DIR/.env"
    grep -q 'PORT_FORWARD_ONLY=off' "$INSTALL_DIR/docker-compose.yaml"
    grep -q 'VPN_PORT_FORWARDING=off' "$INSTALL_DIR/docker-compose.yaml"
}

@test "installs Plex without VPN, Usenet, or Lidarr" {
    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "plex" \
        "n" \
        "n" \
        "n"

    [ "$status" -eq 0 ]
    assert_valid_install plex
    grep -q '^VPN_SERVICE=$' "$INSTALL_DIR/.env"
    grep -q '^VPN_TYPE=$' "$INSTALL_DIR/.env"
    grep -q '^    network_mode: host # plex$' "$INSTALL_DIR/docker-compose.yaml"
    grep -q '^    #network_mode: "service:gluetun"$' "$INSTALL_DIR/docker-compose.yaml"
    [ "$(grep -c 'profiles: \["disabled"\]' "$INSTALL_DIR/docker-compose.yaml")" -eq 3 ]
}

@test "installs Emby with WireGuard and port forwarding" {
    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "emby" \
        "y" \
        "mullvad" \
        "wireguard" \
        "" \
        "private-key" \
        "10.0.0.2/32" \
        "preshared-key" \
        "y" \
        "y" \
        "y"

    [ "$status" -eq 0 ]
    assert_valid_install emby
    grep -q '^VPN_SERVICE=mullvad$' "$INSTALL_DIR/.env"
    grep -q '^VPN_TYPE=wireguard$' "$INSTALL_DIR/.env"
    grep -q '^WIREGUARD_PRIVATE_KEY=private-key$' "$INSTALL_DIR/.env"
    grep -q '^WIREGUARD_ADDRESSES=10.0.0.2/32$' "$INSTALL_DIR/.env"
    grep -q '^WIREGUARD_PRESHARED_KEY=preshared-key$' "$INSTALL_DIR/.env"
    grep -q -- '- WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}' "$INSTALL_DIR/docker-compose.yaml"
    grep -q 'VPN_PORT_FORWARDING=on' "$INSTALL_DIR/docker-compose.yaml"
}

@test "ProtonVPN free tier disables port forwarding" {
    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "jellyfin" \
        "y" \
        "protonvpn" \
        "openvpn" \
        "y" \
        "" \
        "vpn-user" \
        "vpn-password" \
        "y" \
        "y"

    [ "$status" -eq 0 ]
    assert_valid_install jellyfin
    grep -q -- '- FREE_ONLY=true' "$INSTALL_DIR/docker-compose.yaml"
    grep -q 'VPN_PORT_FORWARDING=off # ProtonVPN Free Tier unsupported' "$INSTALL_DIR/docker-compose.yaml"
    ! grep -q '^VPN_USER=.*+pmp$' "$INSTALL_DIR/.env"
}

@test "rejects execution as root" {
    run sudo -n bash "$INSTALLER"

    [ "$status" -eq 1 ]
    [[ "$output" == *"YAMS must run without sudo"* ]]
    [ ! -e "$INSTALL_DIR" ]
}

@test "rejects an unsupported media service" {
    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "kodi"

    [ "$status" -eq 1 ]
    [[ "$output" == *'"kodi" is not supported by YAMS'* ]]
    [ ! -e "$INSTALL_DIR/.env" ]
}

@test "reports a configuration download failure" {
    export YAMS_CURL_FAIL=.env.template

    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "jellyfin" \
        "n" \
        "y" \
        "y"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to download .env.template"* ]]
}

@test "reports a Compose startup failure" {
    export YAMS_DOCKER_UP_STATUS=1

    run_installer \
        "" \
        "$INSTALL_DIR" \
        "$MEDIA_DIR" \
        "y" \
        "jellyfin" \
        "n" \
        "y" \
        "y"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to start YAMS services"* ]]
}
