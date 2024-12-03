<?php
// Get the hostname
$hostname = gethostname();

// Try to get the server's IP address
$nodeIP = $_SERVER['SERVER_ADDR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'Unknown';

// Avoid passing null to htmlspecialchars
$nodeIP = is_null($nodeIP) ? 'Unknown' : $nodeIP;

// Get the PHP version
$phpVersion = phpversion();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello World</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f0f8ff; /* Light blue background */
      color: #333;
      padding: 20px;
    }
    h1 {
      font-size: 3em; /* Larger font size for the heading */
      color: #0000ff; /* Blue color */
    }
    p {
      font-size: 1.5em; /* Bigger font for paragraphs */
    }
    strong {
      color: #ff0000; /* Red color for the labels */
    }
  </style>
</head>
<body>
  <h1>PHP version (<?php echo htmlspecialchars($phpVersion); ?>)</h1>
  <p><strong>Hostname:</strong> <?php echo htmlspecialchars($hostname); ?></p>
  <p><strong>Node IP:</strong> <?php echo htmlspecialchars($nodeIP); ?></p>
</body>
</html>
