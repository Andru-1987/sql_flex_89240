-- Crear base de datos
DROP DATABASE ventas_db;
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


USE ventas_db;

-- 1. Insertar Clientes
INSERT INTO clientes (nombre, email, telefono) VALUES
('Juan Pérez', 'juan.perez@email.com', '555-0101'),
('María García', 'maria.garcia@email.com', '555-0102'),
('Carlos López', 'carlos.lopez@email.com', '555-0103'),
('Ana Rodríguez', 'ana.rodriguez@email.com', '555-0104'),
('Luis Fernández', 'luis.fernandez@email.com', '555-0105');

-- 2. Insertar Productos
INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop HP Pavilion', 750.00, 15),
('Mouse Inalámbrico Logitech', 25.50, 100),
('Monitor Samsung 24 pulgadas', 180.00, 30),
('Teclado Mecánico RGB', 45.00, 50),
('Auriculares Bluetooth Sony', 89.99, 25),
('Cable HDMI 2 metros', 12.00, 200),
('Silla Ergonómica', 150.00, 10);

-- 3. Insertar Órdenes
-- Nota: cliente_id hace referencia a los clientes insertados arriba (1 al 5)
INSERT INTO ordenes (cliente_id, fecha_orden) VALUES
(1, '2023-10-01 10:30:00'), -- Orden de Juan Pérez
(2, '2023-10-02 14:15:00'), -- Orden de María García
(1, '2023-10-05 09:00:00'), -- Juan Pérez compra de nuevo
(3, '2023-10-06 16:45:00'), -- Orden de Carlos López
(4, '2023-10-07 11:20:00'); -- Orden de Ana Rodríguez


INSERT INTO ordenes (cliente_id, fecha_orden) VALUES
(5, '2025-03-10 10:30:00'),
(5, '2023-01-10 14:15:00'),
(5, '2026-04-11 09:45:00'),
(5, '2024-02-12 16:20:00'),
(5, '2022-04-13 11:10:00'),
(5, '2026-07-13 18:00:00');

-- 4. Insertar Detalle de Órdenes
-- Nota: 
-- - orden_id corresponde a las órdenes recién creadas.
-- - producto_id corresponde a los productos.
-- - precio_unitario debe coincidir (o ser histórico) con el precio del producto.

-- Orden 1 (Juan): Compró una Laptop y un Mouse
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 750.00), -- 1x Laptop HP
(1, 2, 1, 25.50); -- 1x Mouse

-- Orden 2 (María): Compró 2 Monitores
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
(2, 3, 2, 180.00); -- 2x Monitores

-- Orden 3 (Juan): Compró un Teclado y Auriculares
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
(3, 4, 1, 45.00), -- 1x Teclado
(3, 5, 1, 89.99); -- 1x Auriculares

-- Orden 4 (Carlos): Compró 5 Cables HDMI (compra al por mayor)
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
(4, 6, 5, 12.00); -- 5x Cables HDMI

-- Orden 5 (Ana): Compró una Silla Ergonómica y un Cable extra
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
(5, 7, 1, 150.00), -- 1x Silla
(5, 6, 2, 12.00); -- 2x Cables HDMI


-- indices --> compuestos

CREATE INDEX idx_cliente_fecha ON ordenes(cliente_id,fecha_orden);
-- 1	SIMPLE	ordenes		ref	cliente_id	cliente_id	4	const	6	11.11	Using where
-- 1	SIMPLE	ordenes		range	idx_cliente_fecha	idx_cliente_fecha	10		1	100.00	Using where; Using index

EXPLAIN SELECT * FROM ordenes 
	WHERE cliente_id = 5 AND fecha_orden BETWEEN '2023-01-01' AND '2023-12-31';

    
-- vistas 
CREATE VIEW view_reporte_ventas AS
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



SELECT * FROM  view_reporte_ventas WHERE cliente_id = 2;





USE ventas_db;
DELIMITER //

DROP PROCEDURE IF EXISTS actualizar_stock_por_orden//
CREATE PROCEDURE actualizar_stock_por_orden(IN p_orden_id INT)
BEGIN
    UPDATE productos p
    JOIN detalle_orden d 
        ON p.producto_id = d.producto_id
    SET p.stock = p.stock - d.cantidad
    WHERE d.orden_id = p_orden_id
      AND p.stock >= d.cantidad;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se actualizó stock';
    END IF;
END //
DELIMITER ;

-- Ejemplo de uso:
CALL actualizar_stock_por_orden(1);


SELECT p.producto_id, p.stock, d.cantidad
FROM productos p
JOIN detalle_orden d 
    ON p.producto_id = d.producto_id
WHERE d.orden_id = 1;



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


INSERT INTO usuarios (nombre,email) VALUES ('Laura', 'lau@gmail.com');
SELECT * FROM  usuarios;




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


INSERT INTO usuarios (nombre, email) VALUES ('Ana López', 'ana@mail.com');
UPDATE usuarios SET email = 'laura.nueva@mail.com' WHERE usuario_id = 1;

