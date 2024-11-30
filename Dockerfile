# Use the Windows Server Core 2019 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install IIS and CGI
RUN dism.exe /online /enable-feature /all /featurename:IIS-WebServer /NoRestart && \
    dism.exe /online /enable-feature /all /featurename:IIS-CGI /NoRestart

# Install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-8.4.1-Win32-vs17-x64.zip" -OutFile "php.zip"; \
    Expand-Archive -Path php.zip -DestinationPath C:\php; \
    Remove-Item -Force php.zip

# Set PHP path for current session and globally
RUN setx /M PATH "%PATH%;C:\php" && \
    powershell -Command $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)

# Configure IIS FastCGI and handlers
RUN powershell -Command \
    Import-Module WebAdministration; \
    if (-Not (Get-WebConfiguration -filter 'system.webServer/fastCgi/application' -name '.' -value @{fullPath='C:\php\php-cgi.exe'})) { \
        Add-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi/application' -value @{fullPath='C:\php\php-cgi.exe'; instanceMaxRequests=200; activityTimeout=600; requestTimeout=600}; \
    }; \
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers' -name '.' -value @{name='PHP_via_FastCGI'; path='*.php'; verb='*'; modules='FastCgiModule'; scriptProcessor='C:\php\php-cgi.exe'; resourceType='Either'}

# Ensure PHP directory and executable have correct permissions
RUN icacls "C:\php" /grant "IIS_IUSRS:(OI)(CI)RX" /T

# Enable PHP logging
RUN powershell -Command \
    New-Item -ItemType Directory -Path C:\php\logs -Force; \
    "[System.IO.File]::WriteAllText('C:\\php\\logs\\php.log', '')"; \
    (Get-Content 'C:\php\php.ini') -replace ';error_log = syslog', 'error_log = C:\\php\\logs\\php.log' | Set-Content 'C:\php\php.ini'

# Add Hello World PHP script
RUN powershell -Command \
    "[System.IO.File]::WriteAllText('C:\\inetpub\\wwwroot\\index.php', '<?php phpinfo(); ?>')"

# Enable detailed IIS errors
RUN powershell -Command \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/httpErrors' -name 'errorMode' -value 'Detailed'

# Expose port 80
EXPOSE 80

# Start IIS
CMD ["powershell", "-Command", "Start-Service W3SVC; while ($true) { Start-Sleep -Seconds 3600; }"]
