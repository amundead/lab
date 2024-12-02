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
RUN powershell -Command `
    Invoke-WebRequest -Uri $Env:PHP_DOWNLOAD_URL -OutFile php.zip; `
    Expand-Archive -Path php.zip -DestinationPath $Env:PHP_DIR; `
    Remove-Item -Force php.zip

# Configure IIS to use PHP
RUN powershell -Command `
    Import-Module WebAdministration; `
    Set-ItemProperty -Path "IIS:\Sites\Default Web Site" -Name physicalPath -Value "C:\\inetpub\\wwwroot"; `
    Add-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/fastCgi" -name "." -value @{ `
        fullPath="$Env:PHP_DIR\\php-cgi.exe"; `
        instanceMaxRequests=10000; `
        maxInstances=5 }; `
    Add-WebConfiguration -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/handlers" -value @{ `
        name="PHP"; `
        path="*.php"; `
        verb="*"; `
        modules="FastCgiModule"; `
        scriptProcessor="$Env:PHP_DIR\\php-cgi.exe"; `
        resourceType="File" }

# Add MIME type for PHP
RUN powershell -Command `
    Import-Module WebAdministration; `
    Add-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/staticContent" -name "." -value @{ `
        fileExtension=".php"; `
        mimeType="text/html" }

# Copy the index.php file into the IIS folder
COPY index.php C:\\inetpub\\wwwroot\\index.php

# Expose port 80 for IIS
EXPOSE 80

# Start IIS and keep the container running
ENTRYPOINT ["cmd", "/S", "/C", "start w3svc && ping 127.0.0.1 -t"]
