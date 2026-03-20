#!/usr/bin/env bash
set -euo pipefail

VAGRANT_VM_SERVER="nfs-server"
VAGRANT_VM_CLIENT="nfs-client"
SERVER_IP="192.168.56.10"
CLIENT_IP="192.168.56.11"

run_on_server() {
  vagrant ssh "${VAGRANT_VM_SERVER}" -c "$1"
}

run_on_client() {
  vagrant ssh "${VAGRANT_VM_CLIENT}" -c "$1"
}

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

pass() {
  echo "PASS: $1"
}

