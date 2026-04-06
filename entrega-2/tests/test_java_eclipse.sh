#!/usr/bin/env bash
set -euo pipefail

#--------------------------------------------------------------------
# test_java_eclipse
#--------------------------------------------------------------------
# Valida herramientas de desarrollo requeridas en ambas VMs:
# - Java: OpenJDK 17 presente
# - Eclipse: ejecutable `eclipse` disponible y ejecutable
#
# Criterio de aprobacion:
# - `java -version` contiene "openjdk version \"17\""
# - `command -v eclipse` existe y apunta a un binario ejecutable
#--------------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

check_java() {
  local vm_name="$1"
  echo "[test_java_eclipse:$vm_name] Java..."
  vagrant ssh "$vm_name" -c 'java -version 2>&1 | grep -q "openjdk version \"17"' >/dev/null
}

check_eclipse() {
  local vm_name="$1"
  echo "[test_java_eclipse:$vm_name] Eclipse..."
  vagrant ssh "$vm_name" -c 'command -v eclipse >/dev/null 2>&1 && test -x "$(readlink -f "$(command -v eclipse)")"' >/dev/null
}

check_java "$VAGRANT_VM_SERVER"
check_java "$VAGRANT_VM_CLIENT"
check_eclipse "$VAGRANT_VM_SERVER"
check_eclipse "$VAGRANT_VM_CLIENT"

pass "Java (17) y Eclipse OK"

