#!/usr/bin/env bash
set -euo pipefail

#--------------------------------------------------------------------
# test_ip_static
#--------------------------------------------------------------------
# Valida que las dos VMs tengan una IP privada fija en la red provista:
# - Servidor:  192.168.56.10
# - Cliente:   192.168.56.11
#
# Criterio de aprobacion:
# - Ambas IPs aparecen en `ip -4 addr show` dentro de cada VM.
#--------------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DIR}/common.sh"

echo "[test_ip_static] Verificando IPs privadas estáticas..."

run_on_server '
  ip -4 addr show | grep -q "'"$SERVER_IP"'"
'

run_on_client '
  ip -4 addr show | grep -q "'"$CLIENT_IP"'"
'

pass "IPs estáticas OK"

