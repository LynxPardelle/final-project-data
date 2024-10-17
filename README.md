# Proyecto Final Data

## Objetivo del proyecto

El objetivo del proyecto es analizar la información de una base de datos de las ventas de videojuegos a través de los años, para poder predecir el éxito de un videojuego en el mercado con respecto a sus ventas y géneros.

[Miro entidad-relación y columnas de las tablas que contienen la información a analizar.](https://miro.com/app/board/uXjVNwT4l0w=/?share_link_id=595304181901)
[Análisis de Ventas de Videojuegos](https://docs.google.com/document/d/1v_NK6nnpS6LK-YPITEaeL0-POFv9t9qedw9JwTz19PI/edit?usp=sharing)

## Comandos para instalar y lanzar el proyecto de python

cd python
venv\Scripts\activate
pip install -r requirements.txt

En caso de añadir nuevas dependencias al proyecto, se puede generar el archivo requirements.txt con el siguiente comando:
pip freeze > requirements.txt

# Ejemplos de uso

- Import to MySQL and MongoDB:
- python import_clean_csv_mysql.py --mysql_user=root --mysql_password=secret --mysql_host=localhost --mysql_database=VideoGamesDB --mongo_host=localhost --mongo_port=27017 --mongo_db=VideoGamesDB --db_types=all --csv_file_path=../bd_source/Video_Games.csv
- Import to CSV only: python import_clean_csv_mysql.py --db_types=csv --csv_file_path=../bd_source/Video_Games.csv
