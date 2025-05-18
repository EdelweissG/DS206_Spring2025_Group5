import pyodbc
import configparser

import uuid

def generate_uuid():
    return str(uuid.uuid4())

def load_config(config_path):
    """
    Loads database configuration from a .cfg file.

    Args:
        config_path (str): Path to the configuration file.

    Returns:
        dict: Database connection parameters.
    """
    config = configparser.ConfigParser()
    config.read(config_path)
    # Assuming section 'SQLServer' exists and contains necessary details
    db_config = config['SQLServer']
    return db_config


def read_sql_file(file_path):
    """
    Reads an SQL file from the given path and returns the SQL command as a string.

    Args:
        file_path (str): The file path to the SQL script.

    Returns:
        str: The content of the SQL file as a single string.
    """
    with open(file_path, 'r') as file:
        sql_command = file.read()
    return sql_command


def execute_sql_script(conn_str, sql_command):
    """
    Executes the given SQL command on the database specified by the connection string.

    Args:
        conn_str (str): Database connection string.
        sql_command (str): SQL command to execute.

    Returns:
        None
    """
    try:
        # Establishing the connection
        with pyodbc.connect(conn_str, timeout=10) as conn:
            # Creating a cursor object using the cursor() method
            cursor = conn.cursor()
            # Executing the SQL command
            cursor.execute(sql_command)
            # Committing the transaction
            conn.commit()
            print("SQL script executed successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")


def load_and_execute_sql_file(config_path, file_path):
    """
    Loads SQL commands from a file and executes them on a database using config.

    Args:
        config_path (str): Path to the database configuration file.
        file_path (str): Path to the SQL file to be executed.

    Returns:
        None
    """
    # Load database configuration
    db_config = load_config(config_path)
    # Create connection string
    conn_str = f'DRIVER={db_config["Driver"]};SERVER={db_config["Server"]};DATABASE={db_config["Database"]};UID={db_config["User"]};PWD={db_config["Password"]}'
    # Reading SQL from file
    sql_command = read_sql_file(file_path)
    # Executing SQL
    execute_sql_script(conn_str, sql_command)


def get_sql_config(filename: str, database: str) -> dict:
    """
    Reads SQL configuration details from a `.cfg` file and returns the database connection parameters as a dictionary.

    Args:
        filename (str): The path to the `.cfg` configuration file.
        database (str): The name of the database section in the configuration file.

    Returns:
        dict: A dictionary containing the database connection parameters.

    Raises:
        ValueError: If the driver is unsupported or missing in the configuration file.
    """
    cf = configparser.ConfigParser()
    cf.read(filename)  # Read configuration file

    # Read common parameters
    config = {
        "Driver": cf.get(database, "Driver"),
        "Server": cf.get(database, "Server"),
        "Database": cf.get(database, "Database"),
        "Trusted_Connection": cf.get(database, "Trusted_Connection"),
    }

    # Additional parameters for ODBC Driver 18
    if config["Driver"] == "{ODBC Driver 18 for SQL Server}":
        config["Encrypt"] = cf.get(database, "Encrypt")
        if cf.has_option(database, "TrustServerCertificate"):
            config["TrustServerCertificate"] = cf.get(database, "TrustServerCertificate")
    elif config["Driver"] != "{ODBC Driver 17 for SQL Server}":
        raise ValueError(f"Unsupported driver: {config['Driver']}")

    return config


def create_connection_string(config: dict) -> str:
    """
    Generates a SQL Server connection string from the provided configuration dictionary.

    Args:
        config (dict): A dictionary containing SQL Server connection parameters.
            Expected keys: 'Driver', 'Server', 'Database', 'Trusted_Connection'.
            Optional keys: 'Encrypt', 'TrustServerCertificate'.

    Returns:
        str: The formatted SQL Server connection string.
    """
    # Start with mandatory parameters
    conn_str = (
        f"Driver={config['Driver']};"
        f"Server={config['Server']};"
        f"Database={config['Database']};"
        f"Trusted_Connection={config['Trusted_Connection']};"
    )

    # Append optional parameters if present
    if "Encrypt" in config:
        conn_str += f"Encrypt={config['Encrypt']};"
    if "TrustServerCertificate" in config:
        conn_str += f"TrustServerCertificate={config['TrustServerCertificate']};"

    return conn_str
