#!/usr/bin/env bash
set -euo pipefail

#--------------------------------------------------------------------
# test_nfs_export
#--------------------------------------------------------------------
# Valida que el servidor NFSv4 exporte el directorio requerido:
# - Directorio exportado: /srv/nfs
# - Uso NFSv4 con fsid=0 (pseudo-root)
# - Export permitido para el cliente con IP fija: 192.168.56.11
#
# Criterio de aprobacion:
# - `sudo exportfs -v` contiene:
#   - "/srv/nfs"
#   - "fsid=0"
#   - la entrada asociada al cliente (IP permitida)
#--------------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_nfs_export] Verificando export en servidor..."

run_on_server "
  set -euo pipefail
  sudo exportfs -v | grep -Fq '/srv/nfs'
  sudo exportfs -v | grep -Fq 'fsid=0'
  sudo exportfs -v | grep -Fq '${CLIENT_IP}'
"

pass "NFS export (servidor) OK"

