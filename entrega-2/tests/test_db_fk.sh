#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_db_fk] Verificando llave foranea personas(dir_ciud_id)->ciudades(ciud_id)..."

run_on_server '
  set -euo pipefail
  result="$(sudo mysql -Nse "
    SELECT COUNT(*)
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = '\''sd_entrega2'\''
      AND TABLE_NAME = '\''personas'\''
      AND COLUMN_NAME = '\''dir_ciud_id'\''
      AND REFERENCED_TABLE_NAME = '\''ciudades'\''
      AND REFERENCED_COLUMN_NAME = '\''ciud_id'\'';
  ")"
  test "${result}" -ge 1
'

pass "Llave foranea OK"
