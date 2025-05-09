# Use a minimal base image
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY app/ ./app/

# Change to non-root user
USER appuser

# Expose port and run app
EXPOSE 8080
CMD ["python", "app/main.py"]
