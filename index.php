<?php
// Get the hostname
$hostname = gethostname();

// Try to get the server's IP address
$nodeIP = $_SERVER['SERVER_ADDR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'Unknown';

// Avoid passing null to htmlspecialchars
$nodeIP = is_null($nodeIP) ? 'Unknown' : $nodeIP;
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello World</title>
</head>
<body>
  <h1>Hello World</h1>
  <p><strong>Hostname:</strong> <?php echo htmlspecialchars($hostname); ?></p>
  <p><strong>Node IP:</strong> <?php echo htmlspecialchars($nodeIP); ?></p>
</body>
</html>
