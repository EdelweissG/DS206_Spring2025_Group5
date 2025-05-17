# pipeline_dimensional_data/loader.py

import pandas as pd
from utils import get_db_connection

def load_sheet_to_table(conn, excel_path, sheet_name, table_name, date_col=None):
    """
    Load one sheet from an Excel file into a staging table.
    """
    # Read the sheet into a DataFrame
    df = pd.read_excel(excel_path, sheet_name=sheet_name)
    # Convert pandas NaN → None for SQL NULL
    df = df.where(pd.notnull(df), None)
    # If you have a date column, ensure it’s datetime
    if date_col and date_col in df.columns:
        df[date_col] = pd.to_datetime(df[date_col])

    # Prepare INSERT
    cols = list(df.columns)
    placeholders = ", ".join("?" for _ in cols)
    insert_sql = f"INSERT INTO {table_name} ({', '.join(cols)}) VALUES ({placeholders})"

    # Execute batch insert
    cursor = conn.cursor()
    cursor.fast_executemany = True
    cursor.executemany(insert_sql, df.values.tolist())
    conn.commit()

def main():
    conn = get_db_connection("sql_server_config.cfg")
    excel_file = "raw_data_source.xlsx"

    # Load each sheet → staging table
    load_sheet_to_table(conn, excel_file, "Customers", "dbo.Staging_Customers", date_col="LoadDate")
    load_sheet_to_table(conn, excel_file, "Orders",    "dbo.Staging_Orders",    date_col="LoadDate")
    load_sheet_to_table(conn, excel_file, "Products",  "dbo.Staging_Products",  date_col="LoadDate")
    # Add more as needed...

if __name__ == "__main__":
    main()
