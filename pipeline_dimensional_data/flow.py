import logging
from utils import generate_uuid
from pipeline_dimensional_data import tasks

# Configure root logger once for the application
logging.basicConfig(
    format='%(asctime)s %(levelname)s %(message)s',
    level=logging.INFO
)

class DimensionalDataFlow:
    def __init__(self, config_path, database_name, schema_name, table_mappings):
        """
        Initializes the DimensionalDataFlow object with configuration and metadata.

        Args:
            config_path (str): Path to the config file.
            database_name (str): Target database name.
            schema_name (str): Target schema name.
            table_mappings (list of tuples): List of (source_table, destination_table) mappings.
        """
        self.config_path = config_path
        self.database_name = database_name
        self.schema_name = schema_name
        self.table_mappings = table_mappings
        self.execution_id = generate_uuid()  # For tracking/monitoring

        # Get a logger for this execution
        self.logger = logging.getLogger(f"DimensionalDataFlow.{self.execution_id}")
        self.logger.info(f"Initialized pipeline for DB={database_name}, schema={schema_name}, exec_id={self.execution_id}")

    def exec(self, start_date, end_date):
        """
        Executes the ETL pipeline tasks sequentially.

        Args:
            start_date (str): Start date for data ingestion (YYYY-MM-DD).
            end_date (str): End date for data ingestion (YYYY-MM-DD).

        Returns:
            dict: Result of the pipeline execution.
        """
        self.logger.info(f"Starting ETL pipeline {self.execution_id} from {start_date} to {end_date}")

        # Step 1: Create dimensional tables
        result = tasks.create_tables(
            self.config_path,
            self.database_name,
            self.schema_name
        )
        if not result.get('success'):
            self.logger.error(f"Table creation failed: {result.get('error')}")
            return {'success': False, 'task': 'create_tables', 'error': result.get('error')}

        self.logger.info("Tables created successfully.")

        # Step 2: Ingest data from source to destination
        result = tasks.ingest_data(
            self.config_path,
            self.database_name,
            self.schema_name,
            self.table_mappings,
            start_date,
            end_date
        )
        if not result.get('success'):
            self.logger.error(f"Data ingestion failed: {result.get('error')}")
            return {'success': False, 'task': result.get('task'), 'error': result.get('error')}

        self.logger.info("Data ingestion completed successfully.")

        # Pipeline finished
        self.logger.info(f"Pipeline execution {self.execution_id} completed successfully.")
        return {'success': True, 'execution_id': self.execution_id}
