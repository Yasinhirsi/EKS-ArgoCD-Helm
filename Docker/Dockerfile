# Use Python's built-in HTTP server (minimal, no vulnerabilities)
FROM python:3.12-alpine
# Copy application files
WORKDIR /app
COPY ../ /app/
# Expose port
EXPOSE 80
# Run simple HTTP server
CMD ["python", "-m", "http.server", "80"]
