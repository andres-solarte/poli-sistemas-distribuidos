# Entrega Final - Semana 7: Clúster HPC con Vagrant y OpenMPI

**Materia:** Sistemas Distribuidos - Politécnico Grancolombiano

Este proyecto implementa un Clúster de Computación de Alto Rendimiento (HPC) de 3 nodos utilizando máquinas virtuales provistas por Vagrant y VirtualBox, con el objetivo de ejecutar procesamiento paralelo distribuido mediante OpenMPI.

## 1. Descripción del Proyecto

El proyecto consta de la configuración automatizada de una infraestructura virtual de tres nodos (`master`, `nodo-0`, `nodo-1`) comunicados a través de una red privada (`192.168.56.0/24`). El clúster cuenta con:
- OpenMPI instalado en todos los nodos.
- Una carpeta compartida por NFS para centralizar el código y los binarios compilados.
- Acceso SSH sin contraseña mediante llaves RSA para comunicación transparente entre MPI y los nodos.
- Dos programas en C paralelizados: un clásico "Hola Mundo" y un estimador intensivo del número PI usando la serie de Leibniz.

## 2. Requisitos Previos

- **Vagrant** (v2.x o superior)
- **VirtualBox** (v6.1 o superior)
- Git (Opcional, para clonar el proyecto)

## 3. Topología de Red LAN

```text
                  +--------------------------+
                  |         Internet         |
                  +-------------+------------+
                                | (NAT)
                                v
+-------------------------------------------------------------+
| Clúster HPC                                                 |
|                                                             |
|   +---------------+     +---------------+   +---------------+
|   |    master     |     |    nodo-0     |   |    nodo-1     |
|   |---------------|     |---------------|   |---------------|
|   | 192.168.56.10 |<--->| 192.168.56.11 |<->| 192.168.56.12 |
|   |   (NFS Server)|     | (NFS Client)  |   | (NFS Client)  |
|   +---------------+     +---------------+   +---------------+
|          |                      |                   |
|          +----------------------+-------------------+
|                  Red Privada "numeroPI"
+-------------------------------------------------------------+
```

## 4. Instrucciones de Despliegue

1. Abre una terminal y navega a la carpeta raíz de este proyecto (`entrega-3`).
2. Levanta la infraestructura ejecutando:
   ```bash
   vagrant up
   ```
   *Nota: La primera vez descargará la imagen `ubuntu/focal64` y el proceso puede tardar unos minutos. Los scripts de aprovisionamiento instalarán dependencias y configurarán la red.*

3. Para acceder al nodo maestro, usa:
   ```bash
   vagrant ssh master
   ```

## 5. Compilación y Ejecución

Una vez dentro de la máquina `master` a través de SSH, conéctate como el usuario de MPI (esto es importante para evitar permisos de root en mpirun):

```bash
sudo su - mpiuser
cd /vagrant/scripts
```
*(Nota: la carpeta compartida por Vagrant `/vagrant` apunta al directorio `entrega-3` donde están los scripts).*

### Compilar los programas
Asegúrate de dar permisos de ejecución a los scripts:
```bash
chmod +x compilar.sh ejecutar_holamundo.sh ejecutar_pi.sh
./compilar.sh
```
Esto creará los binarios y los ubicará en la carpeta compartida NFS `/home/mpiuser/mpi/`.

### Ejecutar Hola Mundo
```bash
./ejecutar_holamundo.sh
```
Observarás cómo diferentes procesos responden desde las distintas máquinas virtuales.

### Ejecutar Cálculo de PI
```bash
./ejecutar_pi.sh
```
Este script ejecutará el programa en 1, 2 y 3 procesos, consolidará los tiempos de procesamiento y generará un archivo `resultados.txt` en la raíz de `entrega-3/`.

## 6. Detalles Técnicos

### Método de Leibniz
El número $\pi$ se puede aproximar mediante la serie infinita descubierta por Gottfried Leibniz en el siglo XVII:

$$\frac{\pi}{4} = 1 - \frac{1}{3} + \frac{1}{5} - \frac{1}{7} + \frac{1}{9} - ... $$

Nuestro programa realiza 9,000,000,000 iteraciones para obtener un nivel alto de precisión, lo que consume bastante poder de cómputo.

### Paralelización con MPI
1. **Distribución del Trabajo**: A través de `MPI_Comm_rank` y `MPI_Comm_size`, identificamos cuántos nodos existen y cuál es el ID del actual. Dividimos las $9 \times 10^9$ iteraciones en bloques iguales. Por ejemplo, si hay 3 procesos, cada uno hace $3 \times 10^9$ iteraciones.
2. **Cálculo Local**: Cada nodo procesa el ciclo for para su propio rango de índices asíncronamente y acumula una "suma parcial".
3. **Consolidación (Reduce)**: Utilizamos `MPI_Reduce` con el operador `MPI_SUM`. El nodo maestro suma las respuestas de todos los nodos.
4. **Finalización**: Se toma el tiempo usando `MPI_Wtime()`, y el maestro finaliza la ecuación multiplicando el resultado sumado por 4.

## 7. Análisis Esperado (Speedup)
Al evaluar `resultados.txt`, observarás lo siguiente:
- Tiempo con 1 Proceso: $T_1$
- Tiempo con 2 Procesos: $T_2$ (debería ser aproximadamente $T_1/2$)
- Tiempo con 3 Procesos: $T_3$ (debería ser aproximadamente $T_1/3$)

La eficiencia ($E$) y el Speedup ($S$) demostrarán que la paralelización reduce linealmente (en sistemas ideales) los tiempos de cómputo: $S = \frac{T_1}{T_N}$.

## 8. Comandos MPI Útiles
- `mpicc`: Compilador de C modificado para enlazar las librerías de OpenMPI automáticamente.
- `mpirun` o `mpiexec`: Lanzador de tareas paralelas. Ejemplo: `mpirun -np 4 --hostfile my_hosts ./app` lanza 4 procesos distribuidos según dicte el archivo de hosts.

## 9. Troubleshooting
- **Falla mpirun con SSH sin contraseña**: Comprueba que las llaves se generaron correctamente:
  ```bash
  ssh nodo-0 date
  ```
  Si te pide confirmación `yes/no` o contraseña, revisa los permisos de `~/.ssh/authorized_keys` (deben ser 600).
- **No encuentra el binario**: Asegúrate de que NFS está montado correctamente en los nodos. `df -h` debería mostrar `/home/mpiuser/mpi` montado desde la IP del master.
