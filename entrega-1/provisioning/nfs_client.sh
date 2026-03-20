#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

SERVER_IP="${1:-}"
if [[ -z "${SERVER_IP}" ]]; then
  echo "Usage: $0 <server_ip>"
  exit 1
fi

echo "[nfs-client] Installing NFS client"
apt-get update -y
apt-get install -y nfs-common

MOUNT_POINT="/mnt/nfs"
mkdir -p "${MOUNT_POINT}"

# Montaje de NFSv4 (pseudo-root exportado por el servidor)
FSTAB_LINE="${SERVER_IP}:/ ${MOUNT_POINT} nfs4 defaults,_netdev 0 0"

if ! grep -qE "^[#[:space:]]*${SERVER_IP}:/[[:space:]]+${MOUNT_POINT}[[:space:]]+nfs4" /etc/fstab; then
  echo "${FSTAB_LINE}" >> /etc/fstab
fi

echo "[nfs-client] Mounting NFSv4"
mount -a -t nfs4 || true

# Reintentos por posible condición de carrera entre VMs
ok=false
for _ in {1..20}; do
  if mount -t nfs4 "${SERVER_IP}:/" "${MOUNT_POINT}" 2>/dev/null; then
    ok=true
    break
  fi
  sleep 2
done

if [[ "${ok}" != "true" ]]; then
  echo "[nfs-client] WARNING: no se pudo montar ${SERVER_IP}:/ en ${MOUNT_POINT}" >&2
fi

echo "[nfs-client] NFSv4 listo"
