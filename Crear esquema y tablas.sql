-- ========================================================================
-- PROYECTO DE ANALÍTICA DE VENTAS DE UNA TIENDA COLOMBIANA- ANDRÉS SANTOS
-- ========================================================================

-- ==========================
-- PRIMER PASO. CREAR ESQUEMA
--===========================
CREATE SCHEMA info_comercial


-- ==========================
-- SEGUNDO PASO. CREAR TABLAS
--===========================
--Crear tabla clientes
CREATE TABLE info_comercial.clientes(
cliente_id SERIAL PRIMARY KEY,
nombre TEXT,
ciudad TEXT,
segmento TEXT,
fecha_registro DATE
);

--Crear tabla de tiendas
CREATE TABLE info_comercial.tiendas(
tienda_id SERIAL PRIMARY KEY,
nombre_tienda TEXT,
departamento TEXT,
ciudad TEXT,
latitud DECIMAL,
longitud DECIMAL, 
region TEXT
);

--Crear tabla de empleados
CREATE TABLE info_comercial.empleados(
empleado_id SERIAL PRIMARY KEY,
nombre_empleado TEXT,
cargo TEXT,
region TEXT,
tienda_id INT REFERENCES info_comercial.tiendas(tienda_id)
);

--Crear tabla de productos
CREATE TABLE info_comercial.productos(
producto_id SERIAL PRIMARY KEY,
nombre_producto TEXT,
categoria TEXT,
precio_unitario DECIMAL,
costo_unitario DECIMAL
);

--Crear tabla de ventas
CREATE TABLE info_comercial.ventas(
venta_id INT,
cliente_id INT REFERENCES info_comercial.clientes(cliente_id),
producto_id INT REFERENCES info_comercial.productos(producto_id),
empleado_id INT REFERENCES info_comercial.empleados(empleado_id),
tienda_id INT REFERENCES info_comercial.tiendas(tienda_id), 
fecha_venta DATE,
cantidad INT,
total_venta DECIMAL
);

-- ==========================
-- TERCER PASO. CARGAR DATA
--===========================

--Este paso se hizo de forma manual desde la sección derecha de postgres, dando click derecho a cada tabla e importando la info

-- ==========================
-- CUARTO PASO. VERIFICAR DATA
--===========================

--Se verifica l valor de "total_ventas" que sea correcto porque deberia ser equivalente a cantidad*precio_unitario

SELECT
cantidad*precio_unitario,
total_venta
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id

--Como hay diferencia, se restaurará el valor
UPDATE info_comercial.ventas v
SET total_venta = cantidad * p.precio_unitario
FROM info_comercial.productos p
WHERE v.producto_id = p.producto_id;


