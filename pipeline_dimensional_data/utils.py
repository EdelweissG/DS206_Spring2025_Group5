import configparser
import pyodbc

def get_db_connection(cfg_path="sql_server_config.cfg"):
    cfg = configparser.ConfigParser()
    cfg.read(cfg_path)

    # Accept either uppercase or lowercase section name
    if "sql_server" in cfg:
        section = "sql_server"
    elif "SQL_SERVER" in cfg:
        section = "SQL_SERVER"
    else:
        raise KeyError("Missing [sql_server] or [SQL_SERVER] section in config")

    s = cfg[section]

    # Windows auth?
    if s.getboolean("trusted_connection", fallback=False):
        conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            f"SERVER={s['server']};DATABASE={s['database']};"
            "Trusted_Connection=yes"
        )
    else:
        conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            f"SERVER={s['server']};DATABASE={s['database']};"
            f"UID={s.get('user', s.get('username'))};PWD={s['password']}"
        )

    return pyodbc.connect(conn_str)
