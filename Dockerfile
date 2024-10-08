# Use the official NGINX image
FROM nginx:alpine

# Install bash and curl (needed for the host-info script)
RUN apk add --no-cache bash curl

# Copy custom index.html to NGINX default location
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Add host-info script
COPY host-info.sh /usr/local/bin/host-info.sh
RUN chmod +x /usr/local/bin/host-info.sh

# Start NGINX and serve host info at /host-info
CMD ["/bin/sh", "-c", "nginx & while true; do /usr/local/bin/host-info.sh | nc -l -p 8080; done"]

# Expose port 80
EXPOSE 80
