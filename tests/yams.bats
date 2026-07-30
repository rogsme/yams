#!/usr/bin/env bats

load test_helper.bash

setup() {
    setup_cli_test
}

make_update_fixture() {
    export YAMS_CURL_UPDATE_FILE="$BATS_TEST_TMPDIR/remote-yams"
    cp /repo/src/yams "$YAMS_CURL_UPDATE_FILE"
    sed -i '2i# downloaded update marker' "$YAMS_CURL_UPDATE_FILE"
}

@test "shows help with no command" {
    run_cli

    [ "$status" -eq 0 ]
    assert_output_contains 'Usage: yams [command] [options]'
    assert_output_contains 'update-cli'
    [ ! -s "$YAMS_DOCKER_LOG" ]
}

@test "shows help explicitly" {
    run_cli --help

    [ "$status" -eq 0 ]
    assert_output_contains 'Yet Another Media Server'
}

@test "rejects an unknown command" {
    run_cli not-a-command

    [ "$status" -eq 1 ]
    assert_output_contains 'Unknown command: not-a-command'
    assert_output_contains "Run 'yams --help'"
}

@test "starts all services and waits until they are ready" {
    export YAMS_DOCKER_PS_STATES=2/2
    run_cli start

    [ "$status" -eq 0 ]
    assert_cli_compose_command up -d
    assert_cli_compose_command ps --format '{{.Name}}'
    assert_cli_compose_command ps --format '{{.Status}}'
    assert_output_contains 'All 2 services are up and running'
}

@test "start waits through delayed service readiness" {
    export YAMS_DOCKER_PS_STATES=1/2,1/2,2/2
    run_cli start

    [ "$status" -eq 0 ]
    [ "$(wc -l < "$YAMS_SLEEP_LOG")" -eq 2 ]
    assert_output_contains 'All 2 services are up and running'
}

@test "start times out when a service never becomes ready" {
    export YAMS_DOCKER_PS_STATES=1/2
    run_cli start

    [ "$status" -eq 1 ]
    [ "$(wc -l < "$YAMS_SLEEP_LOG")" -eq 60 ]
    assert_output_contains 'Not all services started within 60 seconds'
}

@test "starts only requested services without a global readiness wait" {
    run_cli start radarr sonarr

    [ "$status" -eq 0 ]
    assert_cli_compose_command up -d radarr sonarr
    [ ! -s "$YAMS_SLEEP_LOG" ]
}

@test "reports a start failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=up
    run_cli start radarr

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to start services'
}

@test "stops all services" {
    run_cli stop

    [ "$status" -eq 0 ]
    assert_cli_compose_command stop
    assert_output_contains 'Services stopped successfully'
}

@test "stops requested services as separate arguments" {
    run_cli stop radarr sonarr

    [ "$status" -eq 0 ]
    assert_cli_compose_command stop radarr sonarr
}

@test "reports a stop failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=stop
    run_cli stop radarr

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to stop services: radarr'
}

@test "restarts all services and waits for readiness" {
    export YAMS_DOCKER_PS_STATES=1/2,2/2
    run_cli restart

    [ "$status" -eq 0 ]
    assert_cli_compose_command stop
    assert_cli_compose_command up -d
    [ "$(wc -l < "$YAMS_SLEEP_LOG")" -eq 1 ]
}

@test "restarts only requested services" {
    run_cli restart radarr sonarr

    [ "$status" -eq 0 ]
    assert_cli_compose_command stop radarr sonarr
    assert_cli_compose_command up -d radarr sonarr
    [ ! -s "$YAMS_SLEEP_LOG" ]
}

@test "restart stops after a stop failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=stop
    run_cli restart

    [ "$status" -eq 1 ]
    refute_command "$YAMS_DOCKER_LOG" docker compose \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" up -d
}

@test "restart reports an up failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=up
    run_cli restart radarr

    [ "$status" -eq 1 ]
    assert_cli_compose_command stop radarr
    assert_cli_compose_command up -d radarr
}

@test "status prints Compose status" {
    export YAMS_DOCKER_STATUS_OUTPUT='radarr Up 10 minutes'
    run_cli status

    [ "$status" -eq 0 ]
    assert_cli_compose_command ps
    assert_output_contains 'radarr Up 10 minutes'
}

@test "status reports a Compose failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=ps
    run_cli status

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to check services'
}

@test "destroy cancellation has no side effects" {
    run_cli_input n destroy

    [ "$status" -eq 0 ]
    [ ! -s "$YAMS_DOCKER_LOG" ]
}

@test "destroy confirmation removes containers and volumes but not the named network" {
    run_cli_input y destroy

    [ "$status" -eq 0 ]
    assert_cli_compose_command down -v
    ! grep -Fq $'docker\tnetwork\trm\tyams_network\t' "$YAMS_DOCKER_LOG"
    assert_output_contains 'YAMS services were destroyed'
}

@test "targeted destroy stops and removes only requested services" {
    run_cli_input y destroy radarr sonarr

    [ "$status" -eq 0 ]
    assert_cli_compose_command stop radarr sonarr
    assert_cli_compose_command rm -f -v radarr sonarr
}

@test "destroy reports a Compose failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=down
    run_cli_input y destroy

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to destroy services'
}

@test "container update cancellation does not call Compose" {
    run_cli_input n update-containers

    [ "$status" -eq 0 ]
    assert_output_contains 'Update aborted'
    [ ! -s "$YAMS_DOCKER_LOG" ]
}

@test "container update pulls and restarts services" {
    run_cli_input y update-containers

    [ "$status" -eq 0 ]
    assert_cli_compose_command pull
    assert_cli_compose_command stop
    assert_cli_compose_command up -d
    assert_output_contains 'Containers updated successfully'
}

@test "container update reports a pull failure without restarting" {
    export YAMS_DOCKER_FAIL_ACTIONS=pull
    run_cli_input y update-containers

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to pull containers'
    refute_command "$YAMS_DOCKER_LOG" docker compose \
        -f "$INSTALL_DIR/docker-compose.yaml" \
        -f "$INSTALL_DIR/docker-compose.custom.yaml" stop
}

@test "container update propagates a restart failure" {
    export YAMS_DOCKER_FAIL_ACTIONS=up
    run_cli_input y update-containers

    [ "$status" -eq 1 ]
    assert_cli_compose_command pull
    assert_cli_compose_command stop
    assert_cli_compose_command up -d
    [[ "$output" != *'Containers updated successfully'* ]]
}

@test "VPN check retries endpoints and succeeds for different IPs" {
    export YAMS_LOCAL_IP_RESPONSES=garbage,198.51.100.10
    export YAMS_QBIT_IP_RESPONSES=EMPTY,203.0.113.20
    run_cli check-vpn

    [ "$status" -eq 0 ]
    assert_output_contains 'Your IP: 198.51.100.10'
    assert_output_contains 'qBittorrent IP: 203.0.113.20'
    assert_output_contains 'qBittorrent is masking your IP'
    grep -Fq 'https://api.ipify.org' "$YAMS_CURL_LOG"
    grep -Fq 'https://api.ipify.org' "$YAMS_DOCKER_LOG"
}

@test "VPN check rejects matching IPs" {
    export YAMS_LOCAL_IP_RESPONSES=198.51.100.10
    export YAMS_QBIT_IP_RESPONSES=198.51.100.10
    run_cli check-vpn

    [ "$status" -eq 1 ]
    assert_output_contains 'Your IPs are the same'
}

@test "VPN check reports exhaustion of local IP endpoints" {
    export YAMS_LOCAL_IP_RESPONSES=FAIL,EMPTY,invalid
    run_cli check-vpn

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to get your IP address from any endpoint'
    grep -Fq 'https://checkip.amazonaws.com' "$YAMS_CURL_LOG"
    ! grep -Fq $'docker\texec\tqbittorrent' "$YAMS_DOCKER_LOG"
}

@test "VPN check reports exhaustion of qBittorrent IP endpoints" {
    export YAMS_QBIT_IP_RESPONSES=FAIL,EMPTY,invalid
    run_cli check-vpn

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to get qBittorrent IP from any endpoint'
    grep -Fq 'https://checkip.amazonaws.com' "$YAMS_DOCKER_LOG"
}

@test "backup archive contains configuration and excludes caches" {
    backup_dir="$BATS_TEST_TMPDIR/backup target"
    mkdir -p "$backup_dir" "$INSTALL_DIR/transcoding-temp" "$INSTALL_DIR/config/jellyfin/cache"
    echo keep > "$INSTALL_DIR/config/keep/settings.conf"
    echo skip > "$INSTALL_DIR/transcoding-temp/file"
    echo skip > "$INSTALL_DIR/config/jellyfin/cache/file"

    run_cli backup "$backup_dir"

    [ "$status" -eq 0 ]
    archive="$backup_dir/yams-backup-2026-07-22-1721640000.tar.gz"
    [ -f "$archive" ]
    [ "$(stat -c %a "$archive")" = 600 ]
    assert_cli_compose_command stop
    assert_cli_compose_command start
    run /bin/tar -tzf "$archive"
    [ "$status" -eq 0 ]
    [[ "$output" == *'./config/keep/settings.conf'* ]]
    [[ "$output" == *'./docker-compose.yaml'* ]]
    [[ "$output" == *'./yams'* ]]
    [[ "$output" != *'transcoding-temp'* ]]
    [[ "$output" != *'config/jellyfin/cache'* ]]
}

@test "backup reports a stop failure before archiving" {
    export YAMS_DOCKER_FAIL_ACTIONS=stop
    mkdir "$BATS_TEST_TMPDIR/backup"
    run_cli backup "$BATS_TEST_TMPDIR/backup"

    [ "$status" -eq 1 ]
    assert_output_contains 'Failed to stop services'
    [ ! -s "$YAMS_TAR_LOG" ]
}

@test "backup restarts services after archive creation fails" {
    export YAMS_TAR_FAIL=1
    mkdir "$BATS_TEST_TMPDIR/backup"
    run_cli backup "$BATS_TEST_TMPDIR/backup"

    [ "$status" -eq 1 ]
    assert_cli_compose_command stop
    assert_cli_compose_command start
    assert_output_contains 'Failed to create backup archive'
    [[ "$output" != *'Backup completed successfully'* ]]
}

@test "backup reports a restart failure instead of success" {
    export YAMS_DOCKER_FAIL_ACTIONS=start
    mkdir "$BATS_TEST_TMPDIR/backup"
    run_cli backup "$BATS_TEST_TMPDIR/backup"

    [ "$status" -eq 1 ]
    assert_cli_compose_command stop
    assert_cli_compose_command start
    assert_output_contains 'Failed to restart services'
    [[ "$output" != *'Backup completed successfully'* ]]
}

@test "CLI update uses the v4 raw source and preserves local configuration" {
    make_update_fixture
    expected_dc=$(grep '^readonly DC=' "$CLI")
    expected_install=$(grep '^readonly INSTALL_DIRECTORY=' "$CLI")
    run_cli update-cli

    [ "$status" -eq 0 ]
    grep -Fxq '# downloaded update marker' "$CLI"
    grep -Fxq "$expected_dc" "$CLI"
    grep -Fxq "$expected_install" "$CLI"
    [ -x "$CLI" ]
    bash -n "$CLI"
    grep -Fq 'https://raw.githubusercontent.com/rogsme/yams/v4/src/yams' "$YAMS_CURL_LOG"
    grep -Fq $'sudo\tinstall\t' "$YAMS_SUDO_LOG"
    [ ! -e /tmp/yams_update.sh ]
}

@test "CLI update preserves the current script after a download failure" {
    make_update_fixture
    export YAMS_CURL_FAIL=yams
    before=$(cksum "$CLI")
    run_cli update-cli

    [ "$status" -eq 1 ]
    [ "$(cksum "$CLI")" = "$before" ]
    assert_output_contains 'Failed to download'
}

@test "CLI update rejects a script with invalid Bash syntax" {
    make_update_fixture
    echo 'if broken' >> "$YAMS_CURL_UPDATE_FILE"
    before=$(cksum "$CLI")
    run_cli update-cli

    [ "$status" -eq 1 ]
    [ "$(cksum "$CLI")" = "$before" ]
    ! grep -Fq $'sudo\tinstall\t' "$YAMS_SUDO_LOG"
}

@test "CLI update rejects a script without configuration placeholders" {
    make_update_fixture
    sed -i '/^readonly DC=/d' "$YAMS_CURL_UPDATE_FILE"
    before=$(cksum "$CLI")
    run_cli update-cli

    [ "$status" -eq 1 ]
    [ "$(cksum "$CLI")" = "$before" ]
    ! grep -Fq $'sudo\tinstall\t' "$YAMS_SUDO_LOG"
}
