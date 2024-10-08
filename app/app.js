const express = require('express');
const os = require('os');

const app = express();
const port = 80;

// Serve the static HTML file
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

// Endpoint to get host info
app.get('/host-info', (req, res) => {
  const hostname = os.hostname();
  const ip = getIPAddress();
  res.json({ hostname, ip });
});

// Helper function to get IP address
function getIPAddress() {
  const interfaces = os.networkInterfaces();
  for (const interfaceName in interfaces) {
    for (const net of interfaces[interfaceName]) {
      // Skip over non-IPv4 and internal (i.e., 127.0.0.1) addresses
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'IP not found';
}

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
