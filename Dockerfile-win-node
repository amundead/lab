# Use the official Windows Server Core image as the base
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variable for Node.js version and download URL
ENV NODE_VERSION v22.11.0
ENV NODE_DIST_URL https://nodejs.org/dist/v22.11.0/node-v22.11.0-win-x64.zip
ENV NODE_HOME C:/nodejs

# Install Node.js by downloading and extracting the zip file
RUN powershell -Command \
    Invoke-WebRequest -Uri $env:NODE_DIST_URL -OutFile nodejs.zip; \
    Expand-Archive -Path nodejs.zip -DestinationPath $env:NODE_HOME; \
    Remove-Item nodejs.zip; \
    $env:Path = "$env:Path;$env:NODE_HOME"; \
    [System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Set the working directory in the container
WORKDIR /app

# Copy the index.html from the host machine to the container's working directory
COPY index.html /app/index.html

# Expose port 80
EXPOSE 80

# Start a simple HTTP server to serve the index.html file using PowerShell
CMD powershell -Command \
    $server = New-Object System.Net.HttpListener; \
    $server.Prefixes.Add('http://+:80/'); \
    $server.Start(); \
    while ($true) { \
        $context = $server.GetContext(); \
        $response = $context.Response; \
        $response.ContentType = 'text/html'; \
        $response.StatusCode = 200; \
        $response.ContentEncoding = [System.Text.Encoding]::UTF8; \
        $indexFile = 'C:/app/index.html'; \
        $response.OutputStream.Write([System.IO.File]::ReadAllBytes($indexFile), 0, [System.IO.File]::ReadAllBytes($indexFile).Length); \
        $response.OutputStream.Close(); \
    }
