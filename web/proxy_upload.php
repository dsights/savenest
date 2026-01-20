<?php
// proxy_upload.php
// Handles file uploads to HubSpot via server-side proxy to avoid CORS issues.

// Allow CORS from any origin (or restrict to your domain)
header("Access-Control-Allow-Origin: *");
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
// We try to get it from environment, or use a placeholder that deployment script replaces.
$HUB_TOKEN = getenv('HUBSPOT_ACCESS_TOKEN');

// Fallback logic for shared hosting where getenv might not be populated from .env
if (!$HUB_TOKEN || $HUB_TOKEN === '') {
    // This string is a placeholder. The GitHub Action `deploy.yml` should replace it 
    // with the actual secret using `sed`.
    $HUB_TOKEN = 'REPLACE_WITH_HUBSPOT_ACCESS_TOKEN';
}

// If it's still the placeholder (local dev or misconfigured), try the header from the client?
// Note: Client likely sends an empty token if not configured there.
// But if the client sent a valid token in Authorization header, we could use it.
$authHeader = isset($_SERVER['HTTP_AUTHORIZATION']) ? $_SERVER['HTTP_AUTHORIZATION'] : '';
if (strpos($HUB_TOKEN, 'REPLACE_') === 0 && !empty($authHeader)) {
    // Extract token from "Bearer <token>"
    if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        $HUB_TOKEN = $matches[1];
    }
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
    http_response_code($httpCode);
    header('Content-Type: application/json');
    echo $response;
}

curl_close($ch);
?>
