FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables for PHP installation
ENV PHP_VERSION 8.4.1
ENV PHP_HOME C:\PHP

# Install IIS and necessary components
RUN powershell -Command \
    Install-WindowsFeature Web-Server, Web-ISAPI-Ext, Web-ISAPI-Filter; \
    # Install PHP from the official Windows PHP binaries
    Invoke-WebRequest -Uri https://windows.php.net/downloads/releases/php-${env:PHP_VERSION}-Win32-vs17-x64.zip -OutFile C:\php.zip; \
    Expand-Archive C:\php.zip -DestinationPath C:\ -Force; \
    Rename-Item -Path C:\php-${env:PHP_VERSION}-Win32-vs17-x64 -NewName PHP; \
    # Ensure registry path exists for FastCGI configuration
    if (-not (Test-Path "HKLM:\Software\Microsoft\InetStp\Handlers")) { \
        New-Item -Path "HKLM:\Software\Microsoft\InetStp" -Name "Handlers"; \
    }; \
    New-ItemProperty -Path "HKLM:\Software\Microsoft\InetStp\Handlers" -Name ".php" -Value "FastCgiModule" -PropertyType String; \
    # Clean up
    Remove-Item -Force C:\php.zip

# Expose port 80 for IIS
EXPOSE 80

# Set up a simple PHP "Hello World" file
RUN powershell -Command \
    New-Item -Path C:\inetpub\wwwroot -ItemType Directory -Force; \
    echo "<?php echo 'Hello, World!'; ?>" > C:\inetpub\wwwroot\index.php

# Set the default entrypoint to start IIS
CMD ["powershell", "-Command", "Start-Service w3svc; Wait-Event -Timeout 86400"]
