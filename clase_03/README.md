### 1. Panorama general: objetos de BD y herramientas

**¿Qué es?**  
Introducción a los objetos que componen una base de datos (tablas, vistas, índices, procedimientos, funciones, triggers) y las herramientas para gestionarlos (SSMS, pgAdmin, DBeaver, etc.).

**Caso de uso:**  
Un equipo empieza un proyecto nuevo y necesita elegir el motor de BD y las herramientas de administración, entendiendo qué objetos van a crear.

---

### 2. Conceptos de integridad referencial y claves

**¿Qué es?**  
Reglas que garantizan que las relaciones entre tablas sean coherentes. Una clave foránea (FK) debe coincidir con una clave primaria (PK) existente o ser NULL.

**Caso de uso:**  
En un sistema de pedidos, evitar que un detalle de pedido haga referencia a un producto que ya fue eliminado.

---

### 3. Estrategias de indexación y tipos de datos apropiados

**¿Qué es?**  
Los índices aceleran las consultas (ej. B-tree, hash). Elegir el tipo de dato correcto (INT vs VARCHAR, fecha vs texto) ahorra espacio y mejora rendimiento.

**Caso de uso:**  
Una tabla de ventas con millones de filas: crear un índice sobre `fecha_venta` para que los reportes mensuales sean rápidos.

---

### 4. Teoría de normalización y casos prácticos

**¿Qué es?**  
Proceso para eliminar redundancias y dependencias problemáticas mediante formas normales (1FN, 2FN, 3FN, BCNF).

**Caso de uso:**  
Una tabla de clientes con múltiples teléfonos y direcciones repetidas se normaliza en tablas separadas `Clientes`, `Telefonos`, `Direcciones`.

---

### 5. Patrones de diseño: vistas, procedimientos y funciones

**¿Qué es?**  
Vistas (consultas almacenadas), procedimientos (bloques de lógica sin retorno) y funciones (retornan un valor). Ayudan a encapsular lógica y reutilizar código.

**Caso de uso:**  
Crear una vista `v_ventas_mensuales` para que el equipo de reporting no tenga que escribir joins complejos cada vez.

---

### 6. Implementación avanzada de PK/FK y claves compuestas

**¿Qué es?**  
Claves primarias formadas por múltiples columnas (compuestas) y claves foráneas que referencian esas claves compuestas. Incluye manejo de `ON DELETE CASCADE` / `ON UPDATE CASCADE`.

**Caso de uso:**  
En una tabla `DetallePedido` con PK compuesta (`pedido_id`, `producto_id`), y una FK desde `Devoluciones` que referencia ambas columnas.

---

### 7. Crear tablas y constraints (ejemplos cross-DB)

**¿Qué es?**  
Sintaxis para crear tablas con restricciones (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`) en diferentes motores (PostgreSQL, MySQL, SQL Server, SQLite).

**Caso de uso:**  
Migrar un esquema de MySQL a PostgreSQL manteniendo las mismas reglas de integridad y restricciones.

---

### 8. Procedimientos y funciones (ejercicios prácticos)

**¿Qué es?**  
Procedimientos (`PROCEDURE`) para operaciones que no retornan un valor o retornan múltiples resultados. Funciones (`FUNCTION`) que retornan un escalar o una tabla.

**Caso de uso:**  
Escribir una función `calcular_iva(precio NUMERIC)` que se use en múltiples consultas de facturación.

---

### 9. Triggers para auditoría: patrones y ejemplos

**¿Qué es?**  
Disparadores que ejecutan código automáticamente ante eventos `INSERT`, `UPDATE`, `DELETE`. Muy usados para auditoría (registrar quién, cuándo y qué cambió).

**Caso de uso:**  
Un trigger en la tabla `Empleados` que, al actualizar el salario, inserte un registro en `Auditoria_Salarios` con usuario y fecha.

---

### 10. Implementación práctica: esquema normalizado y denormalización dirigida

**¿Qué es?**  
Partir de un esquema normalizado (evita anomalías) y, cuando el rendimiento lo exija, aplicar denormalización controlada (agregar redundancias para evitar joins costosos).

**Caso de uso:**  
Un dashboard de ventas en tiempo real: se normaliza el OLTP, pero se crea una tabla denormalizada `resumen_ventas_diarias` para consultas rápidas.

---

### 11. Validaciones avanzadas: CHECK, DEFAULTs y columnas calculadas

**¿Qué es?**  
- `CHECK`: restricción a nivel de fila (ej. edad >= 18).  
- `DEFAULT`: valor por defecto si no se provee.  
- Columnas calculadas (generadas): su valor se deriva de otras columnas (ej. `total = precio * cantidad`).

**Caso de uso:**  
En una tabla `Personas`, `CHECK (sexo IN ('M','F'))`, `DEFAULT activo = TRUE`, y columna generada `nombre_completo = nombre || ' ' || apellido`.


A continuación, encontrarás los **puntos clave** teóricos y **cinco ejemplos prácticos** en MySQL para impartir una clase sobre diseño y gestión de bases de datos. Los ejemplos están pensados para ser ejecutados en orden y mostrar conceptos como normalización, índices, vistas, procedimientos y triggers.

---

## Puntos clave (para tu diapositiva o resumen)

1. **Integridad referencial y claves primarias/foráneas**  
   - Garantizan que las relaciones entre tablas sean consistentes.  
   - `PRIMARY KEY` (única y no nula), `FOREIGN KEY` (referencia a PK de otra tabla).  

2. **Estrategias de indexación**  
   - Los índices aceleran `SELECT`, `WHERE`, `JOIN`, `ORDER BY`.  
   - Tipos: simples (una columna) o compuestos (varias columnas).  
   - Impacto: mejora lecturas, ralentiza escrituras (`INSERT`, `UPDATE`, `DELETE`).  

3. **Diseño de esquemas normalizados**  
   - Eliminar redundancias y anomalías (1FN, 2FN, 3FN).  
   - Separar entidades en tablas relacionadas por claves foráneas.  

4. **Vistas, procedimientos y funciones**  
   - **Vista**: consulta almacenada que se comporta como una tabla virtual.  
   - **Procedimiento**: bloque de código que puede modificar datos y aceptar parámetros.  
   - **Función**: retorna un valor escalar o tabla, se usa en expresiones SQL.  

5. **Triggers para auditoría y logging**  
   - Se ejecutan automáticamente ante eventos `INSERT`, `UPDATE`, `DELETE`.  
   - Útiles para registrar cambios (quién, cuándo, qué valor antiguo/nuevo).  

---

## Ejemplos prácticos para clase

### 1. Esquema normalizado para ventas (clientes, productos, órdenes)

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS ventas_db;
USE ventas_db;

-- Tabla clientes (entidad independiente)
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

-- Tabla productos (entidad independiente)
CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL DEFAULT 0
);

-- Tabla órdenes (relaciona clientes con productos, evitando redundancia)
CREATE TABLE ordenes (
    orden_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_orden DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- Tabla detalle_orden (resuelve relación muchos a muchos entre órdenes y productos)
CREATE TABLE detalle_orden (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL, -- se copia de productos para historial
    FOREIGN KEY (orden_id) REFERENCES ordenes(orden_id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);
```

### 2. Índice compuesto para optimizar consultas frecuentes

**Supongamos** que a menudo buscamos órdenes de un cliente en un rango de fechas:

```sql
-- Consulta lenta sin índice (especialmente con muchos datos)
SELECT * FROM ordenes 
WHERE cliente_id = 5 AND fecha_orden BETWEEN '2025-01-01' AND '2025-12-31';

-- Crear índice compuesto (cliente_id + fecha_orden)
CREATE INDEX idx_cliente_fecha ON ordenes(cliente_id, fecha_orden);
```

**Explicación**: MySQL usará este índice para filtrar primero por `cliente_id` y luego por rango de fechas, evitando escanear toda la tabla.

### 3. Vista que consolida información para reportes

```sql
-- Vista: resumen de ventas por cliente
CREATE VIEW v_reporte_ventas AS
SELECT 
    c.cliente_id,
    c.nombre AS cliente,
    o.orden_id,
    o.fecha_orden,
    SUM(d.cantidad * d.precio_unitario) AS total_orden
FROM clientes c
JOIN ordenes o ON c.cliente_id = o.cliente_id
JOIN detalle_orden d ON o.orden_id = d.orden_id
GROUP BY o.orden_id;

-- Uso: consultar ventas de un cliente
SELECT * FROM v_reporte_ventas WHERE cliente_id = 3;
```

**Ventaja**: Los usuarios (o reportes) no necesitan escribir los joins cada vez.

### 4. Procedimiento almacenado para actualizar stock tras una venta

El procedimiento recibe `orden_id` y actualiza el stock de cada producto restando la cantidad vendida.

```sql
DELIMITER //

CREATE PROCEDURE actualizar_stock_por_orden(IN p_orden_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    
    -- Cursor para recorrer los productos de la orden
    DECLARE cur CURSOR FOR 
        SELECT producto_id, cantidad FROM detalle_orden WHERE orden_id = p_orden_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_producto_id, v_cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Actualizar stock (control básico: no permitir stock negativo)
        UPDATE productos 
        SET stock = stock - v_cantidad 
        WHERE producto_id = v_producto_id AND stock >= v_cantidad;
        
        -- Opcional: si no se actualizó ninguna fila, lanzar advertencia
        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Stock insuficiente para el producto ', v_producto_id;
        END IF;
    END LOOP;
    
    CLOSE cur;
END //

DELIMITER ;

-- Ejemplo de uso:
-- CALL actualizar_stock_por_orden(1);
```

### 5. Trigger que registra cambios en una tabla de usuarios para auditoría

Primero creamos una tabla de auditoría y luego el trigger.

```sql
-- Tabla de auditoría
CREATE TABLE audit_usuarios (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    accion VARCHAR(10),        -- 'INSERT', 'UPDATE', 'DELETE'
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario_bd VARCHAR(50),    -- usuario de MySQL que hizo el cambio
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios que queremos auditar
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

-- Trigger AFTER UPDATE (también se pueden crear para INSERT y DELETE)
DELIMITER //

CREATE TRIGGER trg_audit_usuarios_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO audit_usuarios (usuario_id, accion, valor_anterior, valor_nuevo, usuario_bd)
    VALUES (
        OLD.usuario_id,
        'UPDATE',
        CONCAT('nombre=', OLD.nombre, ' email=', OLD.email),
        CONCAT('nombre=', NEW.nombre, ' email=', NEW.email),
        USER()   -- función que devuelve el usuario actual de MySQL
    );
END //

DELIMITER ;

-- Ejemplo de prueba:
INSERT INTO usuarios (nombre, email) VALUES ('Ana López', 'ana@mail.com');
UPDATE usuarios SET email = 'ana.nueva@mail.com' WHERE usuario_id = 1;

-- Verificar auditoría
SELECT * FROM audit_usuarios;
```

**Ampliación**: Puedes crear triggers similares para `INSERT` y `DELETE` según necesidad.

