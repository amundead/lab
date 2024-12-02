# Dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install tools, download, and set up Nginx (Windows binary)
RUN powershell -Command \
    "Invoke-WebRequest -Uri 'https://nginx.org/download/nginx-1.27.3.zip' -OutFile C:\\nginx.zip; \
    Expand-Archive -Path C:\\nginx.zip -DestinationPath C:\\; \
    Remove-Item -Force C:\\nginx.zip; \
    Rename-Item -Path 'C:\\nginx-1.27.3' -NewName 'C:\\nginx'; \
    if (-not (Test-Path -Path 'C:\\nginx\\logs')) { New-Item -Path 'C:\\nginx\\logs' -ItemType Directory }"

# Install tools, download, and set up PHP
RUN powershell -Command \
    "Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.4.1-Win32-vs17-x64.zip' -OutFile C:\\php.zip; \
    Expand-Archive -Path C:\\php.zip -DestinationPath C:\\php; \
    Remove-Item -Force C:\\php.zip"

# Set up environment variables for PHP
ENV PATH="C:\\php;${PATH}"

# Copy nginx.conf
COPY nginx.conf C:\\nginx\\conf\\nginx.conf

# Copy PHP script
COPY index.php C:\\nginx\\html\\index.php

# Expose port 80
EXPOSE 80

# Command to start Nginx
CMD ["C:\\nginx\\nginx.exe", "-c", "C:\\nginx\\conf\\nginx.conf"]
