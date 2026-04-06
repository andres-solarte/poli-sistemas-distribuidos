#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[db-server] Installing MariaDB server + JDBC driver"
apt-get update -y
apt-get install -y mariadb-server mariadb-client libmariadb-java

systemctl enable --now mariadb

echo "[db-server] Creating schema, seed data and app user"
mysql <<'SQL'
CREATE DATABASE IF NOT EXISTS sd_entrega2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE sd_entrega2;

CREATE TABLE IF NOT EXISTS ciudades (
  ciud_id INT PRIMARY KEY,
  ciud_nombre VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS personas (
  dir_tel VARCHAR(20) PRIMARY KEY,
  dir_tipo_tel VARCHAR(20) NOT NULL,
  dir_nombre VARCHAR(120) NOT NULL,
  dir_direccion VARCHAR(200) NOT NULL,
  dir_ciud_id INT NOT NULL,
  CONSTRAINT fk_persona_ciudad
    FOREIGN KEY (dir_ciud_id) REFERENCES ciudades(ciud_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

INSERT INTO ciudades (ciud_id, ciud_nombre) VALUES
  (1, 'Bogota'),
  (2, 'Medellin'),
  (3, 'Cali'),
  (4, 'Barranquilla'),
  (5, 'Bucaramanga')
ON DUPLICATE KEY UPDATE ciud_nombre = VALUES(ciud_nombre);

INSERT INTO personas (dir_tel, dir_tipo_tel, dir_nombre, dir_direccion, dir_ciud_id) VALUES
  ('3001001001', 'movil', 'Ana Torres', 'Calle 10 # 20-30', 1),
  ('3001001002', 'movil', 'Luis Perez', 'Carrera 15 # 8-12', 2),
  ('3001001003', 'fijo', 'Marta Diaz', 'Av. 3N # 45-10', 3),
  ('3001001004', 'movil', 'Carlos Ruiz', 'Calle 72 # 50-20', 4),
  ('3001001005', 'fijo', 'Diana Mora', 'Cra 27 # 36-40', 5)
ON DUPLICATE KEY UPDATE
  dir_tipo_tel = VALUES(dir_tipo_tel),
  dir_nombre = VALUES(dir_nombre),
  dir_direccion = VALUES(dir_direccion),
  dir_ciud_id = VALUES(dir_ciud_id);

CREATE USER IF NOT EXISTS 'sd_user'@'localhost' IDENTIFIED BY 'sd_password';
GRANT SELECT ON sd_entrega2.* TO 'sd_user'@'localhost';
FLUSH PRIVILEGES;
SQL

echo "[db-server] MariaDB ready"
