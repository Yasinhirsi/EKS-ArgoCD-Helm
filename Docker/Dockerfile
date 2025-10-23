# Use specific version for reproducibility
FROM nginx:alpine3.21
# Copy application files to nginx default directory
COPY ../ /usr/share/nginx/html/
# Expose port
EXPOSE 80
# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
