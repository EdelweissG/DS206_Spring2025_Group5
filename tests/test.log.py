
import uuid
from logging import INFO
from logging import getLogger

# Import your get_logger from the logging.py you created
from logger import get_logger

# Generate execution ID
execution_id = str(uuid.uuid4())

# Get logger (optional: set use_utc=True)
logger = get_logger(execution_id, use_utc=False)

# Log something
logger.info("This is a test log entry.")
