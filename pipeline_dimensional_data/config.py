import configparser
import os

def load_config(path: str = 'sql_server_config.cfg') -> dict:
    """
    Load SQL Server connection settings from a .cfg file.
    Default filename is 'sql_server_config.cfg'.

    Raises:
        FileNotFoundError: if the file isn't found at `path`.
        ValueError: if the file doesn't contain a [SQL_SERVER] section.
    """
    # 1. Ensure the file actually exists
    if not os.path.isfile(path):
        raise FileNotFoundError(f"Config file not found: {path}")

    # 2. Parse the file
    parser = configparser.ConfigParser()
    parser.read(path)

    # 3. Verify the section
    if 'SQL_SERVER' not in parser:
        raise ValueError(f"Missing [SQL_SERVER] section in config file: {path}")

    section = parser['SQL_SERVER']

    # 4. Build the connection dict
    conn = {
        'Driver':       section.get('driver'),
        'Server':       section.get('server'),
        'Database':     section.get('database'),
        'Trusted_Connection': section.getboolean('trusted_connection', fallback=False)
    }

    # 5. Only pull username/password if not using Windows auth
    if not conn['Trusted_Connection']:
        conn['Username'] = section.get('username')
        conn['Password'] = section.get('password')

    # 6. Include schema if provided
    if 'schema' in section:
        conn['Schema'] = section.get('schema')

    return conn
