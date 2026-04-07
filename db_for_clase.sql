-- =============================================
-- CREACION DE TABLAS (SI NO EXISTEN)
-- =============================================

CREATE DATABASE IF NOT EXISTS  database_store;

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    fecha DATE NOT NULL,
    producto VARCHAR(100),
    cantidad INT,
    precio_unitario DECIMAL(10,2)
);

CREATE TABLE devoluciones (
    id_devolucion INT PRIMARY KEY,
    id_venta INT,
    fecha DATE NOT NULL,
    motivo VARCHAR(200),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
);

-- =============================================
-- INSERCION DE DATOS: VENTAS
-- =============================================

INSERT INTO ventas (id_venta, fecha, producto, cantidad, precio_unitario) VALUES
(1, '2024-01-15', 'Laptop Pro 14', 1, 1299.99),
(2, '2024-01-20', 'Monitor 24"', 2, 189.50),
(3, '2024-01-25', 'Teclado Mecanico', 1, 89.99),
(4, '2024-02-05', 'Laptop Pro 14', 1, 1299.99),
(5, '2024-02-10', 'Mouse Inalambrico', 3, 29.99),
(6, '2024-02-15', 'Monitor 24"', 1, 189.50),
(7, '2024-03-01', 'Auriculares Bluetooth', 2, 79.99),
(8, '2024-03-12', 'Laptop Air 13', 1, 999.99),
(9, '2024-03-20', 'Teclado Mecanico', 2, 89.99),
(10, '2024-04-03', 'Monitor 27" 4K', 1, 349.99),
(11, '2024-04-10', 'Laptop Pro 14', 1, 1299.99),
(12, '2024-04-18', 'Mouse Inalambrico', 1, 29.99),
(13, '2024-05-05', 'Auriculares Bluetooth', 1, 79.99),
(14, '2024-05-15', 'Laptop Air 13', 2, 999.99),
(15, '2024-05-22', 'Monitor 24"', 3, 189.50),
(16, '2024-06-01', 'Laptop Pro 14', 1, 1399.99), -- cambio de precio
(17, '2024-06-10', 'Teclado Mecanico', 1, 94.99),
(18, '2024-06-20', 'Monitor 27" 4K', 1, 349.99),
(19, '2024-07-04', 'Auriculares Bluetooth', 4, 79.99),
(20, '2024-07-19', 'Laptop Air 13', 1, 999.99),
(21, '2024-08-02', 'Mouse Inalambrico', 2, 29.99),
(22, '2024-08-15', 'Laptop Pro 14', 1, 1399.99),
(23, '2024-08-25', 'Monitor 24"', 1, 189.50),
(24, '2024-09-05', 'Teclado Mecanico', 1, 94.99),
(25, '2024-09-18', 'Laptop Air 13', 1, 1049.99), -- nuevo precio
(26, '2024-10-01', 'Monitor 27" 4K', 2, 349.99),
(27, '2024-10-10', 'Auriculares Bluetooth', 1, 84.99),
(28, '2024-10-20', 'Laptop Pro 14', 1, 1399.99),
(29, '2024-11-05', 'Mouse Inalambrico', 1, 29.99),
(30, '2024-11-15', 'Teclado Mecanico', 2, 94.99),
(31, '2024-11-25', 'Monitor 24"', 1, 189.50),
(32, '2024-12-02', 'Laptop Air 13', 1, 1049.99),
(33, '2024-12-12', 'Auriculares Bluetooth', 3, 84.99),
(34, '2024-12-20', 'Monitor 27" 4K', 1, 349.99),
(35, '2024-12-28', 'Laptop Pro 14', 1, 1399.99);

-- =============================================
-- INSERCION DE DATOS MOCK: DEVOLUCIONES
-- =============================================
-- Se registran devoluciones de algunas de las ventas anteriores.
-- No todas las ventas tienen devolucion, y algunas tienen mas de una.
-- Las fechas de devolucion son posteriores a la venta.

INSERT INTO devoluciones (id_devolucion, id_venta, fecha, motivo) VALUES
(1, 2, '2024-01-22', 'Producto danado en el envio'),
(2, 5, '2024-02-12', 'El cliente cambio de opinion'),
(3, 5, '2024-02-14', 'Error en la orden (duplicada)'),
(4, 8, '2024-03-18', 'No cumple expectativas de rendimiento'),
(5, 11, '2024-04-12', 'Caja abierta / producto usado'),
(6, 14, '2024-05-20', 'Defecto de fabrica'),
(7, 16, '2024-06-05', 'No enciende'),
(8, 19, '2024-07-10', 'Color incorrecto'),
(9, 19, '2024-07-11', 'Faltan accesorios'),
(10, 22, '2024-08-18', 'Arrepentimiento de compra'),
(11, 26, '2024-10-05', 'Pantalla con pixeles muertos'),
(12, 28, '2024-10-25', 'Tecla defectuosa'),
(13, 31, '2024-11-28', 'Recibio producto equivocado'),
(14, 33, '2024-12-15', 'Sonido distorsionado'),
(15, 35, '2024-12-30', 'Llego tarde para regalo');