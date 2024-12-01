# Use Windows NanoServer LTSC2019 as the base image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2019

# Set environment variables
ENV PHP_VERSION=8.4.1 \
    PHP_DOWNLOAD_URL=https://windows.php.net/downloads/releases/php-8.4.1-Win32-vs17-x64.zip \
    PHP_DIR="C:\\php"

# Install IIS (via cmd, as PowerShell is not available in NanoServer)
RUN dism.exe /online /enable-feature /featurename:IIS-WebServerRole /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-WebServerManagementTools /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-CommonHttpFeatures /all /norestart && \
    dism.exe /online /enable-feature /featurename:IIS-StaticContent /all /norestart

# Download and install PHP
RUN powershell -Command \
    Invoke-WebRequest -Uri %PHP_DOWNLOAD_URL% -OutFile php.zip; \
    Expand-Archive -Path php.zip -DestinationPath %PHP_DIR%; \
    Remove-Item -Force php.zip

# Configure IIS to use PHP (this step assumes IIS is already installed)
RUN echo Set-ItemProperty 'IIS:\\Sites\\Default Web Site' -Name physicalPath -Value 'C:\\inetpub\\wwwroot' >> C:\\setup.ps1; \
    echo New-ItemProperty 'IIS:\\Sites\\Default Web Site' -Name scriptProcessor -Value '%PHP_DIR%\\php-cgi.exe' -PropertyType String >> C:\\setup.ps1; \
    echo New-WebHandler -PSPath 'IIS:\\' -Name 'PHP' -Type 'System.Web.DefaultHttpHandler' -Verb '*' -Path '*.php' -Modules 'FastCgiModule' -ScriptProcessor '%PHP_DIR%\\php-cgi.exe' >> C:\\setup.ps1; \
    powershell -ExecutionPolicy Bypass -File C:\\setup.ps1; \
    Remove-Item C:\\setup.ps1

# Expose port 80 for IIS
EXPOSE 80

# Set IIS as the entry point
ENTRYPOINT ["cmd", "/S", "/C", "start w3svc && ping 127.0.0.1 -t"]
