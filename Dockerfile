# Use the Windows Server Core 2019 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install IIS
RUN dism.exe /online /enable-feature /all /featurename:IIS-WebServer /NoRestart

# Install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-8.4.1-Win32-vs17-x64.zip" -OutFile "php.zip"; \
    Expand-Archive -Path php.zip -DestinationPath C:\php; \
    Remove-Item -Force php.zip

# Set PHP path for current session and globally
RUN setx /M PATH "%PATH%;C:\php" && \
    powershell -Command $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)

# Configure IIS to handle PHP
RUN powershell -Command \
    Import-Module WebAdministration; \
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers' -name '.' -value @{name='PHP_via_FastCGI'; path='*.php'; verb='*'; modules='FastCgiModule'; scriptProcessor='C:\php\php-cgi.exe'; resourceType='Either'}; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi' -name '.' -value @{fullPath='C:\php\php-cgi.exe'; maxInstances=10}; \
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/defaultDocument/files' -name '.' -value @{value='index.php'}

# Configure PHP
RUN powershell -Command \
    Copy-Item -Path "C:\\php\\php.ini-production" -Destination "C:\\php\\php.ini"; \
    $content = Get-Content "C:\\php\\php.ini"; \
    $content = $content -replace ';cgi.fix_pathinfo=1', 'cgi.fix_pathinfo=1'; \
    [System.IO.File]::WriteAllText('C:\\php\\php.ini', $content)

# Add Hello World PHP script
RUN powershell -Command \
    "[System.IO.File]::WriteAllText('C:\\inetpub\\wwwroot\\index.php', '<?php phpinfo(); ?>')"

# Enable detailed IIS errors
RUN powershell -Command \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/httpErrors' -name 'errorMode' -value 'Detailed'; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/asp' -name 'scriptErrorSentToBrowser' -value 'true'

# Expose port 80
EXPOSE 80

# Start IIS
CMD ["powershell", "-Command", "Start-Service W3SVC; while ($true) { Start-Sleep -Seconds 3600; }"]
