# Use Windows Server Core image with IIS
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Remove default IIS website content
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

# Set working directory to IIS wwwroot
WORKDIR /inetpub/wwwroot

# Download and install PHP
ADD https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip php.zip
RUN powershell -NoProfile -Command `
    Expand-Archive -Path php.zip -DestinationPath C:\php; `
    Remove-Item -Force php.zip; `
    [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\php', [System.EnvironmentVariableTarget]::Machine)

# Configure PHP with IIS
RUN powershell -NoProfile -Command `
    Import-Module WebAdministration; `
    Set-WebConfigurationProperty -filter "system.webServer/handlers" -name "." -value `
    @{Name="PHP_via_FastCGI"; Path="*.php"; Verb="GET,HEAD,POST"; ScriptProcessor="C:\php\php-cgi.exe"; ResourceType="File"}; `
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi" -name "." -value `
    @{fullPath="C:\php\php-cgi.exe"}

# Copy index.php to the IIS wwwroot folder
COPY index.php .

# Expose port 80 for the web server
EXPOSE 80

# Start IIS
CMD ["powershell", "-NoProfile", "-Command", "Start-Service w3svc; while ($true) { Start-Sleep -Seconds 3600; }"]
