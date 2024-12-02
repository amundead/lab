# Use Windows Server Core LTSC2019 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables
ENV PHP_VERSION=8.4.1 \
    PHP_DOWNLOAD_URL=https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip \
    PHP_DIR="C:\\php"

# Install IIS and CGI Module
RUN dism.exe /online /enable-feature /featurename:IIS-WebServerRole /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-WebServerManagementTools /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-CommonHttpFeatures /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-StaticContent /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-CGI /all /norestart

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri $Env:PHP_DOWNLOAD_URL -OutFile php.zip; \
    Expand-Archive -Path php.zip -DestinationPath $Env:PHP_DIR; \
    Remove-Item -Force php.zip

# Configure IIS to use PHP
RUN powershell -Command \
    Import-Module WebAdministration; \
    Set-ItemProperty IIS:\Sites\Default Web Site -Name physicalPath -Value C:\inetpub\wwwroot; \
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers' -name '.' -value @{name='PHP';path='*.php';verb='*';modules='FastCgiModule';scriptProcessor='C:\php\php-cgi.exe';resourceType='Unspecified'}

# Set permissions for IIS user
RUN icacls "C:\\php" /grant IIS_IUSRS:(OI)(CI)RX /T && \
    icacls "C:\\inetpub\\wwwroot" /grant IIS_IUSRS:(OI)(CI)RX /T

# Copy the index.php file into the IIS folder
COPY index.php C:\\inetpub\\wwwroot\\index.php

# Expose port 80 for IIS
EXPOSE 80

# Start IIS
ENTRYPOINT ["cmd", "/S", "/C", "start w3svc && ping 127.0.0.1 -t"]
