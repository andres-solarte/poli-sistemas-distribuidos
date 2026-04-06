#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_db_seed] Verificando base de datos y datos de prueba..."

run_on_server '
  set -euo pipefail
  test "$(sudo mysql -Nse "USE sd_entrega2; SELECT COUNT(*) FROM ciudades;")" -eq 5
  test "$(sudo mysql -Nse "USE sd_entrega2; SELECT COUNT(*) FROM personas;")" -eq 5
  sudo mysql -Nse "USE sd_entrega2; DESCRIBE ciudades;" | grep -q "^ciud_id"
  sudo mysql -Nse "USE sd_entrega2; DESCRIBE personas;" | grep -q "^dir_tel"
'

pass "BD y seed data OK"
