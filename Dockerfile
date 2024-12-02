# Use Windows Server Core image with IIS pre-installed
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Remove the default IIS website content
RUN powershell -NoProfile -Command "Remove-Item -Recurse -Force C:\inetpub\wwwroot\*"

# Set working directory to IIS wwwroot
WORKDIR C:/inetpub/wwwroot

# Download PHP zip
ADD https://windows.php.net/downloads/releases/php-8.4.1-nts-Win32-vs17-x64.zip C:/php.zip

# Install Visual C++ Redistributable (VC Redist)
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "C:/vc_redist.x64.exe" ; \
    Start-Process -Wait -FilePath "C:/vc_redist.x64.exe" -ArgumentList "/quiet" ; \
    Remove-Item -Force "C:/vc_redist.x64.exe"

# Enable required IIS Features
RUN dism.exe /Online /Enable-Feature /FeatureName:IIS-CGI /All

# Configure IIS to serve PHP files
RUN powershell -Command \
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS\Parameters' -Name 'CGI' -Value 1 -PropertyType DWord -Force ; \
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS\Parameters' -Name 'CgiWithScriptMaps' -Value 1 -PropertyType DWord -Force ; \
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS\Parameters' -Name 'EnableScripting' -Value 1

# Add PHP to the system PATH
RUN setx PATH "%PATH%;C:\php;C:\php\ext"

# Copy PHP files into IIS root
COPY index.php C:/inetpub/wwwroot/index.php

# Expose IIS port
EXPOSE 80

# Start IIS
CMD ["powershell", "-NoProfile", "-Command", "Start-Service w3svc; Wait-Process w3wp"]
