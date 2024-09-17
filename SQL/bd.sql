/* 
  Crear una base de datos en MySQL para almacenar información de videojuegos.
*/
-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS VideoGamesDB;

USE VideoGamesDB;

-- Tabla para Platform
CREATE TABLE IF NOT EXISTS Platform (
    Platform_ID INT PRIMARY KEY AUTO_INCREMENT,
    Platform VARCHAR(50) NOT NULL
);

-- Tabla para Year of Release
CREATE TABLE IF NOT EXISTS Year_Of_Release (
    Year_Of_Release_ID INT PRIMARY KEY AUTO_INCREMENT,
    Year_Of_Release VARCHAR(50) NOT NULL
);

-- Tabla para Genre
CREATE TABLE IF NOT EXISTS Genre (
    Genre_ID INT PRIMARY KEY AUTO_INCREMENT,
    Genre VARCHAR(50) NOT NULL
);

-- Tabla para Company (used for both Publisher and Developer)
CREATE TABLE IF NOT EXISTS Company (
    Company_ID INT PRIMARY KEY AUTO_INCREMENT,
    Company VARCHAR(50) NOT NULL
);

-- Tabla para Rating
CREATE TABLE IF NOT EXISTS Rating (
    Rating_ID INT PRIMARY KEY AUTO_INCREMENT,
    Rating CHAR(5) NOT NULL
);

-- Tabla para Videogame
CREATE TABLE IF NOT EXISTS Videogame (
    Videogame_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Platform INT,
    Year_of_Release INT,
    Genre INT,
    Publisher INT,
    NA_Sales FLOAT,
    EU_Sales FLOAT,
    JP_Sales FLOAT,
    Global_Sales FLOAT,
    Critic_Score FLOAT,
    Critic_Count INT,
    User_Score FLOAT,
    User_Count INT,
    Developer INT,
    Rating INT,
    FOREIGN KEY (Platform) REFERENCES Platform(Platform_ID),
    FOREIGN KEY (Year_of_Release) REFERENCES Year_Of_Release(Year_Of_Release_ID),
    FOREIGN KEY (Genre) REFERENCES Genre(Genre_ID),
    FOREIGN KEY (Publisher) REFERENCES Company(Company_ID),
    FOREIGN KEY (Developer) REFERENCES Company(Company_ID),
    FOREIGN KEY (Rating) REFERENCES Rating(Rating_ID)
);
