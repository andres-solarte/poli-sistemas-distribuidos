#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
HOST="${1:-192.168.56.10}"
PORT="${2:-5050}"

mkdir -p "${BUILD_DIR}"

javac \
  -d "${BUILD_DIR}" \
  "${ROOT_DIR}/src/sd/entrega2/PhoneLookupClient.java"

java \
  -cp "${BUILD_DIR}" \
  sd.entrega2.PhoneLookupClient "${HOST}" "${PORT}"
