<?php
// proxy_upload.php
// Handles file uploads to HubSpot via server-side proxy to avoid CORS issues.

// Allow CORS from specific origin
$allowed_origin = getenv('ALLOWED_ORIGIN') ?: '*';
header("Access-Control-Allow-Origin: $allowed_origin");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
    exit();
}

// 1. Get the HubSpot Access Token
$HUB_TOKEN = getenv('HUBSPOT_ACCESS_TOKEN');

// If the environment variable is not found, check for the placeholder which is meant
// to be replaced by a deployment script. This is a fallback for environments
// that don't easily support environment variables.
if (!$HUB_TOKEN) {
    // This string should be replaced by a `sed` command in `deploy.yml`.
    $token_placeholder = 'REPLACE_WITH_HUBSPOT_ACCESS_TOKEN';
    if ($token_placeholder !== 'REPLACE_WITH_HUBSPOT_ACCESS_TOKEN') {
        $HUB_TOKEN = $token_placeholder;
    }
}

// Final check for the token
if (!$HUB_TOKEN || $HUB_TOKEN === 'REPLACE_WITH_HUBSPOT_ACCESS_TOKEN') {
    http_response_code(500);
    // Provide a clear error message in JSON format.
    echo json_encode([
        "error" => "HubSpot Access Token is not configured on the server.",
        "message" => "The HubSpot access token is missing. Please ensure the HUBSPOT_ACCESS_TOKEN environment variable is set or the placeholder is replaced during deployment."
    ]);
    exit();
}

$uploadUrl = "https://api.hubapi.com/files/v3/files";

// 2. Validate File
if (!isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(["error" => "No file provided"]);
    exit();
}

$file = $_FILES['file'];

// Check for upload errors
if ($file['error'] !== UPLOAD_ERR_OK) {
     http_response_code(400);
     echo json_encode(["error" => "File upload error code: " . $file['error']]);
     exit();
}

// 3. Prepare Forward Request
$cfile = new CURLFile($file['tmp_name'], $file['type'], $file['name']);

$postFields = [
    'file' => $cfile,
    'folderPath' => 'savenest_bills',
    'options' => json_encode(["access" => "PUBLIC_INDEXABLE"])
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $uploadUrl);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . $HUB_TOKEN
]);

// 4. Execute
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    $error_msg = curl_error($ch);
    http_response_code(500);
    echo json_encode(["error" => "Curl error: " . $error_msg]);
} else {
    // Pass through HubSpot's response, whether it's an error or success.
    http_response_code($httpCode);
    header('Content-Type: application/json');
    echo $response;
}

curl_close($ch);
?>
