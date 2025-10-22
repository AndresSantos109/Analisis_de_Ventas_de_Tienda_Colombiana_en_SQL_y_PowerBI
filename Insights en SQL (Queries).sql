--=================================================
--              SEGUNDA SECCIÓN !!!
--=================================================

---------------------------------------------------------------------------------------------------
--       NIVEL BÁSICO
-- En esta sección harémos una busqueda general de información para generar unos primeros insights
---------------------------------------------------------------------------------------------------

--Total de ventas, costo y rentabilidad global por año y mes.
SELECT 
ROUND(SUM(total_venta),2) as Ventas,
ROUND(SUM(cantidad*costo_unitario),2) as Costos,
ROUND(SUM(total_venta)-SUM(cantidad*costo_unitario),2) as Rentabilidad
FROM info_comercial.ventas v
LEFT JOIN info_comercial.productos p
ON p.producto_id=v.producto_id

--Top 10 productos más vendidos por unidades.
SELECT
nombre_producto,
SUM(cantidad) as Unidades_vendidas
FROM info_comercial.ventas v
LEFT JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY nombre_producto
ORDER BY Unidades_vendidas DESC
LIMIT 5

--Top 5 categorías con más ingresos.
SELECT
categoria,
ROUND(SUM(total_venta),2) as Ventas_Totales
FROM info_comercial.ventas v
LEFT JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY categoria
Order by Ventas_Totales DESC
LIMIT 5

--Promedio del ticket de venta por mes.
SELECT
EXTRACT('Month' FROM fecha_venta) as Mes,
ROUND(AVG(total_venta),2) as Promedio_Ventas
FROM info_comercial.ventas v
GROUP BY Mes
ORDER BY Promedio_Ventas DESC

--Número de clientes nuevos por año (usando fecha_registro).
SELECT
TO_CHAR(fecha_registro,'YYYY-MM') as Year_Month,
COUNT(*) as Num_Registros
FROM info_comercial.clientes
GROUP BY Year_Month
ORDER BY Num_registros DESC

--Ventas promedio por tienda y su desviación estándar (para detectar dispersión).
SELECT
t.tienda_id,
nombre_tienda,
ROUND(AVG(total_venta),2),
ROUND(STDDEV(total_venta),2)
FROM info_comercial.ventas v
LEFT JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY t.tienda_id,nombre_tienda
ORDER BY t.tienda_id

--Ver los ingresos totales por año y mes
SELECT
EXTRACT("Year" FROM fecha_venta) as Year,
EXTRACT("Month" FROM fecha_venta) as Month,
ROUND(SUM(total_venta),2) AS Ventas_Totales
FROM info_comercial.ventas
GROUP BY Year, Month
ORDER BY Year, Month

--Ver el top 5 de ciudades con mas ingresos
SELECT
ciudad,
ROUND(SUM(total_venta),2) as Ventas_Totales
FROM info_comercial.ventas v
LEFT JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY ciudad
ORDER BY Ventas_Totales DESC
LIMIT 5

--Ver el top 5 de ciudades con mayor rentabilidad
SELECT
ciudad,
ROUND(SUM(total_venta)-SUM(precio_unitario*cantidad),2) as Rentabilidad_Total
FROM info_comercial.ventas v
LEFT JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
LEFT JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY ciudad
ORDER BY Rentabilidad_Total DESC
LIMIT 5

--Ver el top 5 tiendas con mas ingresos
SELECT
v.tienda_id,
ROUND(SUM(total_venta),2) as Ventas_Totales
FROM info_comercial.ventas v
LEFT JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY v.tienda_id
ORDER BY Ventas_Totales DESC
LIMIT 5

--Ver el top 5 tiendas con mas rentabilidad
SELECT
t.tienda_id,
ROUND(SUM(total_venta)-SUM(precio_unitario*cantidad),2) as Rentabilidad_Total
FROM info_comercial.ventas v
LEFT JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
LEFT JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY t.tienda_id
ORDER BY Rentabilidad_Total DESC
LIMIT 5

--Ver los empleados con mas ventas para retornar un bono
SELECT
nombre_empleado,
ROUND(SUM(total_venta),2) as Ventas_Totales
FROM info_comercial.ventas v
LEFT JOIN info_comercial.empleados e
ON e.empleado_id=v.empleado_id
GROUP BY nombre_empleado
ORDER BY Ventas_Totales DESC

--Ver los productos con mas rentabilidad (ver todos en orden)
SELECT
nombre_producto,
ROUND(SUM(total_venta)-sum(costo_unitario*cantidad),2) as Rentabilidad_Total
FROM info_comercial.ventas v
LEFT JOIN info_comercial.productos p
ON v.producto_id=p.producto_id
GROUP BY nombre_producto
ORDER BY Rentabilidad_Total DESC


---------------------------------------------------------------------------------------------------
--       NIVEL INTERMEDIO
-- (usa CTEs, funciones ventana, y relaciones entre múltiples tablas)
---------------------------------------------------------------------------------------------------

-- Top 3 empleados con mayor rentabilidad promedio por tienda.

SELECT
*
FROM(
SELECT
tienda_id,
empleado_id,
ROUND(AVG(total_venta-cantidad*costo_unitario),2),
DENSE_RANK() OVER (PARTITION BY v1.tienda_id ORDER BY ROUND(AVG(total_venta-cantidad*costo_unitario),2) DESC) as Ranking
FROM info_comercial.ventas v1
LEFT JOIN info_comercial.productos p1
ON p1.producto_id=v1.producto_id
GROUP BY tienda_id, empleado_id
ORDER BY tienda_id
) AS Top3_empleados_tienda
WHERE Ranking in (1,2,3)

-- Clientes que compraron en más de una tienda.

SELECT
cliente_id,
COUNT(*) as Dif_Tiendas
FROM(SELECT DISTINCT
	cliente_id,
	tienda_id
	FROM info_comercial.ventas
	ORDER BY cliente_id,tienda_id) AS cliente_tienda
GROUP BY cliente_id
ORDER BY cliente_id 


SELECT 
cliente_id,
COUNT(DISTINCT tienda_id) AS num_tiendas,
COUNT(DISTINCT venta_id) AS num_ventas
FROM info_comercial.ventas
GROUP BY cliente_id
ORDER BY cliente_id 

-- Comparar ventas actuales vs año anterior (YoY Growth).
SELECT
EXTRACT("Year" FROM fecha_venta) AS Año,
ROUND(SUM(total_venta),2) as Ventas_Totales,
LAG(ROUND(SUM(total_venta),2)) OVER(ORDER BY EXTRACT("Year" FROM fecha_venta)) AS Ventas_Año_Anterior
FROM info_comercial.ventas
GROUP BY Año

-- Distribución de ventas por categoría y región.
SELECT
departamento,
region,
categoria,
sum(total_venta)*100/(SELECT
				sum(total_venta)
				FROM info_comercial.ventas v1
				INNER JOIN info_comercial.tiendas t1
				ON t1.tienda_id=v1.tienda_id
				WHERE t1.departamento=t.departamento
				AND t1.region=t.region) AS Participación_Ventas
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
INNER JOIN info_comercial.tiendas t
ON t.tienda_id=v.tienda_id
GROUP BY departamento,region,categoria
ORDER BY departamento, region, Participación_Ventas DESC

-- Productos que representan el 80% de los ingresos (regla de Pareto).
SELECT
*
FROM(
SELECT
nombre_producto,
ROUND(sum(total_venta)*100/(SELECT SUM(total_venta) FROM info_comercial.ventas),2) AS Participación_Ventas,
SUM(ROUND(sum(total_venta)*100/(SELECT SUM(total_venta) FROM info_comercial.ventas),2)) 
	OVER(ORDER BY ROUND(sum(total_venta)*100/(SELECT SUM(total_venta) FROM info_comercial.ventas),2) DESC) AS Participación_Ventas_Acumulada
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY nombre_producto
ORDER BY Participación_Ventas_Acumulada ASC) AS TABLA_PARTICIPACION_ACUMULADA
WHERE Participación_Ventas_Acumulada<80


-- Top 3 ciudades con mayor crecimiento porcentual año a año.
SELECT
ciudad,
ROUND(AVG(cambio_porcentual),2) AS Promedio_Cambio_Anual
FROM(SELECT
EXTRACT("Year" FROM fecha_venta) as Año,
ciudad,
ROUND(SUM(total_venta),2) AS Venta_Anual,
(ROUND(SUM(total_venta),2)/LAG(ROUND(SUM(total_venta),2)) OVER(PARTITION BY ciudad ORDER BY EXTRACT("Year" FROM fecha_venta))-1)*100 AS Cambio_Porcentual
FROM info_comercial.ventas v
INNER JOIN info_comercial.tiendas t
ON v.tienda_id=t.tienda_id
GROUP BY Año,ciudad
Order by Ciudad,Año) AS Tabla_Cambio_Porcentual
WHERE cambio_porcentual IS NOT NULL
GROUP BY ciudad
ORDER BY Promedio_Cambio_Anual DESC
LIMIT 3

-- Promedio de margen por categoría y tienda.
SELECT
tienda_id,
categoria,
AVG(total_venta-cantidad*costo_unitario) AS margen_prom
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY tienda_id,categoria
ORDER BY tienda_id

---------------------------------------------------------------------------------------------------
--       NIVEL AVANZADO
-- (implican subconsultas correlacionadas, CTEs anidados o lógica de negocio más compleja)
---------------------------------------------------------------------------------------------------

--🧠 Clientes “VIP”: aquellos cuyo total de compras está en el top 10% del total de ventas de todos los clientes.
SELECT
*
FROM(
SELECT
cliente_id,
ROUND(SUM(total_venta)/(SELECT
				SUM(total_venta)
				FROM info_comercial.ventas
				)*100,2) as Porcentaje_Participacion,
SUM(ROUND(SUM(total_venta)/(SELECT
				SUM(total_venta)
				FROM info_comercial.ventas
				)*100,2)) OVER (ORDER BY (ROUND(SUM(total_venta)/(SELECT
				SUM(total_venta)
				FROM info_comercial.ventas
				)*100,2))DESC, cliente_id)
FROM info_comercial.ventas v
GROUP BY cliente_id
ORDER BY Porcentaje_Participacion DESC) TBALE_END
WHERE sum<10


--📅 Estacionalidad: detectar el mes más fuerte en ventas por cada categoría (usando RANK() o DENSE_RANK()).

SELECT
*
FROM(SELECT
categoria,
EXTRACT("Month" FROM fecha_venta) AS mes,
ROUND(SUM(total_venta),2) AS ventas_tot,
DENSE_RANK() OVER(PARTITION BY categoria ORDER BY ROUND(SUM(total_venta),2) DESC) as Ranking
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
GROUP BY categoria,mes) Ventas_Mes_Categoria
WHERE Ranking=1

--💼 Eficiencia de vendedores: calcular el promedio de ingresos generados por empleado, dividido entre el número de clientes atendidos.
SELECT
empleado_id,
ROUND(SUM(total_venta)/COUNT(*),2) Prom_Venta
FROM info_comercial.ventas
GROUP BY empleado_id
ORDER BY Prom_Venta DESC

SELECT
empleado_id,
ROUND(SUM(total_venta)/COUNT(DISTINCT cliente_id),2) Prom_Venta
FROM info_comercial.ventas
GROUP BY empleado_id
ORDER BY Prom_Venta DESC

--🏬 Detección de tiendas en riesgo: tiendas con ventas bajo el promedio del total y margen < 10%.
SELECT
tienda_id,
AVG(venta_mes),
ROUND(((AVG(venta_mes)/(SELECT AVG(venta_mes)FROM(
									SELECT
									tienda_id,
									EXTRACT("month" FROM fecha_venta) AS mes,
									ROUND(sum(total_venta),2) AS venta_mes
									FROM info_comercial.ventas
									GROUP BY tienda_id, mes) AS Venta_Mes_Tienda2))-1)*100,2) AS Porcentaje_encima_prom
FROM(
SELECT
tienda_id,
EXTRACT("month" FROM fecha_venta) AS mes,
ROUND(sum(total_venta),2) AS venta_mes
FROM info_comercial.ventas
GROUP BY tienda_id, mes) AS Venta_Mes_Tienda
GROUP BY tienda_id
HAVING(ROUND(((AVG(venta_mes)/(SELECT AVG(venta_mes)FROM(
									SELECT
									tienda_id,
									EXTRACT("month" FROM fecha_venta) AS mes,
									ROUND(sum(total_venta),2) AS venta_mes
									FROM info_comercial.ventas
									GROUP BY tienda_id, mes) AS Venta_Mes_Tienda2))-1)*100,2))<0
 
--🔄 Clientes recurrentes vs nuevos por mes.
--Clientes recurrentes (Todos los meses del último año)
SELECT
cliente_id,
COUNT(*)
FROM info_comercial.ventas
WHERE EXTRACT("YEAR" FROM fecha_venta)='2024'
GROUP BY cliente_id
HAVING COUNT(*)>12

--Clientes nuevos 
SELECT
cliente_id,
min(fecha_venta)
FROM info_comercial.ventas
GROUP BY cliente_id

--📈 Ranking dinámico de empleados: ranking mensual de ventas con RANK() para analizar quiénes suben o bajan en el top.
--Este es el código empleando una query (NO ES DINAMICO AL ACTUALIZAR LA DATA)
SELECT
cliente_id,
ROUND(SUM(total_venta),2),
DENSE_RANK() OVER(ORDER BY ROUND(SUM(total_venta),2) DESC)
FROM info_comercial.ventas
WHERE EXTRACT("YEAR" FROM fecha_venta)=(SELECT
										MAX(EXTRACT("YEAR" FROM fecha_venta))
										FROM info_comercial.ventas)
AND EXTRACT("MONTH" FROM fecha_venta)=(SELECT
										MAX(EXTRACT("MONTH" FROM fecha_venta))
										FROM info_comercial.ventas)		
GROUP BY cliente_id
limit 10

--Este es el código empleando la busqueda como VIEW (ES DINAMICO AL ACTUALIZAR LA DATA)
CREATE MATERIALIZED VIEW info_comercial.Top_Empleado_mes
AS (
	SELECT
	cliente_id,
	ROUND(SUM(total_venta),2),
	DENSE_RANK() OVER(ORDER BY ROUND(SUM(total_venta),2) DESC)
	FROM info_comercial.ventas
	WHERE EXTRACT("YEAR" FROM fecha_venta)=(SELECT
											MAX(EXTRACT("YEAR" FROM fecha_venta))
											FROM info_comercial.ventas)
	AND EXTRACT("MONTH" FROM fecha_venta)=(SELECT
											MAX(EXTRACT("MONTH" FROM fecha_venta))
											FROM info_comercial.ventas)		
	GROUP BY cliente_id
	limit 10
)

SELECT
*
FROM Top_Empleado_Mes

--📦 Mix de producto por tienda: porcentaje de ventas que representa cada categoría dentro de cada tienda.
SELECT
tienda_id,
categoria,
ROUND(SUM(total_venta)/(SELECT
				  SUM(total_venta)
				  FROM info_comercial.ventas v1
				  WHERE v1.tienda_id=v.tienda_id),2)*100 AS Participacion_Categoria_tienda
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON v.producto_id=p.producto_id
GROUP BY tienda_id, categoria
ORDER BY tienda_id,Participacion_Categoria_tienda DESC

---------------------------------------------------------------------------------------------------
--       NIVEL PRO
-- (mezcla SQL analítico y pensamiento de negocio)
---------------------------------------------------------------------------------------------------

--Detectar outliers: tiendas con ventas 2 desviaciones estándar por encima o debajo del promedio.
SELECT
tienda_Id,
total_venta
FROM info_comercial.ventas
WHERE total_venta>((SELECT AVG(total_venta) FROM info_comercial.ventas)+2*(SELECT STDDEV(total_venta) FROM info_comercial.ventas))

--Clientes “dormidos”: aquellos que no han comprado en los últimos 6 meses.
SELECT
cliente_id,
('2024-12-31'-fecha_venta)/30 AS Meses_Sin_Comprar
FROM info_comercial.ventas
WHERE ('2024-12-31'-fecha_venta)>6*30
ORDER BY Meses_Sin_Comprar 

--Elasticidad por categoría: correlación entre precio promedio y cantidad vendida.
SELECT
categoria,
CORR(prom_precio_unit,Tot_cantidad) AS correlacion_precio_cantidad
FROM(
SELECT
categoria,
TO_CHAR(fecha_venta,'yyyy-mm') AS año_mes,
AVG(precio_unitario) AS prom_precio_unit,
SUM(cantidad) AS Tot_cantidad
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON v.producto_id=p.producto_id
GROUP BY categoria, año_mes) AS tabla_ventas_cat
GROUP BY categoria
ORDER BY correlacion_precio_cantidad

--Productos con ventas negativas o márgenes anómalos.
SELECT
nombre_producto,
precio_unitario-costo_unitario
FROM info_comercial.productos 
WHERE precio_unitario-costo_unitario<0

SELECT
nombre_producto,
total_venta
FROM info_comercial.ventas v
INNER JOIN info_comercial.productos p
ON p.producto_id=v.producto_id
WHERE total_venta<=0
WHERE precio_unitario-costo_unitario<0