#!/bin/bash
set -e # Terminar el script si hay algún error

echo "=== INICIANDO APROVISIONAMIENTO DEL MASTER ==="

# 1. Actualizar el sistema
echo "-> Actualizando repositorios..."
apt-get update && apt-get upgrade -y

# 2. Instalar OpenMPI y herramientas de desarrollo
echo "-> Instalando OpenMPI, gcc, make, vim y herramientas de red..."
apt-get install -y openmpi-bin openmpi-common libopenmpi-dev
apt-get install -y gcc make vim net-tools iputils-ping

# 3. Instalar servidor NFS
echo "-> Instalando servidor NFS..."
apt-get install -y nfs-kernel-server

# 4. Configurar /etc/hosts
echo "-> Configurando /etc/hosts..."
cat /tmp/hosts > /etc/hosts

# 5. Crear usuario 'mpiuser' (UID 1500 para asegurar coherencia en todos los nodos)
echo "-> Creando usuario mpiuser..."
if id "mpiuser" &>/dev/null; then
    echo "El usuario mpiuser ya existe."
else
    useradd -m -u 1500 -s /bin/bash mpiuser
    # Dar permisos de sudo sin password (opcional pero util para debugging)
    echo "mpiuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/mpiuser
fi

# 6. Configurar NFS para compartir /home/mpiuser/mpi
echo "-> Configurando carpeta compartida NFS..."
mkdir -p /home/mpiuser/mpi
chown -R mpiuser:mpiuser /home/mpiuser/mpi

# Exportar la carpeta a la red 192.168.56.0/24
echo "/home/mpiuser/mpi 192.168.56.0/24(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
exportfs -a
systemctl restart nfs-kernel-server

# 7. Configurar SSH sin contraseña para mpiuser
echo "-> Configurando claves SSH..."
su - mpiuser -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
su - mpiuser -c "if [ ! -f ~/.ssh/id_rsa ]; then ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N ''; fi"
su - mpiuser -c "cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys"
su - mpiuser -c "chmod 600 ~/.ssh/authorized_keys"

# Copiar llave pública al NFS para que los nodos la obtengan
cp /home/mpiuser/.ssh/id_rsa.pub /home/mpiuser/mpi/master_key.pub
chown mpiuser:mpiuser /home/mpiuser/mpi/master_key.pub


# Desactivar la verificación estricta de host en SSH para mpiuser para evitar el prompt (yes/no)
cat << 'EOF' > /home/mpiuser/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
chown mpiuser:mpiuser /home/mpiuser/.ssh/config
chmod 600 /home/mpiuser/.ssh/config

# Generar archivo hostfile para mpirun
cat << 'EOF' > /home/mpiuser/mpi/hostfile
master
nodo-0
nodo-1
EOF
chown mpiuser:mpiuser /home/mpiuser/mpi/hostfile

echo "=== APROVISIONAMIENTO DEL MASTER COMPLETADO ==="
