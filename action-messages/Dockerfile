# action-messages — sends order-confirmation emails (with CC) + tracking numbers

FROM python:3.11-slim

# Application directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Create a dedicated non-root user with a valid writable home directory
RUN addgroup --system appgroup && \
    adduser --system \
        --ingroup appgroup \
        --home /home/appuser \
        appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appgroup /app /home/appuser

# Set a valid home directory for the non-root user
ENV HOME=/home/appuser

# Python logs are immediately written to stdout/stderr
ENV PYTHONUNBUFFERED=1

# Run the application as a non-root user
USER appuser

# Action Messages application port
EXPOSE 5001

# Container health check
HEALTHCHECK --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://localhost:5001/health').status==200 else sys.exit(1)"

# Production application server
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "2", "--timeout", "30", "app:app"]
