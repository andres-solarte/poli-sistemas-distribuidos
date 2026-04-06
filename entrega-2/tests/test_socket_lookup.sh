#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_socket_lookup] Verificando consulta socket cliente-servidor..."

vagrant ssh nfs-server -c "pkill -f 'sd.entrega2.PhoneLookupServer' || true" >/dev/null 2>&1 || true
vagrant ssh nfs-server -c "nohup bash -lc 'cd /vagrant/app/server && ./run_server.sh 5050' >/tmp/phone_server.log 2>&1 &" >/dev/null

sleep 6

tmp_out="$(mktemp)"
cleanup() {
  rm -f "$tmp_out"
  vagrant ssh nfs-server -c "pkill -f 'sd.entrega2.PhoneLookupServer' || true" >/dev/null 2>&1 || true
}
trap cleanup EXIT

run_on_client '
  set -euo pipefail
  printf "3001001001\n3001001999\nn\n" | bash -lc "cd /vagrant/app/client && ./run_client.sh 192.168.56.10 5050"
' >"$tmp_out"

grep -q "Ana Torres" "$tmp_out"
grep -q "Persona dueña de ese número telefónico no existe" "$tmp_out"

pass "Socket lookup OK"
