# TechPathway BothCamp — main application (storefront + admin)
FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Create a dedicated non-root user and give it ownership of the application
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

# Run the application as a non-root user
USER appuser

ENV FLASK_ENV=production \
    PYTHONUNBUFFERED=1

EXPOSE 5111

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://localhost:5111/health').status==200 else sys.exit(1)"

# Run Weekly Call with Gunicorn.
# Logs are written to stdout/stderr so Docker and Kubernetes can collect them.
CMD ["gunicorn", "--bind", "0.0.0.0:5111", "--workers", "3", "--timeout", "30", \
     "--access-logfile", "-", "--error-logfile", "-", "wsgi:app"]