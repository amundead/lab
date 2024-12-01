# Use Windows NanoServer LTSC2019 as the base image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2019

# Set environment variables
ENV PHP_VERSION=8.4.1 \
    PHP_DOWNLOAD_URL=https://windows.php.net/downloads/releases/php-8.4.1-Win32-vs17-x64.zip \
    PHP_DIR="C:\\php"

# Install IIS
RUN powershell -Command \
    Install-WindowsFeature -name Web-Server; \
    Install-WindowsFeature -name Web-Common-Http; \
    Install-WindowsFeature -name Web-WebServer

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri %PHP_DOWNLOAD_URL% -OutFile php.zip; \
    Expand-Archive -Path php.zip -DestinationPath %PHP_DIR%; \
    Remove-Item -Force php.zip

# Configure IIS to use PHP
RUN powershell -Command \
    Import-Module WebAdministration; \
    Set-ItemProperty 'IIS:\Sites\Default Web Site' -Name physicalPath -Value C:\inetpub\wwwroot; \
    New-ItemProperty 'IIS:\Sites\Default Web Site' -Name scriptProcessor -Value '%PHP_DIR%\php-cgi.exe' -PropertyType String; \
    New-Item -Type Directory -Path C:\inetpub\wwwroot\phpinfo; \
    New-WebHandler -PSPath 'IIS:\' -Name 'PHP' -Type 'System.Web.DefaultHttpHandler' -Verb '*' -Path '*.php' -Modules 'FastCgiModule' -ScriptProcessor '%PHP_DIR%\php-cgi.exe'

# Expose port 80 for IIS
EXPOSE 80

# Set IIS as the entry point
ENTRYPOINT ["powershell", "Start-Service", "w3svc", ";", "Wait-Event"]
