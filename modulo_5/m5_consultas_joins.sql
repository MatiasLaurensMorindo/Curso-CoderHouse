-- Motor utilizado: SQL Server
-- Preentrega 5 - Consultas con JOINs de RetailPro

USE Ventas_Tech_DB;
GO

-- Consulta 1: Vista base del proyecto
-- La categoria sirve para agrupar y la ciudad del cliente para filtrar.
-- Ciudad ya es un atributo geografico de la dimension clientes en M3.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Consulta 2: Clientes registrados que nunca compraron
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.id_cliente;

-- Consulta 3: Productos del catalogo sin ventas
SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM dbo.productos AS p
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
LEFT JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY p.id_producto;

-- Consulta 4: Consolidado de dos periodos con UNION ALL
-- Canal es una etiqueta creada en cada SELECT, no un canal comercial real.
-- Se comparan los dias 1 a 10 con los dias 11 a 31 de marzo de 2024.
-- Los periodos no se superponen: cada venta de marzo se cuenta una vez.
SELECT
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 01 al 10' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '20240301'
      AND fecha_venta < '20240311'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 11 al 31' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '20240311'
      AND fecha_venta < '20240401'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- Resultados esperados con los datos del Modulo 3:
-- Consulta 1: 10 filas, con un total de ventas de 6444,00.
-- Consulta 2: sin filas, porque los 5 clientes tienen compras.
-- Consulta 3: sin filas, porque los 6 productos tienen ventas.
-- Consulta 4: Marzo 01 al 10 = 3620,00; Marzo 11 al 31 = 2824,00.
-- Que las consultas 2 y 3 no devuelvan filas no significa que fallen.
