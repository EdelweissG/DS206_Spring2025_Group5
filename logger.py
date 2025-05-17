# logging.py

import logging
import os


def get_logger(execution_id: str):
    """
    Returns a logger configured to write to logs_dimensional_data_pipeline.txt with the execution_id.

    Args:
        execution_id (str): The unique identifier for the pipeline run (UUID).

    Returns:
        logging.Logger: A logger instance configured with the execution_id.
    """
    # Define log directory and log file path
    log_dir = 'logs'
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, 'logs_dimensional_data_pipeline.txt')

    # Create logger with the execution_id as part of the name
    logger = logging.getLogger(f'dimensional_data_flow_{execution_id}')
    logger.setLevel(logging.INFO)

    # Avoid adding multiple handlers if the logger is reused
    if not logger.handlers:
        file_handler = logging.FileHandler(log_file)
        formatter = logging.Formatter(
            f'[%(asctime)s] [Execution ID: {execution_id}] [%(levelname)s] %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    return logger
