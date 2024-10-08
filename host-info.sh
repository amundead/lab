#!/bin/sh

# Get the hostname and IP address
HOSTNAME=$(hostname)
IP=$(hostname -i)

# Output the HTTP headers and the JSON response
echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n"
echo -e "{\"hostname\": \"${HOSTNAME}\", \"ip\": \"${IP}\"}"
