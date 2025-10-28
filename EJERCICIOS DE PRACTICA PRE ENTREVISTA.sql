--=====================================================
--					NIVEL INTERMEDIO
--=====================================================
--Obtén el total de ventas por ciudad.
SELECT
ciudad,
SUM(total_venta)
FROM info_comercial.ventas v
INNER JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY ciudad

--Calcula el promedio de venta por cliente.
SELECT
cliente_id,
ROUND(AVG(total_venta),2)
FROM info_comercial.ventas v
GROUP BY cliente_id

--Muestra el producto más vendido (en cantidad).
WITH producto_cantidad AS (
SELECT
nombre_producto,
SUM(cantidad) as Cant_Tot
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY nombre_producto)
SELECT
*
FROM producto_cantidad
WHERE cant_tot=(SELECT
				MAX(Cant_Tot)
				FROM producto_cantidad)

--Encuentra los 3 productos con mayores ingresos totales, sin usar LIMIT ni RANK.
--OP1
WITH producto_ventas AS (
SELECT
nombre_producto,
SUM(total_venta) AS Tot_Ven
FROM info_comercial.ventas v1
INNER JOIN info_comercial.productos p
ON p.producto_id=v1.producto_id
GROUP BY nombre_producto
)
SELECT
*,
(SELECT COUNT(DISTINCT Tot_Ven)
	FROM producto_ventas pd2
	WHERE pd1.Tot_Ven<pd2.Tot_Ven) AS Cant_Encima
FROM producto_ventas pd1
ORDER BY Cant_Encima ASC


--OP2
WITH producto_ventas AS (
SELECT
nombre_producto,
SUM(total_venta) AS Tot_Ven
FROM info_comercial.ventas v1
INNER JOIN info_comercial.productos p
ON p.producto_id=v1.producto_id
GROUP BY nombre_producto
)
SELECT
*
FROM producto_ventas pd1
WHERE (SELECT
		COUNT(DISTINCT Tot_Ven)
		FROM producto_ventas pd2
		WHERE pd1.Tot_Ven<pd2.Tot_Ven)<3
ORDER BY pd1.Tot_Ven DESC


--Muestra los clientes que han comprado más de 5 productos diferentes
SELECT
cliente_id,
(SELECT
		COUNT(DISTINCT producto_id)
		FROM info_comercial.ventas) AS Produt_Dif
FROM info_comercial.ventas
WHERE (SELECT
		COUNT(DISTINCT producto_id)
		FROM info_comercial.ventas)>5


--Encuentra las ventas realizadas en el mismo día por distintos vendedores al mismo cliente.
SELECT
fecha_venta,
cliente_id,
COUNT(DISTINCT empleado_id)
FROM info_comercial.ventas
GROUP BY fecha_venta, cliente_id

--=====================================================
--					Nivel Avanzado
--=====================================================

--Obtén el nombre del vendedor con la segunda mayor venta total, sin usar funciones de ranking ni LIMIT.
WITH ventas_empleado AS
(SELECT
empleado_id,
SUM(total_venta) as Ventas_Totales
FROM info_comercial.ventas
GROUP BY empleado_id)
SELECT
*
FROM ventas_empleado v1
WHERE (SELECT
		count(*)
		FROM ventas_empleado v2
		WHERE v1.Ventas_Totales>v2.Ventas_Totales)=1

--Calcula la diferencia en ventas totales entre el top 1 y el top 2 vendedores.
WITH ventas_empleado AS
(SELECT
empleado_id,
SUM(total_venta) as Ventas_Totales
FROM info_comercial.ventas
GROUP BY empleado_id)
SELECT
	(SELECT MAX(Ventas_Totales)	FROM ventas_empleado)-(
SELECT Ventas_Totales FROM ventas_empleado v2
WHERE (SELECT COUNT(*) FROM ventas_empleado v1 WHERE v2.Ventas_Totales<v1.Ventas_Totales)=1)
AS diferencia_ventas_top1_top2

--Muestra los productos cuyo precio es mayor al promedio de su categoría.
SELECT
categoria,
nombre_producto,
precio_unitario,
(SELECT	AVG(precio_unitario) FROM info_comercial.productos p2 WHERE p2.categoria=p1.categoria) AS promedio
FROM info_comercial.productos p1
WHERE precio_unitario>(SELECT
						AVG(precio_unitario)
						FROM info_comercial.productos p2
						WHERE p2.categoria=p1.categoria)

--Encuentra el cliente que compró por última vez (fecha más reciente).
SELECT
fecha_venta,
cliente_id
FROM info_comercial.ventas
WHERE fecha_venta=(SELECT
					MAX(fecha_venta)
					FROM info_comercial.ventas)

--Muestra el total de ventas acumuladas mes a mes por región, ordenadas cronológicamente.
WITH ventas_mensual AS(
SELECT
EXTRACT("Year" FROM fecha_venta)as Year,
EXTRACT("Month" FROM fecha_venta)as Month,
region,
SUM(total_venta) as Ventas_Mes_Year
FROM info_comercial.ventas v
INNER JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY Year,Month,region)
SELECT
*,
SUM(Ventas_Mes_Year) OVER(PARTITION BY region ORDER BY Year,Month) AS Ventas
FROM ventas_mensual vm
ORDER BY Year,region,Month

--Obtén los clientes que no han comprado en los últimos 6 meses.

SELECT DISTINCT cliente_id
FROM info_comercial.ventas
WHERE cliente_id NOT IN (
    SELECT DISTINCT cliente_id
    FROM info_comercial.ventas
    WHERE fecha_venta >= (SELECT MAX(fecha_venta) FROM info_comercial.ventas) - INTERVAL '6 months'
)

--=====================================================
--	Nivel Experto (preguntas de entrevista real)
--=====================================================

--Encuentra el segundo y tercer producto más vendido sin usar LIMIT, OFFSET, RANK() ni ROW_NUMBER().
--Pista: puedes usar subconsultas correlacionadas o *COUNT(DISTINCT ...) con comparaciones.
WITH producto_venta AS(
SELECT
producto_id,
sum(total_venta) AS Ventas_Tot
FROM info_comercial.ventas
GROUP BY producto_id)
SELECT
*
FROM producto_venta pv1
WHERE (SELECT
		COUNT(*)
		FROM producto_venta pv2
		WHERE pv1.Ventas_Tot<pv2.Ventas_Tot) IN(1,2)


-- Muestra el producto cuyo total de ventas está justo por debajo del máximo.
WITH producto_venta AS(
SELECT
producto_id,
sum(total_venta) AS Ventas_Tot
FROM info_comercial.ventas
GROUP BY producto_id)
SELECT
*
FROM producto_venta pv1
WHERE (SELECT
		COUNT(*)
		FROM producto_venta pv2
		WHERE pv1.Ventas_Tot<pv2.Ventas_Tot)=1


-- Identifica los clientes que gastan más que el promedio de todos los clientes de su ciudad.
WITH cliente_venta AS(
SELECT
v.cliente_id,
ciudad, 
SUM(total_venta) AS ven_tot
FROM info_comercial.ventas v
INNER JOIN info_comercial.clientes c
ON c.cliente_id=v.cliente_id
GROUP BY ciudad,v.cliente_id)
SELECT
*
FROM cliente_venta cv1
WHERE ven_tot>(SELECT
				AVG(ven_tot)
				FROM cliente_venta cv2
				WHERE cv2.ciudad=cv1.ciudad)
ORDER BY ciudad


-- Calcula el porcentaje de participación de cada producto sobre las ventas totales.
SELECT
producto_id,
sum(total_venta)*100/(SELECT
				sum(total_venta)
				FROM info_comercial.ventas ) AS porcent
FROM info_comercial.ventas
GROUP BY producto_id
ORDER BY porcent DESC

-- 💪 Retos Extra (para entrevistas técnicas tipo analista o data scientist)
-- Crea una consulta que muestre la tendencia de crecimiento mensual por vendedor.
--Creo tabla de tiempos
WITH calendario AS(
	SELECT
	y::int AS year,
	m::int AS month
	FROM generate_series(2022,2024) AS y,
	generate_series(1,12) AS m
),
clientes_fecha AS(
SELECT DISTINCT
year,
month,
cliente_id
FROM info_comercial.clientes c
CROSS JOIN calendario
ORDER BY cliente_id,year,month
),
--Creo tabla de ventas historicas por cliente
venta_cliente AS(
SELECT
EXTRACT("Year" FROM fecha_venta) AS Year,
EXTRACT("Month" FROM fecha_venta) AS Month,
cliente_id,
SUM(total_venta) AS Tot_Ven
FROM info_comercial.ventas
GROUP BY Year,Month,cliente_id
),
--Cruzo ambas tablas
cruce_tablas AS(
SELECT
cf.year,
cf.month,
cf.cliente_id,
COALESCE(vc.Tot_Ven,0) as Total_Ventas
FROM clientes_fecha cf 
LEFT JOIN venta_cliente vc
ON vc.cliente_id=cf.cliente_id
AND vc.year=cf.year
AND vc.month=cf.month
)
SELECT
year,
month,
cliente_id,
Total_Ventas,
LAG(Total_Ventas) OVER(PARTITION BY cliente_id ORDER BY year,month) AS mes_pasado,
ROUND(CASE
WHEN (LAG(Total_Ventas) OVER(PARTITION BY cliente_id ORDER BY year,month))=0 AND Total_Ventas>0 THEN 100
WHEN (LAG(Total_Ventas) OVER(PARTITION BY cliente_id ORDER BY year,month))=0 AND Total_Ventas=0 THEN 0
ELSE Total_Ventas*100/(LAG(Total_Ventas) OVER(PARTITION BY cliente_id ORDER BY year,month))
END,2) AS Var_Mes_Cliente
FROM cruce_tablas


-- Calcula el número de días promedio entre compras de cada cliente.
WITH tiempo_comp_client AS(
SELECT
cliente_id,
fecha_venta-LAG(fecha_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta) AS tiempo_entre_compras
FROM info_comercial.ventas)
SELECT
cliente_id,
ROUND(AVG(tiempo_entre_compras),2) AS tiempo_promedio_entre_compra_en_dias
FROM tiempo_comp_client
GROUP BY cliente_id
ORDER BY tiempo_promedio_entre_compra_en_dias


-- Genera un reporte que muestre el primer y último producto comprado por cada cliente.
WITH producto_ventas AS(
SELECT
v.cliente_id,
fecha_venta,
nombre_producto
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON v.producto_id=p.producto_id
)
SELECT
cliente_id,
(SELECT nombre_producto FROM producto_ventas pv2 WHERE pv1.cliente_id=pv2.cliente_id AND fecha_venta=(SELECT MAX(fecha_venta) FROM producto_ventas pv2 WHERE pv1.cliente_id=pv2.cliente_id) LIMIT 1) AS ultimo_producto
FROM producto_ventas pv1

-- Muestra el producto más vendido en cada ciudad.
WITH ventas_ciudad_producto AS(
SELECT
ciudad,
nombre_producto,
SUM(total_venta) as Ven_Tot
FROM info_comercial.ventas v
INNER JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
INNER JOIN info_comercial.productos p 
ON p.producto_id=v.producto_id
GROUP BY ciudad,nombre_producto)
SELECT
ciudad,
nombre_producto
Ven_Tot
FROM ventas_ciudad_producto vcp1
WHERE Ven_Tot=(SELECT
				MAX(Ven_Tot)
				FROM ventas_ciudad_producto vcp2
				WHERE vcp2.ciudad=vcp1.ciudad)

-- Encuentra los clientes que han comprado en más de una tienda.
SELECT
cliente_id
FROM info_comercial.ventas v1
WHERE (SELECT
		COUNT(DISTINCT tienda_id)
		FROM info_comercial.ventas v2
		WHERE v2.cliente_id=v1.cliente_id)>1