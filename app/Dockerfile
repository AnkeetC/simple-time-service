# Use a minimal base image
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m appuser

# Set working directory inside the container
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app folder (from your local project structure) into the container
COPY app/ ./app/

# Change to non-root user
USER appuser

# Expose port for the application
EXPOSE 8080

# Use Gunicorn to run the app in production
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app.main:app"]
