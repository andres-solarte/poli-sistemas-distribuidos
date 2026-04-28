#!/bin/bash
set -e # Detiene el script si ocurre algún error

echo "======================================"
echo " COMPILANDO PROGRAMAS MPI"
echo "======================================"

# Directorios
DIR_SRC="$(dirname "$0")/../src"
DIR_BIN="/home/mpiuser/mpi"

# Crear directorio compartido si no existe localmente (por si acaso)
mkdir -p "$DIR_BIN"

# Compilar Hola Mundo
echo "-> Compilando holamundo.c..."
mpicc -o "$DIR_BIN/holamundo" "$DIR_SRC/holamundo.c"
echo "[OK] holamundo compilado exitosamente."

# Compilar cálculo de PI (Leibniz)
# Se usa -O2 para optimización de código y -lm para enlazar la librería matemática <math.h>
echo "-> Compilando pi_leibniz.c..."
mpicc -O2 -o "$DIR_BIN/pi_leibniz" "$DIR_SRC/pi_leibniz.c" -lm
echo "[OK] pi_leibniz compilado exitosamente."

echo "======================================"
echo " Compilación finalizada."
echo " Binarios ubicados en: $DIR_BIN"
echo "======================================"
