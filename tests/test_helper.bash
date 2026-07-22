setup_installer_test() {
    export INSTALLER=/repo/src/install.sh
    export YAMS_FIXTURE_DIR=/repo/src
    export YAMS_DOCKER_LOG="$BATS_TEST_TMPDIR/docker.log"
    export HOME="$BATS_TEST_TMPDIR/home"
    export INSTALL_DIR="$BATS_TEST_TMPDIR/install"
    export MEDIA_DIR="$BATS_TEST_TMPDIR/media"
    export PATH="/repo/tests/bin:$PATH"
    export TZ=UTC

    mkdir -p "$HOME"
    : > "$YAMS_DOCKER_LOG"
}

run_installer() {
    printf '%s\n' "$@" > "$BATS_TEST_TMPDIR/answers"
    run bash "$INSTALLER" < "$BATS_TEST_TMPDIR/answers"
}

assert_valid_install() {
    local expected_service="$1"

    [ -f "$INSTALL_DIR/.env" ]
    [ -f "$INSTALL_DIR/docker-compose.yaml" ]
    [ -f "$INSTALL_DIR/docker-compose.custom.yaml" ]
    [ -x /usr/local/bin/yams ]

    grep -q "^MEDIA_SERVICE=$expected_service$" "$INSTALL_DIR/.env"
    ! grep -Eq '<[^>]+>|vpn_service|vpn_user|vpn_password|wireguard_(private_key|preshared_key|addresses)' \
        "$INSTALL_DIR/.env" "$INSTALL_DIR/docker-compose.yaml" "$INSTALL_DIR/yams"
    grep -Fxq "compose -f $INSTALL_DIR/docker-compose.yaml up -d" "$YAMS_DOCKER_LOG"

    /usr/bin/docker compose \
        --env-file "$INSTALL_DIR/.env" \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        config --quiet
}
