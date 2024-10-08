# Use the official NGINX image
FROM nginx:alpine

# Install bash and netcat (nc) to run the host-info service
RUN apk add --no-cache bash netcat-openbsd

# Copy the custom index.html to NGINX default location
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the host-info.sh script to the container
COPY host-info.sh /usr/local/bin/host-info.sh
RUN chmod +x /usr/local/bin/host-info.sh

# Start NGINX and run the host-info service on port 8080
CMD ["/bin/sh", "-c", "nginx & while true; do /usr/local/bin/host-info.sh | nc -l -p 8080; done"]

# Expose port 80 for the web server
EXPOSE 80
