#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
PORT="${1:-5050}"

mkdir -p "${BUILD_DIR}"

javac \
  -cp "/usr/share/java/mariadb-java-client.jar" \
  -d "${BUILD_DIR}" \
  "${ROOT_DIR}/src/sd/entrega2/PhoneLookupServer.java"

java \
  -cp "${BUILD_DIR}:/usr/share/java/mariadb-java-client.jar" \
  sd.entrega2.PhoneLookupServer "${PORT}"
