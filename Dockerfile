# Base Image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Define environment variables
ENV PHP_VERSION=8.4.1
ENV PHP_URL=https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip
ENV PHP_INSTALL_DIR=C:\php

# Download and install IIS
RUN powershell -Command \
    Add-WindowsFeature Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Http-Errors,Web-App-Dev,Web-Asp-Net45,Web-Net-Ext45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Performance,Web-Stat-Compression,Web-Security,Web-Filtering,Web-Mgmt-Console

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri %PHP_URL% -OutFile C:\php.zip; \
    Expand-Archive -Path C:\php.zip -DestinationPath %PHP_INSTALL_DIR%; \
    Remove-Item -Force C:\php.zip

# Configure IIS to use PHP via FastCGI
RUN powershell -NoProfile -Command `
    Import-Module WebAdministration; `
    # Create Application Pool
    New-WebAppPool -Name "PHPAppPool"; `
    # Create PHP directory in Default Web Site
    New-Item -Path "IIS:\Sites\Default Web Site\php" -Type Directory; `
    # Set Application Pool for Default Web Site
    Set-ItemProperty -Path "IIS:\Sites\Default Web Site" -Name applicationPool -Value "PHPAppPool"; `
    # Add FastCGI settings for PHP
    Add-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/fastCgi" -name "." -value @{ `
        fullPath="%PHP_INSTALL_DIR%\\php-cgi.exe"; `
        instanceMaxRequests=10000; `
        maxInstances=5 `
    }; `
    # Add handler mapping for PHP
    Add-WebConfiguration -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/handlers" -value @{ `
        name="php"; `
        path="*.php"; `
        verb="*"; `
        modules="FastCgiModule"; `
        scriptProcessor="%PHP_INSTALL_DIR%\\php-cgi.exe"; `
        resourceType="File" `
    }

# Copy the application file (index.php) to the IIS root directory
COPY index.php C:\inetpub\wwwroot\index.php

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start IIS service
CMD ["powershell", "Start-Service", "w3svc", ";", "tail", "-f", "/dev/null"]
