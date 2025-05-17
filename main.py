import configparser
import os

def load_config(path: str = 'sql_server_config.cfg') -> dict:
    """
    Load SQL Server connection settings from a .cfg file.
    Returns a dict with BOTH uppercase keys (Driver, Server, Database…)
    and lowercase aliases (driver, server, database…) so any lookup works.

    Raises:
        FileNotFoundError: if the file isn't found.
        ValueError: if the file doesn't contain a [SQL_SERVER] section.
    """
    if not os.path.isfile(path):
        raise FileNotFoundError(f"Config file not found: {path}")

    parser = configparser.ConfigParser()
    parser.read(path)

    if 'SQL_SERVER' not in parser:
        raise ValueError(f"Missing [SQL_SERVER] section in config file: {path}")

    sec = parser['SQL_SERVER']

    # Map of uppercase→lowercase names
    key_map = {
        'Driver':               'driver',
        'Server':               'server',
        'Database':             'database',
        'Trusted_Connection':   'trusted_connection',
        'Encrypt':              'encrypt',
        'TrustServerCertificate':'trustservercertificate',
        'Username':             'username',
        'Password':             'password',
        'Schema':               'schema'
    }

    cfg: dict = {}

    # Pull values from the file where they exist
    for up, low in key_map.items():
        if low in sec:
            if up == 'Trusted_Connection':
                val = sec.getboolean(low, fallback=False)
            else:
                val = sec.get(low)
            cfg[up] = val
            cfg[low] = val

    # Sanity check: Database must exist
    if 'Database' not in cfg:
        raise ValueError(f"Missing 'database' setting in [SQL_SERVER] section of {path}")

    return cfg
