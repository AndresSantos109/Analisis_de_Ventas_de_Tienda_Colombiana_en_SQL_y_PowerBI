--=============================================================
--    Preparación y creación de Views para importar a PowerBI
-- vamos a transformar la Data como la necesitamos para importarla a POWERBI
--=============================================================

--1. Revisar si hay datos nulos en cada tabla
SELECT
    SUM(CASE WHEN cliente_id IS NULL THEN 1 ELSE 0 END) AS cliente_id_nulos,
    SUM(CASE WHEN producto_id IS NULL THEN 1 ELSE 0 END) AS producto_id_nulos,
    SUM(CASE WHEN fecha_venta IS NULL THEN 1 ELSE 0 END) AS fecha_venta_nulos,
    SUM(CASE WHEN total_venta IS NULL THEN 1 ELSE 0 END) AS total_venta_nulos
FROM info_comercial.ventas;


SELECT
    SUM(CASE WHEN nombre_producto IS NULL THEN 1 ELSE 0 END) AS nombre_producto_nulos,
    SUM(CASE WHEN producto_id IS NULL THEN 1 ELSE 0 END) AS producto_id_nulos,
    SUM(CASE WHEN categoria IS NULL THEN 1 ELSE 0 END) AS categoria_nulos,
    SUM(CASE WHEN precio_unitario IS NULL THEN 1 ELSE 0 END) AS precio_unitario_nulos,
	SUM(CASE WHEN costo_unitario IS NULL THEN 1 ELSE 0 END) AS costo_nulos
FROM info_comercial.productos;

SELECT
    SUM(CASE WHEN empleado_id IS NULL THEN 1 ELSE 0 END) AS empleado_id_nulos,
    SUM(CASE WHEN nombre_empleado IS NULL THEN 1 ELSE 0 END) AS nombre_empleado_nulos,
    SUM(CASE WHEN cargo IS NULL THEN 1 ELSE 0 END) AS cargo_nulos,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulos,
	SUM(CASE WHEN tienda_id IS NULL THEN 1 ELSE 0 END) AS tienda_id_nulos
FROM info_comercial.empleados;

SELECT
    SUM(CASE WHEN tienda_id IS NULL THEN 1 ELSE 0 END) AS tienda_id_nulos,
    SUM(CASE WHEN nombre_tienda IS NULL THEN 1 ELSE 0 END) AS nombre_tienda_nulos,
    SUM(CASE WHEN departamento IS NULL THEN 1 ELSE 0 END) AS departamento_nulos,
    SUM(CASE WHEN ciudad IS NULL THEN 1 ELSE 0 END) AS ciudad_nulos,
	SUM(CASE WHEN latitud IS NULL THEN 1 ELSE 0 END) AS latitud_nulos,
	SUM(CASE WHEN longitud IS NULL THEN 1 ELSE 0 END) AS longitud_nulos,
	SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulos
FROM info_comercial.tiendas;

SELECT
    SUM(CASE WHEN venta_id IS NULL THEN 1 ELSE 0 END) AS venta_id_nulos,
    SUM(CASE WHEN cliente_id IS NULL THEN 1 ELSE 0 END) AS cliente_id_nulos,
    SUM(CASE WHEN producto_id IS NULL THEN 1 ELSE 0 END) AS producto_id_nulos,
    SUM(CASE WHEN empleado_id IS NULL THEN 1 ELSE 0 END) AS empleado_id_nulos,
	SUM(CASE WHEN tienda_id IS NULL THEN 1 ELSE 0 END) AS tienda_id_nulos,
	SUM(CASE WHEN fecha_venta IS NULL THEN 1 ELSE 0 END) AS fecha_venta_nulos,
	SUM(CASE WHEN cantidad IS NULL THEN 1 ELSE 0 END) AS cantidad_nulos,
	SUM(CASE WHEN total_venta IS NULL THEN 1 ELSE 0 END) AS total_venta
FROM info_comercial.ventas;

--2. Verificar si hay datos duplicados
SELECT
count(*)
FROM info_comercial.ventas

SELECT DISTINCT
count(*)
FROM info_comercial.ventas

--como dan el mismo valor, se confirma que no hay duplicados

--3. Verificar si hay datos atipicos en las ventas (variable mas importante)
SELECT
total_venta
FROM info_comercial.ventas
WHERE ABS(total_venta)>3*(SELECT
						STDDEV(total_venta)
						FROM info_comercial.ventas)
							
--4. Ya se determino que hay categorias diferentes, no vamos a integrar tablas para que se haga este proceso con las relaciones en POWERBI
-- Las columnas calculadas las dejamos a POWER BI

--5. Crear VIEWS teniendo en cuenta los hallazgos anteriores
CREATE MATERIALIZED VIEW info_comercial.view_ventas
AS(
SELECT DISTINCT 
*
FROM info_comercial.ventas)

CREATE MATERIALIZED VIEW info_comercial.view_clientes
AS(
SELECT DISTINCT 
*
FROM info_comercial.clientes)

CREATE MATERIALIZED VIEW info_comercial.view_empleados
AS(
SELECT DISTINCT 
*
FROM info_comercial.empleados)

CREATE MATERIALIZED VIEW info_comercial.view_productos
AS(
SELECT DISTINCT 
*
FROM info_comercial.productos)

CREATE MATERIALIZED VIEW info_comercial.view_tiendas
AS(
SELECT DISTINCT 
*
FROM info_comercial.tiendas)


REFRESH MATERIALIZED VIEW info_comercial.view_ventas
