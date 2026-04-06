# Entrega 2 (Semana 5) - Socket Cliente/Servidor + Base de Datos

Esta entrega reutiliza la infraestructura de la entrega 1 (dos VMs con Vagrant, Java y Eclipse), y agrega:

- Base de datos relacional en el servidor (`MariaDB`).
- Tablas `ciudades` y `personas` relacionadas por llave foránea.
- Datos de prueba (5 registros en cada tabla).
- Programa `Socket Server` que consulta la BD por número telefónico.
- Programa `Socket Client` que solicita el teléfono por consola y muestra la respuesta.

## Requisitos cubiertos del enunciado

- BD instalada solo en la máquina servidor.
- Tablas con llaves y relación:
  - `ciudades(ciud_id PK, ciud_nombre)`
  - `personas(dir_tel PK, dir_tipo_tel, dir_nombre, dir_direccion, dir_ciud_id FK -> ciudades.ciud_id)`
- 5 datos de prueba por tabla.
- Cliente envía un teléfono y el servidor responde:
  - teléfono, nombre, dirección y ciudad cuando existe.
  - `Persona dueña de ese número telefónico no existe.` cuando no existe.
- Cliente permite al menos dos consultas y luego cierre; servidor queda escuchando.

## Estructura

- `Vagrantfile`: define `nfs-server` y `nfs-client`.
- `provisioning/`
  - `common.sh`: Java y Eclipse.
  - `nfs_server.sh`: NFSv4 en servidor.
  - `nfs_client.sh`: NFSv4 en cliente.
  - `db_server.sh`: instala/configura MariaDB + esquema + seed + usuario de app.
- `app/server/`
  - `src/sd/entrega2/PhoneLookupServer.java`
  - `run_server.sh`
- `app/client/`
  - `src/sd/entrega2/PhoneLookupClient.java`
  - `run_client.sh`
- `tests/`: validaciones de red/NFS/recursos/Java y también BD + socket.

## Uso rápido

Desde `entrega-2`:

```bash
vagrant up
```

### 1) Levantar servidor socket (en la VM servidor)

```bash
vagrant ssh nfs-server -c "cd /vagrant/app/server && ./run_server.sh 5050"
```

### 2) Ejecutar cliente (en otra terminal, VM cliente)

```bash
vagrant ssh nfs-client -c "cd /vagrant/app/client && ./run_client.sh 192.168.56.10 5050"
```

Ejemplo de teléfonos de prueba:

- `3001001001`
- `3001001002`
- `3001001003`
- `3001001004`
- `3001001005`

### 3) Ejecutar pruebas automáticas

```bash
bash tests/run_all.sh
```

## Notas

- La base usada es `sd_entrega2`.
- Usuario app: `sd_user`
- Password app: `sd_password`
- El driver JDBC de MariaDB se instala con `libmariadb-java`.

