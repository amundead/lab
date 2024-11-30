# Use Windows Server Core as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables for PHP installation
ENV PHP_VERSION 8.4.1
ENV PHP_HOME C:\PHP

# Install IIS and necessary components
RUN powershell -Command \
    Install-WindowsFeature Web-Server, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Management-Tools, Web-Scripting-Tools; \
    # Install PHP from the official Windows PHP binaries
    Invoke-WebRequest -Uri https://windows.php.net/downloads/releases/php-${env:PHP_VERSION}-Win32-vs17-x64.zip -OutFile C:\php.zip; \
    Expand-Archive C:\php.zip -DestinationPath C:\ -Force; \
    # Rename extracted folder to "PHP"
    Rename-Item -Path C:\php-${env:PHP_VERSION}-Win32-vs17-x64 -NewName PHP; \
    # Configure IIS to use FastCGI for PHP (ensure IIS is fully set up)
    if (!(Test-Path "HKLM:\Software\Microsoft\InetStp")) { New-Item -Path "HKLM:\Software\Microsoft\InetStp" -Force; } \
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\InetStp" -Name "FastCgiModule" -Value "C:\PHP\php-cgi.exe"; \
    # Ensure Handlers registry key exists and configure PHP handling for .php files
    if (!(Test-Path "HKLM:\Software\Microsoft\InetStp\Handlers")) { New-Item -Path "HKLM:\Software\Microsoft\InetStp\Handlers" -Force; } \
    New-ItemProperty -Path "HKLM:\Software\Microsoft\InetStp\Handlers" -Name ".php" -Value "FastCgiModule" -PropertyType String -Force; \
    # Clean up PHP archive
    Remove-Item -Force C:\php.zip

# Expose port 80 for IIS
EXPOSE 80

# Set up a simple PHP "Hello World" file
RUN echo "<?php echo 'Hello, World!'; ?>" > C:\inetpub\wwwroot\index.php

# Set the default entrypoint to start IIS
CMD ["powershell", "-Command", "Start-Service w3svc; Wait-Event -Timeout 86400"]
