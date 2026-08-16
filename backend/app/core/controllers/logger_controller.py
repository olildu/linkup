import logging
from colorlog import ColoredFormatter

# Define log format
LOG_FORMAT = (
    "%(log_color)s[%(asctime)s] [%(levelname)s] "
    "%(filename)s:%(lineno)d in %(funcName)s() - %(message)s"
)

# Define log format for file (no colors)
FILE_LOG_FORMAT = (
    "[%(asctime)s] [%(levelname)s] "
    "%(filename)s:%(lineno)d in %(funcName)s() - %(message)s"
)

# Color scheme
LOG_COLORS = {
    'DEBUG': 'cyan',
    'INFO': 'green',
    'WARNING': 'yellow',
    'ERROR': 'red',
    'CRITICAL': 'bold_red',
}

# Create handlers
console_handler = logging.StreamHandler()
console_handler.setFormatter(ColoredFormatter(LOG_FORMAT, log_colors=LOG_COLORS))

file_handler = logging.FileHandler("app.log", mode="a", encoding="utf-8")
file_handler.setFormatter(logging.Formatter(FILE_LOG_FORMAT))

# Configure logger
logger_controller = logging.getLogger(__name__)
logger_controller.setLevel(logging.DEBUG)  # Capture all levels
logger_controller.addHandler(console_handler)
logger_controller.addHandler(file_handler)
logger_controller.propagate = False
