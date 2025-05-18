import logging
import os
from datetime import datetime


def get_logger(execution_id: str, use_utc: bool = False) -> logging.Logger:
    """
    Returns a logger configured to write to a file with execution_id and timestamps.

    Args:
        execution_id (str): Unique identifier for the pipeline run (UUID).
        use_utc (bool): If True, logs timestamps in UTC. Otherwise, uses local time.

    Returns:
        logging.Logger: A configured logger.
    """
    # Log directory and filename
    log_dir = os.path.abspath('logs')
    os.makedirs(log_dir, exist_ok=True)

    # Optional: separate file per run
    log_file = os.path.join(log_dir, f'logs_dimensional_data_pipeline_{execution_id}.txt')

    # Create or get logger
    logger_name = f'dimensional_data_flow_{execution_id}'
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.INFO)

    # Clear any existing handlers to avoid duplicate logs
    if logger.hasHandlers():
        logger.handlers.clear()

    # Create FileHandler with appropriate mode ('w' = overwrite, 'a' = append)
    file_handler = logging.FileHandler(log_file, mode='a')

    # Choose formatter time function (local or UTC)
    class UTCFormatter(logging.Formatter):
        converter = datetime.utcfromtimestamp

    formatter_cls = UTCFormatter if use_utc else logging.Formatter

    formatter = formatter_cls(
        fmt=f'[%(asctime)s] [Execution ID: {execution_id}] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(formatter)

    # Add the file handler to the logger
    logger.addHandler(file_handler)

    # Optional: log startup message
    logger.info(f"Logger initialized for execution ID {execution_id}. Logging to: {log_file}")

    return logger
