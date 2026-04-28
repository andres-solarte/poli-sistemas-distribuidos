#!/bin/bash
set -e

DIR_BIN="/home/mpiuser/mpi"
HOSTFILE="$DIR_BIN/hostfile"
PROGRAMA="$DIR_BIN/pi_leibniz"
ARCHIVO_RESULTADOS="$(dirname "$0")/../resultados.txt"

echo "=========================================="
echo " EJECUCIÓN: CÁLCULO DE PI (Leibniz)"
echo "=========================================="

if [ ! -f "$PROGRAMA" ]; then
    echo "Error: Binario no encontrado. Ejecuta compilar.sh primero."
    exit 1
fi

echo "Iniciando pruebas de rendimiento..."
echo "Guardando resultados en $ARCHIVO_RESULTADOS"

# Inicializar archivo de resultados
echo "RESULTADOS CÁLCULO DE PI (9x10^9 iteraciones)" > "$ARCHIVO_RESULTADOS"
echo "==========================================================" >> "$ARCHIVO_RESULTADOS"

# Función para extraer el tiempo de la salida de nuestro programa C
extraer_tiempo() {
    local salida="$1"
    echo "$salida" | grep "Tiempo" | awk '{print $3}'
}

# 1 Proceso
echo -e "\n---> Ejecutando con 1 proceso..."
out_1p=$(mpirun --hostfile "$HOSTFILE" -np 1 "$PROGRAMA")
echo "$out_1p"
t_1p=$(extraer_tiempo "$out_1p")
echo "Tiempo con 1 proceso: $t_1p s" >> "$ARCHIVO_RESULTADOS"

# 2 Procesos
echo -e "\n---> Ejecutando con 2 procesos..."
out_2p=$(mpirun --hostfile "$HOSTFILE" -np 2 "$PROGRAMA")
echo "$out_2p"
t_2p=$(extraer_tiempo "$out_2p")
echo "Tiempo con 2 procesos: $t_2p s" >> "$ARCHIVO_RESULTADOS"

# 3 Procesos
echo -e "\n---> Ejecutando con 3 procesos..."
out_3p=$(mpirun --hostfile "$HOSTFILE" -np 3 "$PROGRAMA")
echo "$out_3p"
t_3p=$(extraer_tiempo "$out_3p")
echo "Tiempo con 3 procesos: $t_3p s" >> "$ARCHIVO_RESULTADOS"

# Añadir tabla comparativa final al archivo
echo "==========================================================" >> "$ARCHIVO_RESULTADOS"
echo "| N° Procesos | Tiempo (s) |" >> "$ARCHIVO_RESULTADOS"
echo "|-------------|------------|" >> "$ARCHIVO_RESULTADOS"
echo "|      1      |   $t_1p    |" >> "$ARCHIVO_RESULTADOS"
echo "|      2      |   $t_2p    |" >> "$ARCHIVO_RESULTADOS"
echo "|      3      |   $t_3p    |" >> "$ARCHIVO_RESULTADOS"
echo "==========================================================" >> "$ARCHIVO_RESULTADOS"

echo -e "\nPruebas finalizadas. Revisa resultados.txt para ver la tabla comparativa."
