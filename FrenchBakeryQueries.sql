-- Exploracion de datos French Bakery sales

SELECT *
FROM Bakery.dbo.Bakery_Sales;

-- Para saber en que fecha y hora la panaderia vende sus productos

SELECT FORMAT(date,'yyyy-MM-dd') as fecha, FORMAT(time,'HH:mm') as hora, article
FROM Bakery.dbo.Bakery_Sales
ORDER BY date;

-- Cambiar el datatype de las columnas date y time para no repetir la funcion format en el resto de queries

ALTER TABLE Bakery.dbo.Bakery_Sales
ALTER COLUMN date DATE;

ALTER TABLE Bakery.dbo.Bakery_Sales
ALTER COLUMN time time(0);

-- Cambio de datatype columnas que eran float a numeric para obtener resultados sin tantos decimales

ALTER TABLE Bakery.dbo.Bakery_Sales
ALTER COLUMN unit_price numeric(10,2);

ALTER TABLE Bakery.dbo.Bakery_Sales
ALTER COLUMN quantity numeric;

-- Quiero saber que productos son los que mas ha vendido la panaderia con su respectiva cantidad

SELECT article, SUM(quantity) as cantidad_vendida
FROM Bakery.dbo.Bakery_Sales
GROUP BY article
ORDER BY cantidad_vendida DESC;


-- Para saber la cantidad de productos vendidos acumulados

WITH calculo_ventas AS(
SELECT date, SUM(quantity) as Ventas
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ventas,
	SUM(Ventas) OVER (Order by date) as Ventas_Acumuladas
FROM calculo_ventas
GROUP BY date, Ventas
ORDER BY date;


-- Diferencia en la cantidad de unidades vendidas respecto al dia anterior

WITH cantidad_ventas AS(
SELECT date, SUM(quantity) as Ventas
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ventas,
	LAG(Ventas) OVER (Order by date) as Ventas_dia_anterior,
	Ventas - LAG(Ventas) OVER (Order by date) as Diferencia_cantidad_ventas
FROM cantidad_ventas
GROUP BY date, Ventas
ORDER BY date;


-- Ingresos acumulados

WITH cantidad_ventas AS(
SELECT date, SUM(quantity)as cantidad_vendida, SUM(unit_price*quantity) as Ingresos
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ingresos,
	SUM(Ingresos) OVER(ORDER BY date) as Ingresos_Acumulados
FROM cantidad_ventas
GROUP BY date, Ingresos
ORDER BY date;


-- Diferencia en los ingresos respecto al dia anterior

WITH cantidad_ventas AS(
SELECT date, SUM(quantity)as cantidad_vendida, SUM(unit_price*quantity) as Ingresos
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ingresos,
	LAG(Ingresos) OVER (Order by date) as Ingresos_dia_anterior,
	Ingresos - LAG(Ingresos) OVER (Order by date) as Diferencia_Ingresos
FROM cantidad_ventas
GROUP BY date, Ingresos
ORDER BY date;

-- Los ingresos que generan los productos

SELECT article, SUM(unit_price*quantity) as Ingresos_Producto
FROM Bakery.dbo.Bakery_Sales
GROUP BY article
ORDER BY Ingresos_Producto DESC




-- Crear views para posterior visualizaciones


-- Cantidad ventas

USE Bakery
GO
CREATE VIEW cantidad_ventas AS
WITH calculo_ventas AS(
SELECT date, SUM(quantity) as Ventas
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ventas,
	SUM(Ventas) OVER (Order by date) as Ventas_Acumuladas
FROM calculo_ventas
GROUP BY date, Ventas


--diferencia unidades vendidas
USE Bakery
GO
CREATE VIEW diferencia_ventas AS
WITH cantidad_ventas AS(
SELECT date, SUM(quantity) as Ventas
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ventas,
	LAG(Ventas) OVER (Order by date) as Ventas_dia_anterior,
	Ventas - LAG(Ventas) OVER (Order by date) as Diferencia_cantidad_ventas
FROM cantidad_ventas
GROUP BY date, Ventas


-- ingresos acumulados view

USE Bakery
GO
CREATE VIEW ingresos_acumulados AS
WITH cantidad_ventas AS(
SELECT date, SUM(quantity)as cantidad_vendida, SUM(unit_price*quantity) as Ingresos
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ingresos,
	SUM(Ingresos) OVER(ORDER BY date) as Ingresos_Acumulados
FROM cantidad_ventas
GROUP BY date, Ingresos


-- diferencia ingresos dia anterior

USE Bakery
GO
CREATE VIEW diferencia_ingresos AS
WITH cantidad_ventas AS(
SELECT date, SUM(quantity)as cantidad_vendida, SUM(unit_price*quantity) as Ingresos
FROM Bakery.dbo.Bakery_Sales
GROUP BY date
)
SELECT date,
	Ingresos,
	LAG(Ingresos) OVER (Order by date) as Ingresos_dia_anterior,
	Ingresos - LAG(Ingresos) OVER (Order by date) as Diferencia_Ingresos
FROM cantidad_ventas
GROUP BY date, Ingresos



-- Ingresos por producto

USE Bakery
GO
CREATE VIEW ingresos_producto AS
SELECT article, SUM(unit_price*quantity) as Ingresos_Producto
FROM Bakery.dbo.Bakery_Sales
GROUP BY article
