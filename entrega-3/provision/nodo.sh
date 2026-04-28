#!/bin/bash
set -e

echo "=== INICIANDO APROVISIONAMIENTO DEL NODO ==="

# 1. Actualizar el sistema
echo "-> Actualizando repositorios..."
apt-get update && apt-get upgrade -y

# 2. Instalar OpenMPI y herramientas de desarrollo
echo "-> Instalando OpenMPI, dependencias y cliente NFS..."
apt-get install -y openmpi-bin openmpi-common libopenmpi-dev
apt-get install -y gcc make vim net-tools iputils-ping
apt-get install -y nfs-common

# 3. Configurar /etc/hosts
echo "-> Configurando /etc/hosts..."
cat /tmp/hosts > /etc/hosts

# 4. Crear usuario 'mpiuser' (Debe tener el mismo UID 1500)
echo "-> Creando usuario mpiuser..."
if id "mpiuser" &>/dev/null; then
    echo "El usuario mpiuser ya existe."
else
    useradd -m -u 1500 -s /bin/bash mpiuser
    echo "mpiuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/mpiuser
fi

# 5. Configurar SSH sin contraseña para mpiuser (autorizar la clave del master)
# Como la clave se genera en el master, para que Vagrant up en paralelo no falle,
# es posible que la clave pública aún no esté lista. Hay varias formas de hacerlo.
# La más sencilla con Vagrant es crear un par de claves fijas, o dejar que el NFS 
# comparta la clave pública. Como /home/mpiuser/mpi está compartido, haremos un 
# enlace o copiaremos la authorized_keys cuando se conecte, o configuraremos un 
# par de claves predefinidas en provision/.
#
# Para este laboratorio, vamos a copiar la clave pública del master. Como las VMs
# pueden arrancar asíncronamente, lo mejor es compartir el /home/mpiuser/.ssh via NFS?
# NO, SSH es quisquilloso con permisos. 
# Crearemos un script de sincronización o asumiremos arranque secuencial.
# Vamos a habilitar SSH temporalmente con password para mpiuser o inyectar las claves.

echo "-> Configurando SSH..."
su - mpiuser -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

# Desactivar la verificación estricta de host
cat << 'EOF' > /home/mpiuser/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
chown mpiuser:mpiuser /home/mpiuser/.ssh/config
chmod 600 /home/mpiuser/.ssh/config

# 6. Montar NFS desde el master
echo "-> Montando NFS /home/mpiuser/mpi..."
mkdir -p /home/mpiuser/mpi
chown mpiuser:mpiuser /home/mpiuser/mpi

# Agregar a fstab para persistencia
echo "192.168.56.10:/home/mpiuser/mpi  /home/mpiuser/mpi  nfs  auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab

# Montar ahora
mount -a

# Ahora que está montado el NFS, el master debería dejar su llave pública allí
# Crearemos un bucle de espera para obtener la authorized_keys del master.
echo "-> Esperando clave publica del master vía NFS..."
for i in {1..30}; do
    if [ -f /home/mpiuser/mpi/master_key.pub ]; then
        cat /home/mpiuser/mpi/master_key.pub > /home/mpiuser/.ssh/authorized_keys
        chmod 600 /home/mpiuser/.ssh/authorized_keys
        chown mpiuser:mpiuser /home/mpiuser/.ssh/authorized_keys
        echo "Clave importada con éxito."
        break
    fi
    echo "Esperando 5s..."
    sleep 5
done

echo "=== APROVISIONAMIENTO DEL NODO COMPLETADO ==="
