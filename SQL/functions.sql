/* 
  Función que recibe el género y devuelve los juegos por año
 */
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesByYear(GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        Year,
        TotalGames
    FROM 
        GamesByYearAndGenre
    WHERE 
        Genre = GenreName;

DELIMITER ;
-- Obtener juegos por año para el género "Role-Playing"
SELECT * FROM GetGamesByYear('Role-Playing');

/* 
  Función para Juegos por Año de Lanzamiento
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesBySpecificYear(YearInput VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        Genre,
        TotalGames
    FROM 
        GamesByYearAndGenre
    WHERE 
        Year = YearInput;

DELIMITER ;
-- Obtener la cantidad de juegos por género para el año 2000
SELECT * FROM GetGamesBySpecificYear('2000');

/* 
  Función para Juegos por Género
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesBySpecificGenre(GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        TotalGames
    FROM 
        GamesByGenre
    WHERE 
        Genre = GenreName;

DELIMITER ;
-- Obtener la cantidad de juegos del género "Adventure"
SELECT * FROM GetGamesBySpecificGenre('Adventure');

/* 
  Función para Juegos por Plataforma
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesBySpecificPlatform(PlatformName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        TotalGames
    FROM 
        GamesByPlatform
    WHERE 
        Platform = PlatformName;

DELIMITER ;
-- Obtener la cantidad de juegos de la plataforma "X360"
SELECT * FROM GetGamesBySpecificPlatform('X360');

/* 
  Función para Juegos por Plataforma y Género
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesByPlatformAndGenre(PlatformName VARCHAR(50), GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        TotalGames
    FROM 
        GamesByPlatformAndGenre
    WHERE 
        Platform = PlatformName AND Genre = GenreName;

DELIMITER ;
-- Obtener la cantidad de juegos de la plataforma "PS3" y género "Sports"
SELECT * FROM GetGamesByPlatformAndGenre('PS3', 'Sports');

/* 
  Función para Promedio de Puntuajes
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetAverageScores(GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        AvgCriticScore,
        AvgUserScore
    FROM 
        AverageScoresByGenre
    WHERE 
        Genre = GenreName;

DELIMITER ;
-- Prueba para obtener los promedios de puntuación del género "Role-Playing"
SELECT * FROM GetAverageScores('Role-Playing');

/* 
  Función para Suma de Críticos y Usuarios
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetTotalReviews(GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        TotalCriticCount,
        TotalUserCount
    FROM 
        TotalReviewsByGenre
    WHERE 
        Genre = GenreName;

DELIMITER ;
-- Prueba para obtener la suma total de críticas y usuarios para el género "Puzzle"
SELECT * FROM GetTotalReviews('Puzzle');

/* 
  Función para obtener las ventas por género
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetSalesByGenre(GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        TotalNASales,
        TotalEUSales,
        TotalJPSales,
        TotalOtherSales
    FROM 
        TotalSalesByGenre
    WHERE 
        Genre = GenreName;

DELIMITER ;
-- Prueba para obtener las ventas del género "Sports"
SELECT * FROM GetSalesByGenre('Sports');

/* 
  Función para obtener juegos por desarrollador y género
*/
DELIMITER //

CREATE FUNCTION IF NOT EXISTS GetGamesByDeveloperAndGenre(DeveloperName VARCHAR(50), GenreName VARCHAR(50))
RETURNS TABLE
RETURN
    SELECT 
        GamesCount
    FROM 
        GamesByDeveloperAndGenre
    WHERE 
        Developer = DeveloperName AND Genre = GenreName;

DELIMITER ;
-- Prueba para obtener la cantidad de juegos de "EA Sports" en el género "Sports"
SELECT * FROM GetGamesByDeveloperAndGenre('EA Sports', 'Sports');