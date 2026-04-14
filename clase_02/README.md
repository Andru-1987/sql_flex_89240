# Semana 2: Consultas y subconsultas SQL

## Contenido del Módulo

- Patrones de diseño de esquemas para análisis y OLTP
- Guías para elegir tipos en sistemas analíticos
- Teoría: Subconsultas y cuándo usarlas
- Panorama de tipos por motor: numéricos, textuales, fechas y binarios
- Fundamentos: LIKE, ILIKE y comodines
- Fundamentos DDL: CREATE, ALTER, DROP
- Conceptos y sintaxis de UNION / UNION ALL
- EXPLAIN y rendimiento de UNION
- Subconsultas correlacionadas
- Migraciones y ALTER TABLE seguras
- Práctica: Crear esquemas y constraints en PostgreSQL y MySQL
- CTE (WITH) y LATERAL: patrones avanzados
- Buenas prácticas al combinar resultados
- Índices y estrategias para búsquedas por patrón
- Patrones y anti-patrones al anidar consultas
- Evaluación del módulo


# Caso Real: Ventas y Devoluciones

Para afianzar los conceptos, trabajaremos con un esquema simplificado de una tienda.


## Ejercicio 1: UNION vs UNION ALL

**Consigna:**  
Obtener un listado unico de todos los `id_venta` que aparecen en la tabla `ventas` o en la tabla `devoluciones`. Escribe dos consultas: una con `UNION` y otra con `UNION ALL`. Explica cual es la adecuada para el objetivo.

**Solucion:**
```sql
-- Opcion con UNION (elimina duplicados)
SELECT id_venta FROM ventas
UNION
SELECT id_venta FROM devoluciones;

-- Opcion con UNION ALL (mantiene duplicados)
SELECT id_venta FROM ventas
UNION ALL
SELECT id_venta FROM devoluciones;
```

**Explicacion:**  
`UNION` realiza una operacion de ordenamiento para eliminar registros repetidos, por lo que cada `id_venta` aparece una sola vez. Es la opcion correcta para un listado unico. `UNION ALL` mostraria dos veces un `id_venta` si esta en ambas tablas, lo cual no es deseado para este requerimiento.

---

## Ejercicio 2: Subconsulta escalar en WHERE

**Consigna:**  
Listar todas las ventas cuyo `precio_unitario` sea mayor que el precio promedio de todos los productos vendidos.

**Solucion:**
```sql
SELECT * 
FROM ventas
WHERE precio_unitario > (SELECT AVG(precio_unitario) FROM ventas);
```

**Explicacion:**  
La subconsulta calcula un unico valor (escalar) que representa el promedio general. Luego la consulta externa filtra las filas cuyo precio supera ese promedio.


---

## Ejercicio 3: Subconsulta correlacionada

**Consigna:**  
Para cada venta, mostrar el `id_venta`, `producto` y la cantidad de devoluciones que ha tenido ese mismo producto (independientemente de la venta especifica).

**Solucion:**
```sql
SELECT 
    v.id_venta,
    v.producto,
    v.cantidad AS cantidad_vendida,
    (
        SELECT COUNT(*) 
        FROM devoluciones d 
        JOIN ventas v2 ON d.id_venta = v2.id_venta
        WHERE v2.producto = v.producto
    ) AS total_devoluciones_producto
FROM ventas v;
```

**Explicacion:**  
La subconsulta esta correlacionada mediante `v.producto`. Se ejecuta una vez por cada fila de `ventas`, contando las devoluciones asociadas al mismo producto.


---

## Ejercicio 4: Optimizacion de LIKE con FULLTEXT

**Consigna:**  
La tabla `ventas` tiene mas de 500,000 registros. Se requiere buscar productos que contengan la palabra "Pro" en su nombre (por ejemplo, "MacBook Pro", "AirPods Pro"). Explica por que un indice normal no mejora `LIKE '%Pro%'` y propone una solucion en MySQL.

**Solucion y explicacion:**  
Un indice B-Tree sobre `producto` almacena los valores ordenados alfabeticamente. La condicion `LIKE '%Pro%'` no permite acotar un rango porque el texto puede comenzar con cualquier caracter. MySQL debe leer todas las filas (full table scan).

**Solucion MySQL:**
```sql
ALTER TABLE ventas ADD FULLTEXT INDEX idx_producto_ft (producto);

SELECT * FROM ventas 
WHERE MATCH(producto) AGAINST('Pro' IN NATURAL LANGUAGE MODE);
```

El indice FULLTEXT tokeniza el texto y permite busquedas rapidas de palabras o frases dentro del contenido.

---

## Ejercicio 5: CTE para reporte mensual

**Consigna:**  
Generar un reporte que muestre para cada mes el total de ingresos por ventas, el monto total de devoluciones y el ingreso neto (ventas - devoluciones). Utiliza CTEs para estructurar la consulta.

**Solucion:**
```sql
WITH ventas_mensuales AS (
    SELECT 
        DATE_FORMAT(fecha, '%Y-%m') AS mes,
        SUM(cantidad * precio_unitario) AS total_ventas
    FROM ventas
    GROUP BY mes
),
devoluciones_mensuales AS (
    SELECT 
        DATE_FORMAT(d.fecha, '%Y-%m') AS mes,
        SUM(v.cantidad * v.precio_unitario) AS total_devuelto
    FROM devoluciones d
    JOIN ventas v ON d.id_venta = v.id_venta
    GROUP BY mes
)
SELECT 
    IFNULL(v.mes, d.mes) AS mes,
    IFNULL(v.total_ventas, 0) AS ingresos_brutos,
    IFNULL(d.total_devuelto, 0) AS perdidas_devoluciones,
    IFNULL(v.total_ventas, 0) - IFNULL(d.total_devuelto, 0) AS ingresos_netos
FROM ventas_mensuales v
LEFT JOIN devoluciones_mensuales d ON v.mes = d.mes

UNION

SELECT 
    IFNULL(v.mes, d.mes) AS mes,
    IFNULL(v.total_ventas, 0) AS ingresos_brutos,
    IFNULL(d.total_devuelto, 0) AS perdidas_devoluciones,
    IFNULL(v.total_ventas, 0) - IFNULL(d.total_devuelto, 0) AS ingresos_netos
FROM ventas_mensuales v
RIGHT JOIN devoluciones_mensuales d ON v.mes = d.mes
WHERE v.mes IS NULL

ORDER BY mes;
```

*Alternativa mas simple con `LEFT JOIN` y `UNION` para emular `FULL OUTER JOIN` no soportado en MySQL:*
```sql
WITH ventas_mensuales AS (
    SELECT 
        DATE_FORMAT(fecha, '%Y-%m') AS mes,
        SUM(cantidad * precio_unitario) AS total_ventas
    FROM ventas
    GROUP BY mes
),
devoluciones_mensuales AS (
    SELECT 
        DATE_FORMAT(d.fecha, '%Y-%m') AS mes,
        SUM(v.cantidad * v.precio_unitario) AS total_devuelto
    FROM devoluciones d
    JOIN ventas v ON d.id_venta = v.id_venta
    GROUP BY mes
)
SELECT 
    COALESCE(v.mes, d.mes) AS mes,
    COALESCE(v.total_ventas, 0) AS ingresos_brutos,
    COALESCE(d.total_devuelto, 0) AS perdidas_devoluciones,
    COALESCE(v.total_ventas, 0) - COALESCE(d.total_devuelto, 0) AS ingresos_netos
FROM ventas_mensuales v
LEFT JOIN devoluciones_mensuales d ON v.mes = d.mes

UNION

SELECT 
    COALESCE(v.mes, d.mes) AS mes,
    COALESCE(v.total_ventas, 0) AS ingresos_brutos,
    COALESCE(d.total_devuelto, 0) AS perdidas_devoluciones,
    COALESCE(v.total_ventas, 0) - COALESCE(d.total_devuelto, 0) AS ingresos_netos
FROM ventas_mensuales v
RIGHT JOIN devoluciones_mensuales d ON v.mes = d.mes
WHERE v.mes IS NULL

ORDER BY mes;
```

**Explicacion:**  
Las CTEs calculan los totales por mes. Como MySQL no tiene `FULL OUTER JOIN`, se usa una combinacion de `LEFT JOIN` y `RIGHT JOIN` con `UNION` para incluir meses que solo tienen ventas o solo tienen devoluciones. `COALESCE` (o `IFNULL`) maneja los valores nulos.


---

## Ejercicio 6: ALTER TABLE seguro en produccion

**Consigna:**  
Se necesita agregar la columna `canal_venta VARCHAR(20)` a la tabla `ventas` que tiene mas de 10 millones de registros. El sitio web no puede estar inactivo. Describe el procedimiento recomendado en MySQL.

**Procedimiento recomendado con MySQL:**

1. **Evaluar la version de MySQL:**  Para agregar columnas al final de la tabla sin bloquear. Si es posible, usar:
   ```sql
   ALTER TABLE ventas ADD COLUMN canal_venta VARCHAR(20);
   ```
---

## Ejercicio 7: DROP TABLE con dependencias

**Consigna:**  
Se desea eliminar permanentemente la tabla `ventas`. ¿Que pasos previos son obligatorios en un entorno MySQL de produccion?

**Lista de verificacion y acciones:**

1. **Identificar dependencias:** Consultar las foreign keys que apuntan a `ventas`.
   ```sql
   SELECT 
       TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME 
   FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
   WHERE REFERENCED_TABLE_NAME = 'ventas';
   ```
2. **Eliminar o alterar las FK:** Si existen, se deben eliminar primero o usar `DROP TABLE ventas CASCADE` (no soportado en MySQL; en su lugar se debe eliminar la FK manualmente).
3. **Realizar backup completo:**
   ```bash
   mysqldump -u usuario -p nombre_bd ventas > backup_ventas.sql
   ```
4. **Coordinar con el equipo de desarrollo:** Asegurar que ninguna aplicacion este consultando la tabla en el momento del DROP.
5. **Ejecutar el DROP durante una ventana de mantenimiento programada.**
6. **Como medida de precaucion adicional**, renombrar la tabla en lugar de eliminarla inmediatamente:
   ```sql
   RENAME TABLE ventas TO ventas_deprecated_20260101;
   ```
   Si despues de unos dias no hay problemas, se procede a eliminar la tabla renombrada.
