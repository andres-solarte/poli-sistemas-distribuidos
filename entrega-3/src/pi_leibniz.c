#include <mpi.h>
#include <stdio.h>
#include <math.h>

#define ITERACIONES 9000000000LL // 9x10^9 iteraciones (usamos LL para long long int)

/**
 * Cálculo de PI usando la serie de Leibniz con OpenMPI.
 * La fórmula es: PI/4 = 1 - 1/3 + 1/5 - 1/7 + ...
 */
int main(int argc, char** argv) {
    int rank, size;
    long long int i;
    double suma_parcial = 0.0;
    double suma_total = 0.0;
    double pi_calculado = 0.0;
    double tiempo_inicio, tiempo_fin;

    // 1. Inicializar el entorno MPI
    MPI_Init(&argc, &argv);

    // 2. Obtener el rango del proceso y el tamaño del comunicador
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // 3. Empezar a medir el tiempo en todos los procesos
    // Usamos una barrera para que todos empiecen a contar al mismo tiempo
    MPI_Barrier(MPI_COMM_WORLD);
    tiempo_inicio = MPI_Wtime();

    // 4. Determinar la carga de trabajo de este proceso
    // Dividimos las iteraciones totales entre el número de procesos
    long long int iteraciones_por_proceso = ITERACIONES / size;
    long long int inicio = rank * iteraciones_por_proceso;
    long long int fin = inicio + iteraciones_por_proceso;
    
    // Si la división no es exacta, el último proceso hace el resto
    if (rank == size - 1) {
        fin = ITERACIONES;
    }

    // 5. Cálculo local (Serie de Leibniz)
    for (i = inicio; i < fin; i++) {
        // La serie alterna signos: par -> positivo, impar -> negativo
        double termino = 1.0 / (2.0 * i + 1.0);
        if (i % 2 != 0) {
            termino = -termino;
        }
        suma_parcial += termino;
    }

    // 6. Reducir todos los resultados parciales al proceso 0
    // MPI_Reduce combina los valores de 'suma_parcial' usando la operación MPI_SUM
    // y guarda el resultado en 'suma_total' solo en el proceso raíz (0)
    MPI_Reduce(&suma_parcial, &suma_total, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    // 7. Parar de medir el tiempo
    tiempo_fin = MPI_Wtime();

    // 8. El proceso 0 imprime los resultados
    if (rank == 0) {
        pi_calculado = suma_total * 4.0; // Multiplicamos por 4 según la fórmula
        double error = fabs(pi_calculado - M_PI);
        double tiempo_ejecucion = tiempo_fin - tiempo_inicio;

        printf("-------------------------------------------------\n");
        printf("Cálculo de PI con método de Leibniz\n");
        printf("Número de procesos: %d\n", size);
        printf("Iteraciones totales: %lld\n", ITERACIONES);
        printf("PI Calculado: %.15f\n", pi_calculado);
        printf("Valor M_PI  : %.15f\n", M_PI);
        printf("Error       : %.15f\n", error);
        printf("Tiempo      : %f segundos\n", tiempo_ejecucion);
        printf("-------------------------------------------------\n");
    }

    // 9. Finalizar MPI
    MPI_Finalize();
    return 0;
}
