# Use the Windows LTSC 2019 image
FROM mcr.microsoft.com/windows:ltsc2019

# Define environment variables for PHP installation
ENV PHP_URL=https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip
ENV PHP_ZIP=php-8.4.1-nts-Win32-vs17-x64.zip
ENV PHP_DIR=C:\php

# Install IIS and necessary features
RUN powershell -Command \
    Install-WindowsFeature -name Web-Server -IncludeManagementTools; \
    Install-WindowsFeature -name Web-Scripting-Tools; \
    Install-WindowsFeature -name Web-Dyn-Compression;

# Download and extract PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri %PHP_URL% -OutFile %PHP_ZIP%; \
    Expand-Archive -Path %PHP_ZIP% -DestinationPath %PHP_DIR%; \
    Remove-Item -Path %PHP_ZIP%

# Configure IIS to use PHP
RUN powershell -Command \
    Import-Module WebAdministration; \
    Set-ItemProperty -Path "IIS:\Sites\Default Web Site" -Name bindings -Value @{protocol="http"; bindingInformation=":80:"}; \
    Set-ItemProperty -Path "IIS:\Sites\Default Web Site" -Name physicalPath -Value "C:\inetpub\wwwroot"; \
    New-WebHandler -Name "PHP_via_FastCGI" -Path "*.php" -Verb "*" -Modules "FastCgiModule" -ScriptProcessor "%PHP_DIR%\php-cgi.exe";

# Copy index.php to IIS root folder
COPY index.php C:/inetpub/wwwroot/

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start IIS
CMD ["cmd", "/c", "iisreset", "/start", "&&", "ping", "-t", "localhost"]
