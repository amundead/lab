# Specify the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install IIS
RUN powershell -Command \
    Install-WindowsFeature -name Web-Server; \
    Install-WindowsFeature -name Web-Asp-Net45; \
    Install-WindowsFeature -name Web-Static-Content

# Install PHP
ADD https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip /php.zip
RUN powershell -Command \
    Expand-Archive -Path /php.zip -DestinationPath C:\php; \
    Remove-Item -Force /php.zip; \
    [Environment]::SetEnvironmentVariable('Path', $Env:Path + ';C:\php', [EnvironmentVariableTarget]::Machine)

# Configure IIS to use FastCGI with PHP
RUN powershell -Command \
    Import-Module WebAdministration; \
    New-WebAppPool -Name PHPAppPool; \
    Set-ItemProperty 'IIS:\AppPools\PHPAppPool' -Name enable32BitAppOnWin64 -Value True; \
    Add-WebSite -Name "Default Web Site" -PhysicalPath 'C:\inetpub\wwwroot' -Force; \
    Remove-WebHandler -Path "*" -Name "CGI-exe"; \
    Add-WebHandler -Path "*" -Name "PHP" -ModuleName "FastCgiModule" -Executable "C:\php\php-cgi.exe"; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/handlers/add[@name="PHP"]' -name 'resourceType' -value 'Unspecified'

# Expose port 80
EXPOSE 80

# Copy index.php to the IIS root
COPY index.php C:/inetpub/wwwroot/index.php
