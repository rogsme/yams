#!/usr/bin/env bash

log_command() {
    local log=$1
    shift
    local arg

    for arg in "$@"; do
        printf '%q\t' "$arg" >> "$log"
    done
    printf '\n' >> "$log"
}

csv_contains() {
    [[ ",${1:-}," == *",$2,"* ]]
}

next_response() {
    local name=$1
    local responses=$2
    local counter_file="$YAMS_MOCK_STATE_DIR/$name.count"
    local index=0
    local values=()

    [[ -f "$counter_file" ]] && read -r index < "$counter_file"
    IFS=, read -r -a values <<< "$responses"
    ((index < ${#values[@]})) || index=$((${#values[@]} - 1))
    printf '%s\n' "$((index + 1))" > "$counter_file"

    case "${values[$index]}" in
        FAIL) return 1 ;;
        EMPTY) return 0 ;;
        *) printf '%s\n' "${values[$index]}" ;;
    esac
}
