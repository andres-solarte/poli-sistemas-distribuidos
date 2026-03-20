# Entrega 1 - Vagrant + NFSv4 (Servidor/Cliente)

Este proyecto automatiza (Infraestructura como Código) el despliegue de **dos VMs** con **Vagrant + VirtualBox** y configura **NFSv4** para que el **cliente** monte automáticamente el recurso exportado por el **servidor**.

## Arquitectura

- **VM 1: `nfs-server`**
  - Sistema: Ubuntu Server (la box depende de la arquitectura del host)
  - Box (segun arquitectura):
    - `cloudicio/ubuntu-server` en hosts `arm64`/`aarch64`
    - `ubuntu/jammy64` en hosts `x86_64`
  - Recursos: `1 CPU`, `2048MB RAM`, disco primario `50GB`
  - Red privada (IP fija): `192.168.56.10`
  - Rol: Servidor NFSv4
  - Export:
    - Directorio exportado: `/srv/nfs`
    - Configuración NFSv4: pseudo-root con `fsid=0` (export del tipo `server:/`)
    - Acceso restringido al cliente `192.168.56.11`

- **VM 2: `nfs-client`**
  - Sistema: Ubuntu Server (la box depende de la arquitectura del host)
  - Box (segun arquitectura):
    - `cloudicio/ubuntu-server` en hosts `arm64`/`aarch64`
    - `ubuntu/jammy64` en hosts `x86_64`
  - Recursos: `1 CPU`, `2048MB RAM`, disco primario `50GB`
  - Red privada (IP fija): `192.168.56.11`
  - Rol: Cliente NFSv4
  - Montaje automático:
    - Punto de montaje: `/mnt/nfs`
    - Tipo: `nfs4`
    - Fuente: `192.168.56.10:/` (pseudo-root exportado por el servidor)
    - Se registra en `/etc/fstab` para que quede persistente tras reinicios

## Estructura del repositorio

- `Vagrantfile`: define y provisiona ambas VMs.
- `provisioning/`
  - `common.sh`: instala `Java` y `Eclipse`.
  - `nfs_server.sh`: instala/configura el servidor NFSv4 y crea el export.
  - `nfs_client.sh`: configura el cliente NFSv4 y monta automáticamente via `fstab`.
- `tests/`
  - Scripts de validación del despliegue (NFS export/mount, IPs, recursos, Java/Eclipse).

## Flujo recomendado (paso a paso)

1. Iniciar el entorno:
```bash
vagrant up
```

2. (Opcional) Verificar manualmente:
```bash
vagrant status
vagrant ssh nfs-server -c "sudo exportfs -v"
vagrant ssh nfs-client -c "mount | grep /mnt/nfs"
```

3. Ejecutar pruebas:
```bash
bash tests/run_all.sh
```

4. Apagar o eliminar el entorno al terminar:
```bash
vagrant halt
```

Si necesitas dejarlo completamente limpio (eliminar VMs/discos asociados):
```bash
vagrant destroy -f
```

## Dependencias (requisitos en la máquina host)

Para ejecutar el proyecto y las pruebas necesitas:

- `VirtualBox` instalado y funcionando correctamente.
- `Vagrant` instalado (versión reciente).
- Conectividad a internet para:
  - descargar la `box` de Vagrant (según arquitectura del host),
  - descargar paquetes del `apt` dentro de las VMs,
  - y descargar Eclipse si el paquete de `apt` no está disponible en el box.
- Recursos mínimos sugeridos en la host para que el aprovisionamiento no falle:
  - al menos `4GB` de RAM y espacio de disco libre suficiente (las VMs usan discos virtuales de `50GB` cada una).

## Soporte para AMD64

El `Vagrantfile` detecta la arquitectura del host:
- En hosts `arm64`/`aarch64` usa `cloudicio/ubuntu-server` (arm64).
- En hosts `x86_64` usa `ubuntu/jammy64` (amd64).

Nota: para verificar la parte AMD64 necesitas ejecutarlo en una máquina x86_64. En un host ARM64 con VirtualBox no se pueden arrancar guests x86_64 (por limitación de plataforma).

Incluye validaciones de:
- IP privada estática en ambas VMs (`192.168.56.10` y `192.168.56.11`)
- Export NFSv4 en el servidor (incluye `fsid=0` y el export `/srv/nfs`)
- Montaje NFSv4 automático en el cliente (`/mnt/nfs` y persistencia en `/etc/fstab`)
- Recursos mínimos (CPU, RAM y tamaño de disco en el guest)
- Java (OpenJDK 17) y Eclipse instalados y ejecutables

> Recomendación: si cambias el `Vagrantfile` o los scripts de aprovisionamiento, usa `vagrant destroy -f` y luego `vagrant up` para reaprovisionar desde cero.

