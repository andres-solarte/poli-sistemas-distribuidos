#!/usr/bin/env bash
set -euo pipefail

#--------------------------------------------------------------------
# test_nfs_mount
#--------------------------------------------------------------------
# Valida que el cliente monte automaticamente el recurso NFSv4:
# - Punto de montaje: /mnt/nfs
# - Tipo de sistema: nfs4
# - Fuente: 192.168.56.10:/ (pseudo-root exportado por el servidor)
# - Debe existir la entrada correspondiente en /etc/fstab
#
# Criterio de aprobacion:
# - `mount` muestra el montaje NFSv4 en /mnt/nfs
# - /etc/fstab contiene la linea NFSv4 esperada
#--------------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_nfs_mount] Verificando montaje NFSv4 en cliente..."

run_on_client '
  set -euo pipefail
  mount | grep -E "on /mnt/nfs type nfs4" >/dev/null
  grep -qE "^'"$SERVER_IP"':/ /mnt/nfs[[:space:]]+nfs4[[:space:]]" /etc/fstab
'

pass "NFSv4 mount (cliente) OK"

