FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Download and install PHP and VC++ Redistributable
RUN powershell -Command "Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip' -OutFile 'C:\\php.zip';" ; \
    powershell -Command "Expand-Archive -Path 'C:\\php.zip' -DestinationPath 'C:\\php';" ; \
    powershell -Command "Remove-Item -Force 'C:\\php.zip';" ; \
    powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile 'C:\\vc_redist.x64.exe';" ; \
    powershell -Command "Start-Process -FilePath 'C:\\vc_redist.x64.exe' -ArgumentList '/install', '/quiet', '/norestart' -Wait;" ; \
    powershell -Command "Remove-Item -Force 'C:\\vc_redist.x64.exe';" ; \
    powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', \$env:PATH + ';C:\\php', [System.EnvironmentVariableTarget]::Machine)"

# Enable IIS CGI feature
RUN dism.exe /online /enable-feature /all /featureName:IIS-CGI

# Configure IIS for PHP
RUN powershell -Command "Import-Module IISAdministration;" ; \
    powershell -Command "New-IISHandlerMapping -Name 'PHP' -Path '*.php' -Verb '*' -ScriptProcessor 'C:\\php\\php-cgi.exe' -ResourceType File -PreCondition 'bitness64';" ; \
    powershell -Command "Set-ItemProperty -Path 'IIS:\\AppPools\\DefaultAppPool' -Name 'Enable32BitAppOnWin64' -Value 'False'"

# Optional: Add a starter PHP page
RUN powershell -Command "'<?php phpinfo(); ?>' | Out-File C:\\inetpub\\wwwroot\\index.php -Encoding UTF8"

# Expose port 80 for the application
EXPOSE 80

# Set the working directory to the default IIS website directory
WORKDIR C:\\inetpub\\wwwroot
