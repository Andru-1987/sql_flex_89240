-- decirlo donde estoy parado
USE database_store;

-- consulta simple con todas las columnas --> de una forma full declarativa
SELECT 
	id_devolucion,
	id_venta,
    fecha,
    motivo
FROM devoluciones;


SELECT * -- te traigo todas las columnas
FROM devoluciones
-- primeros filtros
WHERE
	-- ISO 8601  YYYY-mm-dd
	-- fecha > "2024-11-01"
	-- MONTH(fecha) >= 11
    -- Entre marzo y noviembre
    MONTH(fecha) BETWEEN 3 AND 11
    AND YEAR(fecha) = 2024
;






-- 

SELECT id_venta FROM ventas
UNION
SELECT id_venta FROM devoluciones;


SELECT id_venta FROM ventas
UNION ALL
SELECT id_venta FROM devoluciones;



-- JOINS --> 
-- INNER JOIN 
-- promedio de ventas

SELECT AVG(precio_unitario) AS  promedio_precio FROM ventas;

SELECT 
    d.*, v.*
FROM
    devoluciones AS d
        RIGHT JOIN
    ventas AS v ON d.id_venta = v.id_venta
WHERE 
-- subconsulta
	v.precio_unitario > (SELECT AVG(precio_unitario) AS  promedio_precio FROM ventas)
    ;



-- Para cada venta  -> id_venta, producto, y la cantidad de devoluciones que ha teniedo ese producto.

SELECT 
	v.id_venta,
    v.producto,
    v.cantidad AS cantidad_vendidos,
	(
		SELECT COUNT(*)
		FROM devoluciones AS d
        INNER JOIN ventas AS v2 ON d.id_venta = v2.id_venta
        WHERE v2.producto = v.producto
    ) AS total_devoluciones_producto
FROM ventas AS v;

-- utilizando CTE's

WITH
	total_devoluciones_per_producto AS(
		SELECT 
			v2.producto,
			COUNT(*) AS total_devueltos
		FROM devoluciones AS d
        INNER JOIN ventas AS v2 ON d.id_venta = v2.id_venta
        GROUP BY v2.producto
    ),
    total_productos_vendidos AS(
		SELECT 
			v.producto,
			SUM(v.cantidad) AS cantidad_vendidos
		FROM ventas AS v
        GROUP BY v.producto
    )
    SELECT 
		UPPER(pv.producto) AS producto_vendido,
        pv.cantidad_vendidos,
        COALESCE(pp.total_devueltos, 0) AS cantidad_devueltos
    FROM total_productos_vendidos AS pv
    LEFT JOIN total_devoluciones_per_producto AS pp
		ON pv.producto = pp.producto
	WHERE
		pv.producto LIKE "LAPTOP%"
	ORDER BY cantidad_vendidos 
        ;
	








