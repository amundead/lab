<?php
// Get the hostname and IP address of the node
$hostname = gethostname();
$nodeIP = $_SERVER['SERVER_ADDR'];
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
