# pipeline_dimensional_data/loader.py

import pandas as pd
from utils import get_db_connection

def load_sheet_to_table(conn, excel_path, sheet_name, table_name, date_col=None):
    """
    Load one sheet from an Excel file into a staging table.
    """
    df = pd.read_excel(excel_path, sheet_name=sheet_name)
    df = df.where(pd.notnull(df), None)
    if date_col and date_col in df.columns:
        df[date_col] = pd.to_datetime(df[date_col])

    cols = list(df.columns)
    placeholders = ", ".join("?" for _ in cols)
    insert_sql = f"INSERT INTO {table_name} ({', '.join(cols)}) VALUES ({placeholders})"

    cursor = conn.cursor()
    cursor.fast_executemany = True
    cursor.executemany(insert_sql, df.values.tolist())
    conn.commit()

def main():
    conn = get_db_connection("sql_server_config.cfg")
    excel_file = "raw_data_source.xlsx"

    xl = pd.ExcelFile(excel_file)
    sheet_names = xl.sheet_names

    for sheet in sheet_names:
        table_name = f"dbo.Staging_{sheet}"

        load_sheet_to_table(conn, excel_file, sheet, table_name, date_cols=["LoadDate"])


if __name__ == "__main__":
    main()
