-- Motor utilizado: SQL Server
-- Preentrega 4 - Consultas de negocio de RetailPro

USE Ventas_Tech_DB;
GO

-- Consulta 1: Resumen ejecutivo mensual
-- Se incluye el año para no mezclar el mismo mes de años diferentes.
SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM dbo.ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- Consulta 2: Los 5 productos con mayor facturación
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_facturado DESC, id_producto;

-- Consulta 3: Clientes con más de un pedido
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC, id_cliente;

-- Consulta 4: Comparación con el promedio de facturación mensual
-- El promedio se calcula sobre los meses que tienen ventas registradas.
;WITH ventas_mensuales AS (
    SELECT
        YEAR(fecha_venta) AS anio,
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM dbo.ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
)
SELECT
    anio,
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_mensuales)
            THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM ventas_mensuales)
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM ventas_mensuales
ORDER BY anio, mes;

-- Hallazgos sobre los datos cargados en el Módulo 3:
-- 1. En marzo de 2024 se facturaron 6444,00 en 10 pedidos.
--    El ticket promedio fue de 644,40. Es el único mes cargado,
--    por lo que la consulta 4 devuelve 'Igual al promedio'.
-- 2. El producto 1 lidera la facturación con 3600,00 y 3 unidades.
--    Representa aproximadamente el 55,87 % del total facturado.
-- 3. Los 5 clientes realizaron 2 pedidos cada uno. El cliente 1
--    fue el que más gastó, con un total de 2640,00.
