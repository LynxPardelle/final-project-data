import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from pymongo import MongoClient, UpdateOne
import os
import argparse

# Command-line argument parser
parser = argparse.ArgumentParser(
    description='Import CSV to databases (MySQL, MongoDB, CSV)')
parser.add_argument('--mysql_user', type=str,
                    default='your_user', help='MySQL username')
parser.add_argument('--mysql_password', type=str,
                    default='your_password', help='MySQL password')
parser.add_argument('--mysql_host', type=str,
                    default='localhost', help='MySQL host')
parser.add_argument('--mysql_database', type=str,
                    default='VideoGamesDB', help='MySQL database name')
parser.add_argument('--mongo_host', type=str,
                    default='localhost', help='MongoDB host')
parser.add_argument('--mongo_port', type=int,
                    default=27017, help='MongoDB port')
parser.add_argument('--mongo_db', type=str,
                    default='VideoGamesDB', help='MongoDB database name')
parser.add_argument('--db_types', type=str, default='csv',
                    help='Database types to import to (mysql, mongodb, csv, all)')
parser.add_argument('--csv_file_path', type=str,
                    default='../bd_source/Video_Games.csv', help='File path')
args = parser.parse_args()

# MySQL connection parameters
mysql_user = args.mysql_user
mysql_password = args.mysql_password
mysql_host = args.mysql_host
mysql_database = args.mysql_database

# MongoDB connection parameters
mongo_host = args.mongo_host
mongo_port = args.mongo_port
mongo_db = args.mongo_db

# Path to the CSV file
csv_file_path = args.csv_file_path

# Create MySQL database connection engine
# This connection string contains the credentials and information needed to connect to the MySQL database
mysql_connection_string = f'mysql+pymysql://{mysql_user}:{
    mysql_password}@{mysql_host}/{mysql_database}'
mysql_engine = create_engine(mysql_connection_string)

# Create MongoDB client
mongo_client = MongoClient(mongo_host, mongo_port)
mongo_database = mongo_client[mongo_db]


def check_mysql_connection():
    """
    Check if the MySQL database connection can be established.
    """
    try:
        with mysql_engine.connect() as connection:
            connection.execute("SELECT 1")
        print("\nMySQL connection successful.")
        return True
    except SQLAlchemyError as e:
        print(f"\nMySQL connection failed: {str(e)}")
        return False


def check_mongodb_connection():
    """
    Check if the MongoDB connection can be established.
    """
    try:
        mongo_client.admin.command('ping')
        print("\nMongoDB connection successful.")
        return True
    except Exception as e:
        print(f"\nMongoDB connection failed: {str(e)}")
        return False


def create_mysql_schema():
    """
    Create the MySQL database schema if it does not exist.
    """
    try:
        with mysql_engine.connect() as connection:
            # Create the database if it does not exist
            connection.execute(
                text(f"CREATE DATABASE IF NOT EXISTS {mysql_database}"))
            connection.execute(text(f"USE {mysql_database}"))

            # Create tables if they do not exist
            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS Platform (
                    Platform_ID INT PRIMARY KEY AUTO_INCREMENT,
                    Platform VARCHAR(50) NOT NULL UNIQUE
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS Year_Of_Release (
                    Year_Of_Release_ID INT PRIMARY KEY AUTO_INCREMENT,
                    Year_Of_Release VARCHAR(50) NOT NULL UNIQUE
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS Genre (
                    Genre_ID INT PRIMARY KEY AUTO_INCREMENT,
                    Genre VARCHAR(50) NOT NULL UNIQUE
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS Company (
                    Company_ID INT PRIMARY KEY AUTO_INCREMENT,
                    Company VARCHAR(50) NOT NULL UNIQUE
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS Rating (
                    Rating_ID INT PRIMARY KEY AUTO_INCREMENT,
                    Rating CHAR(5) NOT NULL UNIQUE
                );
            """))

            connection.execute(text("""
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
                    Other_Sales FLOAT,
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
            """))

            print("\nMySQL schema created or updated successfully.")
    except SQLAlchemyError as e:
        print(f"\nError creating MySQL schema: {str(e)}")


def clean_data(df):
    """
    Clean the provided DataFrame by handling missing values, ensuring correct data types,
    normalizing strings, and removing duplicates.

    Parameters:
    df (DataFrame): The DataFrame containing raw data to be cleaned.

    Returns:
    DataFrame: The cleaned DataFrame.
    """
    # Remove rows where 'Name' is null (games without a name are not useful for analysis)
    df.dropna(subset=['Name'], inplace=True)

    # Fill null values in categorical columns with 'Unknown'
    # This ensures that missing categorical information is replaced with a default value
    categorical_columns = ['Platform', 'Genre',
                           'Publisher', 'Developer', 'Rating']
    for column in categorical_columns:
        df[column].fillna('Unknown')

    # Fill null values in numerical columns with 0
    # This assumes that missing numerical values indicate no data (e.g., no sales, no scores)
    numerical_columns = ['NA_Sales', 'EU_Sales', 'JP_Sales', 'Other_Sales',
                         'Global_Sales', 'Critic_Score', 'Critic_Count', 'User_Score', 'User_Count']
    for column in numerical_columns:
        df[column].fillna(0)

    # Convert specific columns to correct data types, handling possible errors
    # Year_of_Release is converted to an integer; any errors are coerced to NaN and then filled with 0
    df['Year_of_Release'] = pd.to_numeric(
        df['Year_of_Release'], errors='coerce').fillna(0).astype(int)
    # Convert Critic_Score and User_Score to numeric values, coercing errors to NaN
    df['Critic_Score'] = pd.to_numeric(df['Critic_Score'], errors='coerce')
    df['User_Score'] = pd.to_numeric(df['User_Score'], errors='coerce')

    # Normalize platform and genre names
    # Remove extra spaces and standardize format (e.g., platform names in uppercase, genre names capitalized)
    df['Platform'] = df['Platform'].str.strip().str.upper()
    df['Genre'] = df['Genre'].str.strip().str.capitalize()

    # Remove duplicate rows if they exist
    # This ensures that the data does not contain redundant information
    df.drop_duplicates(inplace=True)

    return df


def normalize_and_import_mysql(df):
    """
    Normalize the data and import into the MySQL database according to the given schema.

    Parameters:
    df (DataFrame): The cleaned DataFrame to be imported.
    """
    if not check_mysql_connection():
        print("\nMySQL connection could not be established.")
        return False

    create_mysql_schema()

    try:
        with mysql_engine.connect() as connection:
            # Insert into Platform table
            platforms = df['Platform'].dropna().unique().tolist()
            for platform in platforms:
                connection.execute(text("INSERT IGNORE INTO Platform (Platform) VALUES (:platform)"), {
                                   'platform': platform})

            # Insert into Year_Of_Release table
            years = df['Year_of_Release'].dropna().unique().tolist()
            for year in years:
                connection.execute(text(
                    "INSERT IGNORE INTO Year_Of_Release (Year_Of_Release) VALUES (:year)"), {'year': year})

            # Insert into Genre table
            genres = df['Genre'].dropna().unique().tolist()
            for genre in genres:
                connection.execute(
                    text("INSERT IGNORE INTO Genre (Genre) VALUES (:genre)"), {'genre': genre})

            # Insert into Company table for Publisher and Developer
            companies = pd.concat(
                [df['Publisher'], df['Developer']]).dropna().unique().tolist()
            for company in companies:
                connection.execute(text(
                    "INSERT IGNORE INTO Company (Company) VALUES (:company)"), {'company': company})

            # Insert into Rating table
            ratings = df['Rating'].dropna().unique().tolist()
            for rating in ratings:
                connection.execute(
                    text("INSERT IGNORE INTO Rating (Rating) VALUES (:rating)"), {'rating': rating})

            # Insert into Videogame table with normalized data
            for _, row in df.iterrows():
                connection.execute(text("""
                    INSERT INTO Videogame (
                        Name, Platform, Year_of_Release, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, 
                        Global_Sales, Critic_Score, Critic_Count, User_Score, User_Count, Developer, Rating
                    )
                    VALUES (
                        :name, 
                        (SELECT Platform_ID FROM Platform WHERE Platform = :platform),
                        (SELECT Year_Of_Release_ID FROM Year_Of_Release WHERE Year_Of_Release = :year_of_release),
                        (SELECT Genre_ID FROM Genre WHERE Genre = :genre),
                        (SELECT Company_ID FROM Company WHERE Company = :publisher),
                        :na_sales, :eu_sales, :jp_sales, :other_sales, :global_sales, :critic_score, :critic_count,
                        :user_score, :user_count,
                        (SELECT Company_ID FROM Company WHERE Company = :developer),
                        (SELECT Rating_ID FROM Rating WHERE Rating = :rating)
                    )
                    ON DUPLICATE KEY UPDATE
                        Platform = VALUES(Platform),
                        Year_of_Release = VALUES(Year_of_Release),
                        Genre = VALUES(Genre),
                        Publisher = VALUES(Publisher),
                        NA_Sales = VALUES(NA_Sales),
                        EU_Sales = VALUES(EU_Sales),
                        JP_Sales = VALUES(JP_Sales),
                        Other_Sales = VALUES(Other_Sales),
                        Global_Sales = VALUES(Global_Sales),
                        Critic_Score = VALUES(Critic_Score),
                        Critic_Count = VALUES(Critic_Count),
                        User_Score = VALUES(User_Score),
                        User_Count = VALUES(User_Count),
                        Developer = VALUES(Developer),
                        Rating = VALUES(Rating)
                """), {
                    'name': row['Name'],
                    'platform': row['Platform'],
                    'year_of_release': row['Year_of_Release'],
                    'genre': row['Genre'],
                    'publisher': row['Publisher'],
                    'na_sales': row['NA_Sales'],
                    'eu_sales': row['EU_Sales'],
                    'jp_sales': row['JP_Sales'],
                    'other_sales': row['Other_Sales'],
                    'global_sales': row['Global_Sales'],
                    'critic_score': row['Critic_Score'],
                    'critic_count': row['Critic_Count'],
                    'user_score': row['User_Score'],
                    'user_count': row['User_Count'],
                    'developer': row['Developer'],
                    'rating': row['Rating']
                })

            print("Data normalization and import to MySQL was successful.")
            return True

    except SQLAlchemyError as e:
        # Handle SQLAlchemy errors (e.g., connection issues, insertion problems)
        print(f"\nError during MySQL data normalization and import: {str(e)}")
        return False


def normalize_and_import_mongodb(df):
    """
    Normalize the data and import into the MongoDB database according to the given schema.

    Parameters:
    df (DataFrame): The cleaned DataFrame to be imported.
    """
    if not check_mongodb_connection():
        print("\nMongoDB connection could not be established.")
        return False
    try:
        # Insert unique platforms, genres, years, companies, and ratings into MongoDB collections
        mongo_database['Platform'].insert_many(
            [{'Platform': platform} for platform in df['Platform'].unique()], ordered=False)
        mongo_database['YearOfRelease'].insert_many(
            [{'YearOfRelease': year} for year in df['Year_of_Release'].unique()], ordered=False)
        mongo_database['Genre'].insert_many(
            [{'Genre': genre} for genre in df['Genre'].unique()], ordered=False)
        mongo_database['Company'].insert_many([{'Company': company} for company in pd.concat(
            [df['Publisher'], df['Developer']]).unique()], ordered=False)
        mongo_database['Rating'].insert_many(
            [{'Rating': rating} for rating in df['Rating'].unique()], ordered=False)

        # Insert the game data into the Videogame collection
        videogame_records = df.to_dict('records')
        # Change the Platform, Genre, Publisher, Developer, and Rating fields to their corresponding IDs on MongoDB
        for record in videogame_records:
            record['Platform'] = mongo_database['Platform'].find_one(
                {'Platform': record['Platform']})['_id']
            record['Genre'] = mongo_database['Genre'].find_one(
                {'Genre': record['Genre']})['_id']
            record['Publisher'] = mongo_database['Company'].find_one(
                {'Company': record['Publisher']})['_id']
            record['Developer'] = mongo_database['Company'].find_one(
                {'Company': record['Developer']})['_id']
            record['Rating'] = mongo_database['Rating'].find_one(
                {'Rating': record['Rating']})['_id']
        # Perform a bulk write operation to insert the records into the Videogame collection
        operations = [UpdateOne({'Name': record['Name']}, {
                                '$set': record}, upsert=True) for record in videogame_records]
        mongo_database['Videogame'].bulk_write(operations)

        print("\nData normalization and import to MongoDB was successful.")

    except Exception as e:
        print(
            f"\nError during MongoDB data normalization and import: {str(e)}")
        return False


def import_csv(csv_file_path, db_types='csv'):
    """
    Import the cleaned data from a CSV file to the specified database types (MySQL, MongoDB, CSV, or combinations).
    If an invalid database type is provided, display a summary of the DataFrame.
    If connections to MySQL and MongoDB fail, export to CSV and display a summary only once.

    Parameters:
    csv_file_path (str): The path to the CSV file to be imported.
    db_types (str): The types of databases to import the data to ('mysql', 'mongodb', 'csv', 'all', or combinations).
    """
    valid_db_types = {'mysql', 'mongodb', 'csv', 'all'}
    invalid_db_type_provided = False
    mysql_success = False
    mongodb_success = False
    already_cleaned = False

    try:
        # Load data from CSV
        if not os.path.isfile(csv_file_path):
            raise FileNotFoundError(
                f"CSV file not found at path: {csv_file_path}")
        cleaned_csv_path = os.path.join(os.path.dirname(
            csv_file_path), 'Video_GamesCleaned.csv')
        if not os.path.isfile(cleaned_csv_path):
            # Read the CSV file into a pandas DataFrame
            df = pd.read_csv(csv_file_path)

            # Clean the data using the defined function
            # Perform data cleaning to handle missing values, incorrect data types, and normalization
            df = clean_data(df)
        else:
            print("\nUsing cleaned data from previous run.")
            already_cleaned = True
            df = pd.read_csv(cleaned_csv_path)

        # Split db_types by commas and trim whitespace
        db_types_list = [db_type.strip().lower()
                         for db_type in db_types.split(',')]

        # Validate database types
        for db_type in db_types_list:
            if db_type not in valid_db_types:
                print(f"\nInvalid database type: {
                      db_type}. Please choose from 'mysql', 'mongodb', 'csv', or 'all'.")
                invalid_db_type_provided = True

        # Import the data to the specified databases
        if 'mysql' in db_types_list or 'all' in db_types_list:
            mysql_success = normalize_and_import_mysql(df)

        if 'mongodb' in db_types_list or 'all' in db_types_list:
            mongodb_success = normalize_and_import_mongodb(df)

        if ('csv' in db_types_list or 'all' in db_types_list or (not mysql_success and not mongodb_success)) and already_cleaned == False:
            df.to_csv(cleaned_csv_path, index=False)
            print(f"\nCleaned data has been exported to CSV: {
                  cleaned_csv_path}")

        # If any invalid db_type was provided, show the DataFrame summary
        if invalid_db_type_provided or (not mysql_success and not mongodb_success):
            print("\nInvalid database type(s) provided or error in the connection of the database type(s). Showing data summary instead:")
            print("\n", df.head(), "\n...\n", df.tail())

    except FileNotFoundError as e:
        print(f"\nError: {str(e)}")
    except Exception as e:
        print(f"\nAn unexpected error occurred: {str(e)}")


if __name__ == "__main__":
    # Run the import_csv function with the specified database types
    import_csv(csv_file_path, args.db_types)
# Example usage
# Import to MySQL and MongoDB:
# python import_clean_csv_mysql.py --mysql_user=root --mysql_password=secret --mysql_host=localhost --mysql_database=VideoGamesDB --mongo_host=localhost --mongo_port=27017 --mongo_db=VideoGamesDB --db_types=all --csv_file_path=../bd_source/Video_Games.csv
# Import to CSV only:
# python import_clean_csv_mysql.py --db_types=csv --csv_file_path=../bd_source/Video_Games.csv
