#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[nfs-server] Installing NFSv4 server"
apt-get update -y
apt-get install -y nfs-kernel-server

CLIENT_ALLOWED_IP="${1:-*}"
echo "[nfs-server] Export permitido para: ${CLIENT_ALLOWED_IP}"

EXPORT_DIR="/srv/nfs"
mkdir -p "${EXPORT_DIR}"

# Evita problemas si el directorio estaba vacío o con permisos heredados.
chmod 0777 "${EXPORT_DIR}"

# NFSv4 recomienda exportar un pseudo-root con fsid=0.
cat >/etc/exports <<EOF
${EXPORT_DIR} ${CLIENT_ALLOWED_IP}(rw,sync,no_subtree_check,fsid=0,insecure,no_root_squash)
EOF

exportfs -ra

echo "[nfs-server] Starting services"
systemctl enable --now nfs-kernel-server
systemctl enable --now rpcbind 2>/dev/null || true

echo "[nfs-server] NFSv4 listo"
