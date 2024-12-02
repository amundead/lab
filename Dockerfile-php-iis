# Stage 1: Base Image for PHP Installation
FROM mcr.microsoft.com/windows/servercore/iis AS php82

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

RUN `
    try { `
        # Install PHP `
        Invoke-WebRequest 'https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip' -OutFile C:\php.zip; `
        Invoke-WebRequest 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile C:\vc_redist-x64.exe; `
        Expand-Archive -Path c:\php.zip -DestinationPath C:\PHP; `
    } `
    catch { `
        $_.Exception; `
        $_; `
        exit 1; `
    }

# Stage 2: Final Image with IIS and PHP Setup
FROM mcr.microsoft.com/windows/servercore/iis

# Copy PHP and VC Redist from the previous stage
COPY --from=php82 ["C:/PHP/", "C:/PHP/"]
COPY --from=php82 ["C:/vc_redist-x64.exe", "C:/vc_redist-x64.exe"]

# Enable IIS CGI feature and configure IIS for PHP
RUN dism.exe /Online /Enable-Feature /FeatureName:IIS-CGI /All && `
    C:\vc_redist-x64.exe /quiet /install && `
    del C:\vc_redist-x64.exe && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'] && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/handlers /+[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='C:\PHP\php-cgi.exe',resourceType='Either'] && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /[fullPath='C:\PHP\php-cgi.exe'].instanceMaxRequests:10000 && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'].environmentVariables.[name='PHP_FCGI_MAX_REQUESTS',value='10000'] && `
    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='C:\PHP\php-cgi.exe'].environmentVariables.[name='PHPRC',value='C:\PHP'] && `
    %windir%\system32\inetsrv\appcmd.exe set config /section:defaultDocument /enabled:true /+files.[value='index.php'] && `
    setx PATH /M "%PATH%;C:\PHP" && `
    setx PHP /M "C:\PHP" && `
    del C:\inetpub\wwwroot\* /Q

# Optional: Add a starter page
RUN powershell.exe -Command "'<?php phpinfo(); ?>' | Out-File C:\inetpub\wwwroot\index.php -Encoding UTF8"

# Expose port 80 for the application
EXPOSE 80
