# Use Windows Server Core image with IIS
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Remove default IIS website content
RUN powershell -NoProfile -Command "Remove-Item -Recurse -Force C:\inetpub\wwwroot\*"

# Set working directory to IIS wwwroot
WORKDIR /inetpub/wwwroot

# Download PHP zip
ADD https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip C:\php.zip

# Extract PHP zip using tar.exe and clean up
RUN tar -xf C:\php.zip -C C:\ && del C:\php.zip

# Add PHP to the system PATH
RUN setx PATH "%PATH%;C:\php"

# Configure IIS to use PHP with FastCGI
RUN powershell -NoProfile -Command `
    Import-Module WebAdministration; `
    New-WebHandler -Name "PHP_via_FastCGI" -Path "*.php" `
    -Verb "GET,HEAD,POST" -ScriptProcessor "C:\php\php-cgi.exe" -ResourceType "File"; `
    Add-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/fastCgi" `
    -name "." -value @{fullPath="C:\php\php-cgi.exe"}

# Copy index.php to the IIS wwwroot folder
COPY index.php .

# Expose port 80 for the web server
EXPOSE 80

# Start IIS service when the container runs
CMD ["powershell", "-NoProfile", "-Command", "Start-Service w3svc; while ($true) { Start-Sleep -Seconds 3600; }"]
