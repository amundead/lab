# Base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install IIS and Management Tools
RUN powershell -Command \
    Install-WindowsFeature -Name Web-Server, Web-Asp-Net45, Web-Static-Content, Web-Scripting-Tools; \
    Install-WindowsFeature -Name Web-CGI

# Download and Install PHP
ADD https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip /php.zip
RUN powershell -Command \
    Expand-Archive -Path /php.zip -DestinationPath C:\php; \
    Remove-Item -Force /php.zip; \
    [Environment]::SetEnvironmentVariable('Path', $Env:Path + ';C:\php', [EnvironmentVariableTarget]::Machine)

# Configure IIS to use PHP with FastCGI
RUN powershell -Command \
    Import-Module WebAdministration; \
    New-WebAppPool -Name PHPAppPool; \
    Set-ItemProperty 'IIS:\AppPools\PHPAppPool' -Name enable32BitAppOnWin64 -Value True; \
    Add-Website -Name "Default Web Site" -PhysicalPath 'C:\inetpub\wwwroot' -ApplicationPool PHPAppPool -Force; \
    & C:\windows\system32\inetsrv\appcmd.exe set config /section:handlers /+[name='PHP',path='*',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='C:\php\php-cgi.exe',resourceType='Unspecified']; \
    & C:\windows\system32\inetsrv\appcmd.exe set config /section:fastCgi /+[fullPath='C:\php\php-cgi.exe',arguments='']

# Expose port 80
EXPOSE 80

# Copy index.php to IIS root
COPY index.php C:/inetpub/wwwroot/index.php
