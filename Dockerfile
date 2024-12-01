# Base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install IIS and required components
RUN powershell -Command \
    Install-WindowsFeature -Name Web-Server, Web-CGI, Web-Static-Content, Web-Scripting-Tools

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip" -OutFile "C:\php.zip"; \
    Expand-Archive -Path C:\php.zip -DestinationPath C:\php; \
    Remove-Item -Force C:\php.zip; \
    [Environment]::SetEnvironmentVariable('Path', $Env:Path + ';C:\php', [EnvironmentVariableTarget]::Machine)

# Configure IIS to use PHP
RUN powershell -Command \
    "& { \
        C:\windows\system32\inetsrv\appcmd.exe add site /name:'Default Web Site' /bindings:http/*:80: /physicalPath:'C:\inetpub\wwwroot'; \
        C:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/handlers /+\"[name='PHP',path='*.php',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='C:\php\php-cgi.exe',resourceType='File']\"; \
        C:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/fastCgi /+[fullPath='C:\php\php-cgi.exe']; \
    }"

# Expose port 80
EXPOSE 80

# Copy PHP application to the IIS root
COPY index.php C:/inetpub/wwwroot/index.php
