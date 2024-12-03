# Use the Windows Server Core IIS base image
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Download and install PHP and VC++ Redistributable
RUN powershell -Command \
    Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip' -OutFile 'C:\\php.zip'; \
    Expand-Archive -Path 'C:\\php.zip' -DestinationPath 'C:\\php'; \
    Remove-Item -Force 'C:\\php.zip'; \
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile 'C:\\vc_redist.x64.exe'; \
    Start-Process -FilePath 'C:\\vc_redist.x64.exe' -ArgumentList '/install', '/quiet', '/norestart' -Wait; \
    Remove-Item -Force 'C:\\vc_redist.x64.exe'; \
    [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\\php', [System.EnvironmentVariableTarget]::Machine)


# Enable IIS CGI feature and configure IIS for PHP
RUN dism.exe /Online /Enable-Feature /FeatureName:IIS-CGI /All && 
    C:\vc_redist-x64.exe /quiet /install && 
    del C:\vc_redist-x64.exe && 
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'] && 
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/handlers /+[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='C:\PHP\php-cgi.exe',resourceType='Either'] && 
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /[fullPath='C:\PHP\php-cgi.exe'].instanceMaxRequests:10000 && 
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'].environmentVariables.[name='PHP_FCGI_MAX_REQUESTS',value='10000'] && 
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'].environmentVariables.[name='PHPRC',value='C:\PHP'] && 
    %windir%\system32\inetsrv\appcmd.exe set config /section:defaultDocument /enabled:true /+files.[value='index.php'] && 
    setx PATH /M "%PATH%;C:\PHP" && 
    setx PHP /M "C:\PHP" && 
    del C:\inetpub\wwwroot\* /Q

# Optional: Add a starter PHP page
COPY index.php C:\\inetpub\\wwwroot\\

# Expose port 80 for the application
EXPOSE 80

# Set the working directory to the default IIS website directory
WORKDIR C:\\inetpub\\wwwroot