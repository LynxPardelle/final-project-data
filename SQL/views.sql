/* 
1. Juegos por Año de Lanzamiento
Descripción: Muestra la cantidad de juegos lanzados por año para diferentes géneros.
 */
CREATE VIEW IF NOT EXISTS GamesByYearAndGenre AS
SELECT 
    y.Year_Of_Release AS Year,
    g.Genre AS Genre,
    COUNT(*) AS TotalGames
FROM
    Videogame v
    JOIN Year_Of_Release y ON v.Year_of_Release = y.Year_Of_Release_ID
    JOIN Genre g ON v.Genre = g.Genre_ID
GROUP BY
    y.Year_Of_Release, g.Genre;

-- Obtener la cantidad de juegos por año y género
SELECT * FROM GamesByYearAndGenre;

-- Obtener la cantidad de juegos por año para un género específico, por ejemplo, "Action"
SELECT * 
FROM GamesByYearAndGenre
WHERE Genre = 'Action';

-- Obtener la cantidad de juegos para un año específico, por ejemplo, 2000
SELECT *
FROM GamesByYearAndGenre
WHERE Year = 2000;
/* 
2. Juegos por Género
Descripción: Muestra la cantidad total de juegos por género.
 */
CREATE VIEW IF NOT EXISTS GamesByGenre AS
SELECT 
    g.Genre AS Genre,
    COUNT(*) AS TotalGames
FROM
    Videogame v
    JOIN Genre g ON v.Genre = g.Genre_ID
GROUP BY
    g.Genre;

-- Obtener la cantidad total de juegos por género
SELECT * FROM GamesByGenre;

-- Obtener la cantidad total de juegos para un género específico, por ejemplo, "Sports"
SELECT * 
FROM GamesByGenre
WHERE Genre = 'Sports';
/* 
3. Juegos por Plataforma
Descripción: Muestra el número de juegos por plataforma.
*/ 
CREATE VIEW IF NOT EXISTS GamesByPlatform AS
SELECT 
    p.Platform AS Platform,
    COUNT(*) AS TotalGames
FROM
    Videogame v
    JOIN Platform p ON v.Platform = p.Platform_ID
GROUP BY
    p.Platform;

-- Obtener la cantidad total de juegos por plataforma
SELECT * FROM GamesByPlatform;

-- Obtener la cantidad total de juegos para una plataforma específica, por ejemplo, "PS2"
SELECT * 
FROM GamesByPlatform
WHERE Platform = 'PS2';
/*
4. Juegos por Plataforma y Género
Descripción: Muestra el número de juegos por plataforma, desglosado por género.
*/
CREATE VIEW IF NOT EXISTS GamesByPlatformAndGenre AS
SELECT 
    p.Platform AS Platform,
    g.Genre AS Genre,
    COUNT(*) AS TotalGames
FROM
    Videogame v
    JOIN Platform p ON v.Platform = p.Platform_ID
    JOIN Genre g ON v.Genre = g.Genre_ID
GROUP BY
    p.Platform, g.Genre;

-- Obtener la cantidad total de juegos por plataforma y género
SELECT * FROM GamesByPlatformAndGenre;

-- Obtener la cantidad de juegos para una plataforma específica y género, por ejemplo, "PS3" y "Action"
SELECT * 
FROM GamesByPlatformAndGenre
WHERE Platform = 'PS3' AND Genre = 'Action';
/* 
5. Promedio de Puntuajes
Descripción: Muestra el promedio de puntuaciones de críticos y usuarios por género.
*/
CREATE VIEW IF NOT EXISTS AverageScoresByGenre AS
SELECT 
    g.Genre,
    AVG(v.Critic_Score) AS AvgCriticScore,
    AVG(v.User_Score) AS AvgUserScore
FROM 
    Videogame v
JOIN 
    Genre g ON v.Genre = g.Genre_ID
GROUP BY 
    g.Genre;

-- Obtener los promedios de puntuaciones por género
SELECT * FROM AverageScoresByGenre;

-- Obtener los promedios de puntuaciones para un género específico, por ejemplo, "Action"
SELECT * FROM AverageScoresByGenre WHERE Genre = 'Action';
/* 
6. Suma de Críticos y Usuarios
Descripción: Muestra la suma total de críticos y usuarios por género.
*/
CREATE VIEW IF NOT EXISTS TotalReviewsByGenre AS
SELECT 
    g.Genre,
    SUM(v.Critic_Count) AS TotalCriticCount,
    SUM(v.User_Count) AS TotalUserCount
FROM 
    Videogame v
JOIN 
    Genre g ON v.Genre = g.Genre_ID
GROUP BY 
    g.Genre;

-- Obtener la suma de críticas y usuarios por género
SELECT * FROM TotalReviewsByGenre;

-- Obtener la suma de críticas y usuarios para un género específico, por ejemplo, "Sports"
SELECT * FROM TotalReviewsByGenre WHERE Genre = 'Sports';
/* 
7. Suma de Ventas Globales por Género
*/
CREATE VIEW IF NOT EXISTS TotalSalesByGenre AS
SELECT 
    g.Genre,
    SUM(v.NA_Sales) AS TotalNASales,
    SUM(v.EU_Sales) AS TotalEUSales,
    SUM(v.JP_Sales) AS TotalJPSales,
    SUM(v.Other_Sales) AS TotalOtherSales
FROM 
    Videogame v
JOIN 
    Genre g ON v.Genre = g.Genre_ID
GROUP BY 
    g.Genre;
-- Obtener todas las sumas de ventas por género
SELECT * FROM TotalSalesByGenre;

-- Obtener las sumas de ventas para un género específico, por ejemplo, "Action"
SELECT * FROM TotalSalesByGenre WHERE Genre = 'Action';
/* 
8. Juegos por Desarrollador y Género
*/
CREATE VIEW IF NOT EXISTS GamesByDeveloperAndGenre AS
SELECT 
    d.Company AS Developer,
    g.Genre,
    COUNT(*) AS GamesCount
FROM 
    Videogame v
JOIN 
    Company d ON v.Developer = d.Company_ID
JOIN 
    Genre g ON v.Genre = g.Genre_ID
GROUP BY 
    d.Company, g.Genre;
-- Obtener la cantidad de juegos por desarrollador y género
SELECT * FROM GamesByDeveloperAndGenre;

-- Obtener la cantidad de juegos para un desarrollador específico, por ejemplo, "Ubisoft"
SELECT * FROM GamesByDeveloperAndGenre WHERE Developer = 'Ubisoft';
