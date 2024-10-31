# Use Python 3.11 as base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Set up virtual environment and install dependencies
RUN python3.11 -m venv /app/.venv \
    && . /app/.venv/bin/activate \
    && python3.11 -m pip install --upgrade pip \
    && python3.11 -m pip install -r requirements.txt

# Copy the rest of the application
COPY . .

# Make sure we use the Python from virtual environment
ENV PATH="/app/.venv/bin:$PATH"

# Add a startup message
RUN echo '#!/bin/sh' > /app/start.sh \
    && echo 'echo "Starting telegram bot with $(which python3.11)"' >> /app/start.sh \
    && echo 'python3.11 main.py' >> /app/start.sh \
    && chmod +x /app/start.sh

# Command to run the application
CMD ["/app/start.sh"]
