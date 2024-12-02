# Use Windows Server Core LTSC2019 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables
ENV PHP_VERSION=8.4.1 \
    PHP_DOWNLOAD_URL=https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip \
    PHP_DIR="C:\\php"

# Install IIS (via dism.exe)
RUN dism.exe /online /enable-feature /featurename:IIS-WebServerRole /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-WebServerManagementTools /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-CommonHttpFeatures /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-StaticContent /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-WebServer /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-RequestFiltering /all /norestart

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri $Env:PHP_DOWNLOAD_URL -OutFile php.zip; \
    Expand-Archive -Path php.zip -DestinationPath $Env:PHP_DIR; \
    Remove-Item -Force php.zip

# Configure IIS to use PHP
RUN echo Set-ItemProperty 'IIS:\\Sites\\Default Web Site' -Name physicalPath -Value 'C:\\inetpub\\wwwroot' >> C:\\setup.ps1; \
    echo Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers' -name '.' -value @{name='PHP';path='*.php';verb='*';modules='FastCgiModule';scriptProcessor='%PHP_DIR%\\php-cgi.exe';resourceType='Unspecified'} >> C:\\setup.ps1; \
    powershell -ExecutionPolicy Bypass -File C:\\setup.ps1; \
    Remove-Item C:\\setup.ps1

# Add MIME type for PHP files
RUN appcmd set config /section:staticContent /+[fileExtension='.php',mimeType='application/x-httpd-php']


# Copy the index.php file into the IIS folder
COPY index.php C:\\inetpub\\wwwroot\\index.php

# Expose port 80 for IIS
EXPOSE 80

# Set IIS as the entry point
ENTRYPOINT ["cmd", "/S", "/C", "start w3svc && ping 127.0.0.1 -t"]