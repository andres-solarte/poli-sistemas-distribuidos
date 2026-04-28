#include <mpi.h>
#include <stdio.h>

/**
 * Programa Clásico "Hola Mundo" con OpenMPI.
 * Este programa inicializa el entorno MPI, obtiene el ID (rank) del proceso actual,
 * el número total de procesos (size) y el nombre de la máquina (hostname) donde se ejecuta.
 */
int main(int argc, char** argv) {
    // Inicializar el entorno MPI. Debe ser la primera función MPI en llamarse.
    MPI_Init(&argc, &argv);

    // Obtener el número total de procesos en el comunicador por defecto (MPI_COMM_WORLD)
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Obtener el identificador (rango) del proceso actual
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Obtener el nombre del host donde se está ejecutando este proceso
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Imprimir el mensaje de "Hola Mundo" con los datos correspondientes
    printf("Hola Mundo desde el proceso %d de %d en %s\n", world_rank, world_size, processor_name);

    // Finalizar el entorno MPI. Limpia todos los estados y recursos de MPI.
    MPI_Finalize();
    
    return 0;
}
