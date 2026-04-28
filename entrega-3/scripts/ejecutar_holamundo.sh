#!/bin/bash
set -e

DIR_BIN="/home/mpiuser/mpi"
HOSTFILE="$DIR_BIN/hostfile"
PROGRAMA="$DIR_BIN/holamundo"

echo "=========================================="
echo " EJECUCIÓN: HOLA MUNDO (MPI)"
echo "=========================================="

if [ ! -f "$PROGRAMA" ]; then
    echo "Error: Binario no encontrado. Ejecuta compilar.sh primero."
    exit 1
fi

echo -e "\n---> Ejecutando con 1 proceso (Master)..."
mpirun --hostfile "$HOSTFILE" -np 1 "$PROGRAMA"

echo -e "\n------------------------------------------\n"

echo "---> Ejecutando con 2 procesos (Master, Nodo-0)..."
mpirun --hostfile "$HOSTFILE" -np 2 "$PROGRAMA"

echo -e "\n------------------------------------------\n"

echo "---> Ejecutando con 3 procesos (Master, Nodo-0, Nodo-1)..."
mpirun --hostfile "$HOSTFILE" -np 3 "$PROGRAMA"

echo -e "\n=========================================="
echo " Fin de la ejecución."
echo "=========================================="
