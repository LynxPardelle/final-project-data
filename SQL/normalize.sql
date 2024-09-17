/* 
  Cargar datos desde un archivo CSV a una tabla temporal en MySQL.
*/
-- Creación de una tabla temporal para almacenar los datos crudos del CSV
CREATE TABLE IF NOT EXISTS Temp_VideoGames (
    Name VARCHAR(100),
    Platform VARCHAR(50),
    Year_of_Release VARCHAR(4),
    Genre VARCHAR(50),
    Publisher VARCHAR(50),
    NA_Sales FLOAT,
    EU_Sales FLOAT,
    JP_Sales FLOAT,
    Other_Sales FLOAT,
    Global_Sales FLOAT,
    Critic_Score FLOAT,
    Critic_Count INT,
    User_Score FLOAT,
    User_Count INT,
    Developer VARCHAR(50),
    Rating CHAR(5)
);
/* 
  ¡¡¡IMPORTANTE!!!
  Pausar aquí y cargar los datos desde el archivo CSV a la tabla temporal.
*/
/* 
  (OPCIONAL) Carga de datos desde un archivo CSV a una tabla temporal en MySQL.
  En caso de encontrarse con errores de seguridad para esto, será necesario importar "manualmente" el csv a la tabla temporal desde el MySQL Workbench.
  Para ello, se puede hacer clic derecho sobre la tabla temporal, seleccionar "Table Data Import Wizard" y seleccionar el archivo CSV.
  Asegurarse de que los campos coincidan correctamente.
*/
-- Carga de datos desde el CSV a la tabla temporal (en MySQL se puede usar LOAD DATA INFILE)
/* LOAD DATA LOCAL INFILE '../bd_cource/Video_Games.csv'
INTO TABLE Temp_VideoGames
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; */
/* 
  Normalizar los datos y llenar las tablas relacionadas
*/
-- Normalización y llenado de la tabla Platform
INSERT INTO Platform (Platform)
SELECT DISTINCT Platform FROM Temp_VideoGames
WHERE Platform IS NOT NULL;

-- Normalización y llenado de la tabla Year_of_Release
INSERT INTO Year_Of_Release (Year_Of_Release)
SELECT DISTINCT Year_of_Release FROM Temp_VideoGames
WHERE Year_of_Release IS NOT NULL;

-- Normalización y llenado de la tabla Genre
INSERT INTO Genre (Genre)
SELECT DISTINCT Genre FROM Temp_VideoGames
WHERE Genre IS NOT NULL;

-- Normalización y llenado de la tabla Company (para Publisher)
INSERT INTO Company (Company)
SELECT DISTINCT Publisher FROM Temp_VideoGames
WHERE Publisher IS NOT NULL;

-- Normalización y llenado de la tabla Company (para Developer)
INSERT INTO Company (Company)
SELECT DISTINCT Developer FROM Temp_VideoGames
WHERE Developer IS NOT NULL;

-- Normalización y llenado de la tabla Rating
INSERT INTO Rating (Rating)
SELECT DISTINCT Rating FROM Temp_VideoGames
WHERE Rating IS NOT NULL;
/* 
  Poblar la tabla principal (Videogame)
*/
-- Insertar en la tabla principal Videogame y vincular los IDs correctos
INSERT INTO Videogame (
    Name, Platform, Year_of_Release, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Global_Sales, 
    Critic_Score, Critic_Count, User_Score, User_Count, Developer, Rating
)
SELECT
    t.Name,
    p.Platform_ID,
    y.Year_Of_Release_ID,
    g.Genre_ID,
    c1.Company_ID AS Publisher_ID,
    t.NA_Sales,
    t.EU_Sales,
    t.JP_Sales,
    t.Global_Sales,
    t.Critic_Score,
    t.Critic_Count,
    t.User_Score,
    t.User_Count,
    c2.Company_ID AS Developer_ID,
    r.Rating_ID
FROM
    Temp_VideoGames t
    LEFT JOIN Platform p ON t.Platform = p.Platform
    LEFT JOIN Year_Of_Release y ON t.Year_of_Release = y.Year_Of_Release
    LEFT JOIN Genre g ON t.Genre = g.Genre
    LEFT JOIN Company c1 ON t.Publisher = c1.Company
    LEFT JOIN Company c2 ON t.Developer = c2.Company
    LEFT JOIN Rating r ON t.Rating = r.Rating;
/* 
  Consultas de prueba para verificar la base de datos
*/
-- Verificar si se cargaron correctamente los videojuegos
SELECT * FROM Videogame LIMIT 10;

-- Verificar si los datos de las plataformas se vincularon correctamente
SELECT v.Name, p.Platform
FROM Videogame v
JOIN Platform p ON v.Platform = p.Platform_ID
LIMIT 10;

-- Consultar la cantidad de juegos por género
SELECT g.Genre, COUNT(v.Videogame_ID) AS GameCount
FROM Videogame v
JOIN Genre g ON v.Genre = g.Genre_ID
GROUP BY g.Genre;
/* 
  Limpieza de la base de datos
*/
-- Eliminar la tabla temporal
DROP TABLE IF EXISTS Temp_VideoGames;
