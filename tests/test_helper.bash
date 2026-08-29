setup_mock_environment() {
    export YAMS_MOCK_STATE_DIR="$BATS_TEST_TMPDIR/mock-state"
    export YAMS_DOCKER_LOG="$BATS_TEST_TMPDIR/docker.log"
    export YAMS_CURL_LOG="$BATS_TEST_TMPDIR/curl.log"
    export YAMS_SUDO_LOG="$BATS_TEST_TMPDIR/sudo.log"
    export YAMS_SLEEP_LOG="$BATS_TEST_TMPDIR/sleep.log"
    export YAMS_TAR_LOG="$BATS_TEST_TMPDIR/tar.log"
    export YAMS_SYSTEM_BIN="$BATS_TEST_TMPDIR/system-bin"
    export YAMS_FIXTURE_DIR=/repo/src
    export PATH="/repo/tests/bin:$PATH"

    mkdir -p "$YAMS_MOCK_STATE_DIR" "$YAMS_SYSTEM_BIN"
    : > "$YAMS_DOCKER_LOG"
    : > "$YAMS_CURL_LOG"
    : > "$YAMS_SUDO_LOG"
    : > "$YAMS_SLEEP_LOG"
    : > "$YAMS_TAR_LOG"
}

setup_installer_test() {
    setup_mock_environment
    export INSTALLER=/repo/src/install.sh
    export HOME="$BATS_TEST_TMPDIR/home"
    export INSTALL_DIR="$BATS_TEST_TMPDIR/install"
    export MEDIA_DIR="$BATS_TEST_TMPDIR/media"
    export TZ=UTC

    mkdir -p "$HOME"

    cat > "$BATS_TEST_TMPDIR/bash-env" <<'EOF'
command() {
    if [[ "${1:-}" == -v && "${2:-}" == "${YAMS_MISSING_COMMAND:-__none__}" ]]; then
        return 1
    fi
    builtin command "$@"
}
EOF
    export BASH_ENV="$BATS_TEST_TMPDIR/bash-env"
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
    [ -x "$YAMS_SYSTEM_BIN/yams" ]
    [ "$(stat -c %a "$INSTALL_DIR/.env")" = 600 ]

    ! grep -Eq '^MEDIA_.*SERVICE=' "$INSTALL_DIR/.env"
    grep -q "^  $expected_service:$" "$INSTALL_DIR/docker-compose.yaml"
    grep -q "^    image: lscr.io/linuxserver/$expected_service$" "$INSTALL_DIR/docker-compose.yaml"
    grep -q "^    container_name: $expected_service$" "$INSTALL_DIR/docker-compose.yaml"
    ! grep -Eq '<[^>]+>|vpn_service|vpn_user|vpn_password|wireguard_(private_key|preshared_key|addresses)' \
        "$INSTALL_DIR/.env" "$INSTALL_DIR/docker-compose.yaml" "$YAMS_SYSTEM_BIN/yams"
    assert_command "$YAMS_DOCKER_LOG" docker compose \
        --env-file "$INSTALL_DIR/.env" \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        up -d

    /usr/bin/docker compose \
        --env-file "$INSTALL_DIR/.env" \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        config --quiet
}

setup_cli_test() {
    setup_mock_environment
    export HOME="$BATS_TEST_TMPDIR/home"
    export INSTALL_DIR="$BATS_TEST_TMPDIR/install"
    export CLI_BIN="$BATS_TEST_TMPDIR/cli-bin"
    export CLI="$CLI_BIN/yams"
    export TMPDIR="$BATS_TEST_TMPDIR/tmp"

    mkdir -p "$HOME" "$INSTALL_DIR/config/keep" "$CLI_BIN" "$TMPDIR"
    cp /repo/src/yams "$CLI"
    sed -i \
        -e "s|<filename>|$INSTALL_DIR/docker-compose.yaml|g" \
        -e "s|<custom_file_filename>|$INSTALL_DIR/docker-compose.custom.yaml|g" \
        -e "s|<install_directory>|$INSTALL_DIR|g" "$CLI"
    chmod +x "$CLI"
    : > "$INSTALL_DIR/docker-compose.yaml"
    : > "$INSTALL_DIR/docker-compose.custom.yaml"
    export PATH="$CLI_BIN:$PATH"
}

run_cli() {
    run "$CLI" "$@"
}

run_cli_input() {
    local answer=$1
    shift
    printf '%s\n' "$answer" > "$BATS_TEST_TMPDIR/cli-answer"
    run "$CLI" "$@" < "$BATS_TEST_TMPDIR/cli-answer"
}

assert_command() {
    local log=$1
    shift
    local expected=""
    local arg

    for arg in "$@"; do
        printf -v expected '%s%q\t' "$expected" "$arg"
    done
    grep -Fxq "$expected" "$log"
}

refute_command() {
    ! assert_command "$@"
}

assert_output_contains() {
    [[ "$output" == *"$1"* ]]
}

assert_cli_compose_command() {
    local action=$1
    shift
    assert_command "$YAMS_DOCKER_LOG" docker compose \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" \
        "$action" "$@"
}
