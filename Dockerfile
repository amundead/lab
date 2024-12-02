# Dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables for installation paths
ENV NGINX_VERSION=1.27.3
ENV PHP_VERSION=8.4.1

# Install necessary tools for downloading and extraction
RUN powershell -Command `
    Invoke-WebRequest -Uri https://nginx.org/download/nginx-${NGINX_VERSION}.zip -OutFile C:\\nginx.zip; `
    Expand-Archive -Path C:\\nginx.zip -DestinationPath C:\\; `
    Remove-Item -Force C:\\nginx.zip; `
    Rename-Item -Path C:\\nginx-${NGINX_VERSION} -NewName C:\\nginx

RUN powershell -Command `
    Invoke-WebRequest -Uri https://windows.php.net/downloads/releases/php-${PHP_VERSION}-Win32-vs17-x64.zip -OutFile C:\\php.zip; `
    Expand-Archive -Path C:\\php.zip -DestinationPath C:\\php; `
    Remove-Item -Force C:\\php.zip

# Set up environment variables for PHP
ENV PATH="C:\\php;${PATH}"

# Copy nginx.conf
COPY nginx.conf C:\\nginx\\conf\\nginx.conf

# Copy PHP script
COPY hello-world.php C:\\nginx\\html\\hello-world.php

# Expose port
EXPOSE 80

# Command to run nginx
CMD ["C:\\nginx\\nginx.exe"]
