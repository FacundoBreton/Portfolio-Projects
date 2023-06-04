-- En este trabajo lo que se hizo fue crear una base de datos llamada 'bd_movimientos', luego crear las tablas correspondientes para depsues tener que insertar sus valores.
-- Una vez que se hizo todo eso, se comenzo a contestar algunas preguntas
--Creamos nuestra base de datos, OJO que al crearla asi si nuestro disco se llega a dañar podemos llegar a perder los datos

CREATE DATABASE BD_PRODUCCION


--Otra forma de crearla es asi:

CREATE DATABASE bd_movimientos
ON
(	NAME = bd_movimientos_dat,
		FILENAME = 'C:\Base de datos\bd_movimientos.mdf',
		-- El archivo .mdf va a guardar todas las tablas, registros, nombres de usuarios, etc
		SIZE = 10MB, -- Tama;o minimo del archivo de datos
		MAXSIZE = 50MB, -- Tama;o maximo del archivo de datos
		FILEGROWTH = 5MB -- Porcentaje de crecimiento del archivo de datos
)
LOG ON
(	NAME = bd_movimientos_log,
		FILENAME = 'C:\Base de datos\bd_movimientos.ldf',
		-- El archivo .ldf va a guardar el registro de transacciones, etc
		SIZE = 5MB, -- Tama;o minimo del archivo de datos
		MAXSIZE = 25MB, -- Tama;o maximo del archivo de datos
		FILEGROWTH = 5MB -- Porcentaje de crecimiento del archivo de datos
);
GO


--Ahora agregamos las tablas

CREATE TABLE Proveedores (
IDPROVEEDOR CHAR(10) PRIMARY KEY,
NOMBRE VARCHAR(50),
CATEGORIA VARCHAR(50),
CIUDAD VARCHAR(50)
);

CREATE TABLE Componentes (
IDCOMPONENTE INT PRIMARY KEY,
NOMBRE VARCHAR(50),
COLOR VARCHAR(50),
PESO VARCHAR(10),
CIUDAD VARCHAR(50)
);

CREATE TABLE Articulos (
IDARTICULOS INT PRIMARY KEY,
NOMBRE VARCHAR(50),
CIUDAD VARCHAR(50)
);

CREATE TABLE Envios (
IDCOMPONENTE INT FOREIGN KEY REFERENCES Componentes (IDCOMPONENTE),
IDARTICULOS INT FOREIGN KEY REFERENCES Articulos (IDARTICULOS),
IDPROVEEDOR CHAR(10) FOREIGN KEY REFERENCES Proveedores (IDPROVEEDOR),
CANTIDAD INT 
);

-- Ahora creemas el diagrama de base de datos yendo a la carpeta "Database Diagrams"

-- Ahora agregamos los valores a la tabla

INSERT INTO Proveedores (IDPROVEEDOR, NOMBRE, CATEGORIA, CIUDAD)
VALUES
  (1, 'Carlos', 20, 'Sevilla'),
  (2, 'Juan', 10, 'Madrid'),
  (3, 'Jose', 30, 'Sevilla'),
  (4, 'Inma', 20, 'Sevilla'),
  (5, 'Eva', 30, 'Caceres')

SELECT * FROM Proveedores

INSERT INTO Componentes(IDCOMPONENTE, NOMBRE, COLOR, PESO, CIUDAD)
VALUES
  (1, 'X3A', 'Rojo', 12, 'Sevilla'),
  (2, 'B85', 'Verde', 17, 'Madrid'),
  (3, 'C4B', 'Azul', 17, 'Malaga'),
  (4, 'C4B', 'Rojo', 14, 'Sevilla'),
  (5, 'VT8', 'Azul', 12, 'Madrid'),
  (6, 'C30','Rojo', 19, 'Sevilla')

SELECT * FROM Componentes

INSERT INTO Articulos(IDARTICULOS,NOMBRE,CIUDAD)
VALUES
	(1,'Clasificadora','Madrid'),
	(2,'Perdoradora','Malaga'),
	(3,'Lectora','Caceres'),
	(4,'Consola','Caceres'),
	(5,'Mezcladora','Sevilla'),
	(6,'Terminal','Barcelona'),
	(7,'Cinta','Sevilla')

SELECT * FROM Articulos

INSERT INTO Envios (IDPROVEEDOR,IDCOMPONENTE,IDARTICULOS,CANTIDAD)
VALUES
	(1,1,1,200),
	(1,1,4,700),
	(2,3,1,400),
	(2,3,2,200),
	(2,3,3,200),
	(2,3,4,500),
	(2,3,5,600),
	(2,3,6,400),
	(2,3,7,800),
	(2,5,2,100),
	(3,3,1,200),
	(3,4,2,500),
	(4,6,3,300),
	(4,6,7,300),
	(5,2,2,200),
	(5,2,4,100),
	(5,5,4,500),
	(5,5,7,100),
	(5,6,2,200),
	(5,1,4,100),
	(5,3,4,200),
	(5,4,4,800),
	(5,5,5,400),
	(5,6,4,500)

SELECT * FROM Envios

-- Obtener todos los detalles de todos los articulos de CACERES

SELECT * 
FROM Articulos
WHERE CIUDAD = 'Caceres'

-- Obtener todos los valores de IDPROVEEDORES que abastecen el articulo IDARTICULO = 1

SELECT DISTINCT IDPROVEEDOR
FROM Envios
WHERE IDARTICULOS = 1

-- Obtener la lista de pares de atributos (COLOR,CIUDAD)  de la tabla de componentes eliminando los pares duplicados

SELECT DISTINCT COLOR, CIUDAD
FROM Componentes

-- Obtener de la tabla de articulos los valores de IDARTICULOS y CIUDAD donde el nombre de la ciudad acaba en D o contiene una E

SELECT IDARTICULOS, CIUDAD
FROM Articulos
WHERE 
	CIUDAD LIKE '%d' OR
	CIUDAD LIKE '%e%'

-- Obtener los valores de IDPROVEEDORES para los proveedores que suministran para el articulo IDARTICULO = 1 el compononente IDCOMPONENTE = 1

SELECT IDPROVEEDOR
FROM Envios
WHERE 
	IDARTICULOS = 1 AND
	IDCOMPONENTE = 1

-- Obtener los calores de ART NOMBRE en orden alfabetico para los articulos abastecidos por el IDPROVEEDOR = 1

SELECT a.NOMBRE 
FROM Articulos AS a, Envios AS e
WHERE 
	e.IDPROVEEDOR = 1 AND
	e.IDARTICULOS = a.IDARTICULOS
ORDER BY NOMBRE

-- Obtener los valores de IDCOMPONENTE para los componenetes suministrados para cualquier articulo de MADRID

SELECT DISTINCT IDCOMPONENTE
FROM Envios
WHERE IDARTICULOS IN (
  SELECT IDARTICULOS
  FROM Articulos
  WHERE CIUDAD = 'Madrid'
)

-- Obtener todos los valores de ID de los componentes tales que ningun otro componente tenga un valor de peso inferior

SELECT IDCOMPONENTE
FROM Componentes
WHERE PESO = (
	SELECT MIN(PESO) as Peso
	FROM Componentes
)

-- Obtener los valores de ID para lo proveedores que suministren los articulos ID 1 y 2

SELECT IDPROVEEDOR
FROM Envios
	WHERE IDARTICULOS = 1
INTERSECT
SELECT IDPROVEEDOR
FROM Envios
	WHERE IDARTICULOS = 2

-- Obtener los valores de ID para los proveedores que suministran para un articulo de SEVILLA o MADRID un componente ROJO

SELECT IDPROVEEDOR
FROM Envios e, Articulos a, Componentes c
WHERE e.IDCOMPONENTE = C.IDCOMPONENTE AND 
		e.IDARTICULOS = a.IDARTICULOS AND
			c.COLOR = 'Rojo' AND
				a.CIUDAD IN ('Sevilla','Madrid')

-- Obtener, mediante subconsultas, los valores de ID para los componentes suministrados para algun articulo de SEVILLA por un proveedor de SEVILLA

SELECT IDCOMPONENTE
FROM Envios e
WHERE E.IDARTICULOS IN (
		SELECT IDARTICULOS
		FROM Articulos a
		WHERE a.CIUDAD = 'Sevilla' 
		) 
AND IDPROVEEDOR IN (
		SELECT IDPROVEEDOR
		FROM Proveedores p
		WHERE p.CIUDAD = 'Sevilla' 
		)

-- Obtener todas las ternas (CIUDAD, IDCOMPONENTE, CIUDAD) tales que un proveedor de la primera ciudad suministre el componente especificado para un articulo montado en la segunda ciudad

SELECT p.CIUDAD, e.IDCOMPONENTE, a.CIUDAD
FROM Envios e, Proveedores p, Articulos a
WHERE
	e.IDPROVEEDOR = p.IDPROVEEDOR AND
	e.IDARTICULOS = a.IDARTICULOS

-- Repetir el ejercicio anterior pero sin recuperar las ternas en los que los dos valores de ciudad sean lo mismo

SELECT p.CIUDAD, e.IDCOMPONENTE, a.CIUDAD
FROM Envios e, Proveedores p, Articulos a
WHERE
	e.IDPROVEEDOR = p.IDPROVEEDOR AND
	e.IDARTICULOS = a.IDARTICULOS AND
	p.CIUDAD <> a.CIUDAD

-- Obtener el numero de suministros, el de articulos distintos suministrados y la cantidad total de articulos suministrados por el proveedor ID = 2

SELECT 
	COUNT(*) AS 'Numero de suministros',
	COUNT(DISTINCT IDARTICULOS) AS 'Articulos Suministrados',
	SUM(CANTIDAD) AS 'Total Articulos Suministrados'
FROM Envios
WHERE IDPROVEEDOR = 2