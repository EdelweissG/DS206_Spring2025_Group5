DS206_Spring2025_Group5

Description

This project implements a Dimensional Data Flow ETL pipeline using Python and SQL Server. It extracts data from source tables, transforms it into dimensional structures (facts and dimensions), and loads it into a target database within a specified date range.

Prerequisites

Windows OS (PowerShell)
Python 3.8 or higher
SQL Server instance accessible with proper credentials
PowerShell execution policy allowing script execution
Installation

Clone the repository:

git clone <repository_url>
cd DS206_Spring2025_Group5
Create and activate a virtual environment:

python -m venv .venv
.\.venv\Scripts\Activate.ps1
(If required) Adjust PowerShell execution policy:

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Install dependencies:

pip install -r requirements.txt
Configuration

Create a file named sql_server_config.cfg in the project root with the following template:

[SQL_SERVER]
Driver = ODBC Driver 17 for SQL Server
Server = <YOUR_SERVER_NAME>
Database = <YOUR_DATABASE_NAME>
Trusted_Connection = yes
; Optional:
; Encrypt = yes
; UID = <username>
; PWD = <password>
Replace placeholders with your actual SQL Server settings.

Usage

Run the ETL pipeline from PowerShell:

python main.py --start-date 1996-01-01 --end-date 1998-01-01 --config-path sql_server_config.cfg
--start-date: Start date for data ingestion (YYYY-MM-DD)
--end-date: End date for data ingestion (YYYY-MM-DD)
--config-path: Path to the config file (default: sql_server_config.cfg)
Project Structure

DS206_SPRING2025_GROUP5/
├── __pycache__/                   # Python bytecode cache (ignored in VCS)
├── .idea/                         # IDE configuration files (JetBrains project settings)
├── .pytest_cache/                 # Pytest cache directory (auto-generated)
├── .venv/                         # Python virtual environment (ignored in VCS)
├── dashboard/                     # Power BI dashboard files
│   └── .DS_Store                  # macOS folder metadata
├── infrastructure_initiation/     # Infrastructure setup scripts
│   ├── dimensional_database_table_creation.sql
│   ├── staging_raw_table_creation.sql
│   └── dimensional_db_table_creation.sql
├── logs/                          # Log outputs
│   └── logs_dimensional_data_pipeline.txt
├── pipeline_dimensional_data/     # ETL modules
│   ├── flow.py                    # Defines the ETL flow logic
│   ├── loader.py                  # Data loading functions
│   ├── tasks.py                   # Task definitions for pipeline
│   ├── utils.py                   # Utility functions for ETL
│   ├── __init__.py                # Package initializer
│   └── queries/                   # SQL query scripts
│       ├── update_dim_DimTerritories.sql
│       ├── update_fact.sql
│       └── update_fact_error.sql
├── tests/                         # Unit tests
│   ├── test_config.py
│   ├── test_flow.py
│   └── test_tasks.py
├── logger.py                      # Logging utilities for the pipeline
├── main.py                        # Entry point script to run the ETL pipeline
├── raw_data_source.xlsx           # Example input data for the ETL process
├── requirements.txt               # Python dependencies
├── sql_server_config.cfg          # SQL Server config file (ignored in VCS)
├── test.py                        # Quick validation script
├── utils.py                       # Helper functions (overlap with ETL utils)
└── README.md                      # Project documentation
