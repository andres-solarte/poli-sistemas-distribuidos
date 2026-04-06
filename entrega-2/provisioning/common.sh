#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[common] apt update && install Java/Eclipse deps"
apt-get update -y
# Paquetes base + dependencias de Java/Eclipse
apt-get install -y \
  ca-certificates curl wget tar unzip \
  openjdk-17-jdk

ECLIPSE_BASE="/opt/eclipse"

# Puedes ajustar la version si tu curso especifica una en particular.
ECLIPSE_VERSION="${ECLIPSE_VERSION:-2024-03}"
ECLIPSE_URL="${ECLIPSE_URL:-https://download.eclipse.org/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-java-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz}"

echo "[common] Install Eclipse (apt primero, fallback a descarga)"

# 1) Intento con paquete del sistema (si está disponible en la distro/imagen)
if ! command -v eclipse >/dev/null 2>&1; then
  apt-get install -y eclipse || true
fi

if command -v eclipse >/dev/null 2>&1; then
  echo "[common] Eclipse instalado via apt"
  exit 0
fi

# 2) Si no hay paquete, instalamos dependencias GUI mínimas (sin romper si faltan)
apt-get install -y \
  libgtk-3-0 libnss3 libxss1 libxtst6 \
  libatk-bridge2.0-0 libatk1.0-0 libcairo2 libpango-1.0-0 libpangocairo-1.0-0 \
  fonts-dejavu-core || true

# 2) Fallback: descarga del tarball oficial
echo "[common] Download Eclipse -> ${ECLIPSE_URL}"
mkdir -p "${ECLIPSE_BASE}"

tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "${tmp_dir}"; }
trap cleanup EXIT

# Descarga robusta (por posibles fallos temporales de red/CDN)
ECLIPSE_URLS=(
  "${ECLIPSE_URL}"
  "https://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-java-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz"
)

download_ok=false
for url in "${ECLIPSE_URLS[@]}"; do
  for attempt in 1 2 3; do
    echo "[common] wget attempt ${attempt}/3: ${url}"
    if wget -qO "${tmp_dir}/eclipse.tar.gz" "${url}"; then
      download_ok=true
      break 2
    fi
    sleep 5
  done
done

if [[ "${download_ok}" != "true" ]]; then
  echo "[common] ERROR: no se pudo descargar Eclipse desde las URLs definidas" >&2
  exit 1
fi

# Limpia cualquier extracción parcial
rm -rf "${ECLIPSE_BASE}/eclipse" || true
tar -xzf "${tmp_dir}/eclipse.tar.gz" -C "${ECLIPSE_BASE}"

# Detecta el ejecutable real (evita confundir directorios con binarios)
ECLIPSE_TARGET=""
if [[ -f "${ECLIPSE_BASE}/eclipse/eclipse/eclipse" && -x "${ECLIPSE_BASE}/eclipse/eclipse/eclipse" ]]; then
  ECLIPSE_TARGET="${ECLIPSE_BASE}/eclipse/eclipse/eclipse"
elif [[ -f "${ECLIPSE_BASE}/eclipse/eclipse" && -x "${ECLIPSE_BASE}/eclipse/eclipse" ]]; then
  ECLIPSE_TARGET="${ECLIPSE_BASE}/eclipse/eclipse"
elif [[ -f "${ECLIPSE_BASE}/eclipse" && -x "${ECLIPSE_BASE}/eclipse" ]]; then
  ECLIPSE_TARGET="${ECLIPSE_BASE}/eclipse"
fi

if [[ -z "${ECLIPSE_TARGET}" ]]; then
  echo "[common] ERROR: No se encontró el ejecutable de Eclipse luego de extraer el tarball" >&2
  exit 1
fi

ln -sf "${ECLIPSE_TARGET}" /usr/local/bin/eclipse

echo "[common] Java/Eclipse listo"
