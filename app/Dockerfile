# Use a minimal base image
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m appuser

# Set working directory inside the container
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the full app folder contents into the container
COPY . .

# Change to non-root user
USER appuser

# Expose the port your app runs on
EXPOSE 8080

# Run the app using Gunicorn
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8080", "main:app"]
