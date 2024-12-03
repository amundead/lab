FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Install PHP and VC++ Redistributable
RUN powershell -Command \
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip' -OutFile 'C:\\php.zip'; \
    Expand-Archive -Path 'C:\\php.zip' -DestinationPath 'C:\\php'; \
    Remove-Item -Force 'C:\\php.zip'; \
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile 'C:\\vc_redist.x64.exe'; \
    Start-Process -FilePath 'C:\\vc_redist.x64.exe' -ArgumentList '/install', '/quiet', '/norestart' -Wait; \
    Remove-Item -Force 'C:\\vc_redist.x64.exe'; \
    [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\\php', [System.EnvironmentVariableTarget]::Machine); \
    [System.Environment]::SetEnvironmentVariable('PHP', 'C:\\php', [System.EnvironmentVariableTarget]::Machine)"

# Enable IIS Features
RUN dism.exe /online /enable-feature /all /featureName:IIS-WebServer /NoRestart && \
    dism.exe /online /enable-feature /all /featureName:IIS-CGI /NoRestart

# Configure FastCGI and PHP Handler
RUN powershell -Command \
    "Import-Module WebAdministration; \
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi' -name '.' -value @{fullPath='C:\\PHP\\php-cgi.exe'}; \
    New-WebHandler -Name 'PHP_via_FastCGI' -Path '*.php' -Verb '*' -Modules 'FastCgiModule' -ScriptProcessor 'C:\\PHP\\php-cgi.exe' -ResourceType 'Either'; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi/application[@fullPath=''C:\\PHP\\php-cgi.exe'']/environmentVariables' -name '.' -value @{name='PHP_FCGI_MAX_REQUESTS';value='10000'}; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi/application[@fullPath=''C:\\PHP\\php-cgi.exe'']/environmentVariables' -name '.' -value @{name='PHPRC';value='C:\\PHP'}; \
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/defaultDocument/files' -name '.' -value @{value='index.php'}"

# Optional: Add Starter PHP Page
RUN powershell -Command "echo '<?php phpinfo(); ?>' > C:\\inetpub\\wwwroot\\index.php"

# Expose Port 80
EXPOSE 80
