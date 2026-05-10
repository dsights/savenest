<?php
// Mock server variables
$_SERVER['REQUEST_URI'] = '/blog/is-your-nbn-plan-too-fast-the-speed-trap';

// Copy-paste logic from web/index.php (simplified for testing)
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);
$path = trim($path, '/');

$blogFile = 'assets/data/blog_posts.json';
$productFile = 'assets/data/products.json';

echo "Testing Path: " . $path . "\n";
echo "Checking file: " . $blogFile . " - Exists: " . (file_exists($blogFile) ? 'Yes' : 'No') . "\n";

if (file_exists($blogFile)) {
    $content = file_get_contents($blogFile);
    $blogs = json_decode($content, true);
    if ($blogs) {
        echo "Blog JSON decoded. Count: " . count($blogs) . "\n";
        foreach ($blogs as $post) {
            $slug = 'blog/' . $post['slug'];
            if ($slug === $path) {
                echo "MATCH FOUND!\n";
                echo "Title: " . $post['title'] . "\n";
                echo "Image: " . $post['imageUrl'] . "\n";
                exit(0);
            }
        }
        echo "No match found for slug.\n";
    } else {
        echo "Failed to decode Blog JSON. Error: " . json_last_error_msg() . "\n";
    }
} else {
    echo "Blog file not found.\n";
}
?>
