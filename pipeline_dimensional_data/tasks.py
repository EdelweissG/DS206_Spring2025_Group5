import pyodbc
from pipeline_dimensional_data.config import load_config

def create_connection_string(cfg: dict) -> str:
    parts = [
        f"Driver={cfg['Driver']}",
        f"Server={cfg['Server']}",
        f"Database={cfg['Database']}",
        f"Trusted_Connection={'yes' if cfg['Trusted_Connection'] else 'no'}"
    ]
    if cfg.get('Encrypt') is not None:
        parts.append(f"Encrypt={cfg['Encrypt']}")
    if cfg.get('TrustServerCertificate') is not None:
        parts.append(f"TrustServerCertificate={cfg['TrustServerCertificate']}")
    return ";".join(parts) + ";"

def execute_sql(conn_str: str, sql: str, params: tuple = None) -> dict:
    try:
        with pyodbc.connect(conn_str, timeout=10) as conn:
            cursor = conn.cursor()
            cursor.execute(sql, params or ())
            conn.commit()
        return {'success': True}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def create_tables(config_path: str, database_name: str, schema_name: str) -> dict:
    cfg = load_config(config_path)
    conn_str = create_connection_string(cfg)

    ddl = f"""
    IF NOT EXISTS (
      SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
       WHERE TABLE_SCHEMA = '{schema_name}'
         AND TABLE_NAME   = 'dim_example_table'
    )
    BEGIN
      CREATE TABLE {schema_name}.dim_example_table (
        id INT PRIMARY KEY,
        name VARCHAR(255),
        date_created DATETIME
      );
    END
    """
    return execute_sql(conn_str, ddl)

def ingest_data(
    config_path:    str,
    database_name:  str,
    schema_name:    str,
    table_mappings: list[tuple[str, str]],
    start_date:     str,
    end_date:       str
) -> dict:
    cfg = load_config(config_path)
    conn_str = create_connection_string(cfg)

    for src, dst in table_mappings:
        sql = f"""
        INSERT INTO {schema_name}.{dst} (id, name, date_created)
        SELECT id, name, date_created
          FROM {schema_name}.{src}
         WHERE date_created BETWEEN ? AND ?;
        """
        result = execute_sql(conn_str, sql, (start_date, end_date))
        if not result['success']:
            return {
                'success': False,
                'task':    f'ingest_{dst}',
                'error':   result['error']
            }

    return {'success': True}

def run_pipeline(
    config_path:    str,
    database_name:  str,
    schema_name:    str,
    table_mappings: list[tuple[str, str]],
    start_date:     str,
    end_date:       str
) -> dict:
    res = create_tables(config_path, database_name, schema_name)
    if not res['success']:
        return {'success': False, 'stage': 'create_tables', 'error': res.get('error')}

    res = ingest_data(config_path, database_name, schema_name, table_mappings, start_date, end_date)
    if not res['success']:
        return {'success': False, 'stage': 'ingest_data',  'error': res.get('error')}

    return {'success': True}