<?php
// Default Metadata
$metaTitle = "Compare Energy Plans Australia 2026 | SaveNest – Save \$500+";
$metaDescription = "Compare electricity, gas, internet, and insurance plans in Australia. Find the best deals, understand the 2026 Solar Sharer Offer, and stop paying the loyalty tax with SaveNest.";
$metaImage = "https://savenest.au/assets/assets/images/hero_energy.jpg";
$metaUrl = "https://savenest.au/";
$metaType = "website";

// Get current path
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);
$path = trim($path, '/'); // Remove leading/trailing slashes

// Caching Mechanism
$cacheFile = 'meta_cache.php';
$blogFile = 'assets/data/blog_posts.json';
$productFile = 'assets/data/products.json';

function buildCache($cacheFile, $blogFile, $productFile) {
    $data = [];

    // Process Blog Posts
    if (file_exists($blogFile)) {
        $blogs = json_decode(file_get_contents($blogFile), true);
        if ($blogs) {
            foreach ($blogs as $post) {
                $slug = 'blog/' . $post['slug'];
                $img = $post['imageUrl'];
                if (strpos($img, 'http') !== 0) {
                    $img = "https://savenest.au/assets/" . ltrim($img, '/');
                }
                $data[$slug] = [
                    'title' => $post['title'] . " | SaveNest Blog",
                    'description' => $post['summary'],
                    'image' => $img,
                    'type' => 'article'
                ];
            }
        }
    }

    // Process Products
    if (file_exists($productFile)) {
        $products = json_decode(file_get_contents($productFile), true);
        if ($products) {
            foreach ($products as $category => $deals) {
                if (is_array($deals)) {
                    foreach ($deals as $deal) {
                        if (isset($deal['id'])) {
                            $slug = 'deal/' . $deal['id'];
                            $img = $deal['logoUrl'];
                            if (strpos($img, 'http') !== 0) {
                                $img = "https://savenest.au/assets/" . ltrim($img, '/');
                            }
                            $data[$slug] = [
                                'title' => $deal['providerName'] . " - " . $deal['planName'] . " Review | SaveNest",
                                'description' => $deal['description'],
                                'image' => $img,
                                'type' => 'product'
                            ];
                        }
                    }
                }
            }
        }
    }

    // Save Cache
    file_put_contents($cacheFile, "<?php\nreturn " . var_export($data, true) . ";\n");
    return $data;
}

// Check if cache needs rebuilding
$cacheNeedsRebuild = !file_exists($cacheFile);
if (!$cacheNeedsRebuild) {
    $cacheTime = filemtime($cacheFile);
    if (file_exists($blogFile) && filemtime($blogFile) > $cacheTime) $cacheNeedsRebuild = true;
    if (file_exists($productFile) && filemtime($productFile) > $cacheTime) $cacheNeedsRebuild = true;
}

if ($cacheNeedsRebuild) {
    $metaDataMap = buildCache($cacheFile, $blogFile, $productFile);
} else {
    $metaDataMap = include $cacheFile;
}

// Lookup Metadata
if (isset($metaDataMap[$path])) {
    $data = $metaDataMap[$path];
    $metaTitle = $data['title'];
    $metaDescription = $data['description'];
    $metaImage = $data['image'];
    $metaType = $data['type'];
    $metaUrl = "https://savenest.au/" . $path;
}

// Escape for HTML
$metaTitle = htmlspecialchars($metaTitle, ENT_QUOTES, 'UTF-8');
$metaDescription = htmlspecialchars($metaDescription, ENT_QUOTES, 'UTF-8');
$metaImage = htmlspecialchars($metaImage, ENT_QUOTES, 'UTF-8');
$metaUrl = htmlspecialchars($metaUrl, ENT_QUOTES, 'UTF-8');

?>
<!DOCTYPE html>
<html>
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- Primary Meta Tags -->
  <title><?php echo $metaTitle; ?></title>
  <meta name="description" content="<?php echo $metaDescription; ?>">
  <meta name="keywords" content="compare electricity Australia, utility comparison, save money energy, solar sharer offer 2026, cheap internet plans, home insurance comparison, savenest, cheapest electricity provider NSW 2026">
  <meta name="author" content="SaveNest Australia">

  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="<?php echo $metaType; ?>">
  <meta property="og:url" content="<?php echo $metaUrl; ?>">
  <meta property="og:title" content="<?php echo $metaTitle; ?>">
  <meta property="og:description" content="<?php echo $metaDescription; ?>">
  <meta property="og:image" content="<?php echo $metaImage; ?>">

  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="<?php echo $metaUrl; ?>">
  <meta property="twitter:title" content="<?php echo $metaTitle; ?>">
  <meta property="twitter:description" content="<?php echo $metaDescription; ?>">
  <meta property="twitter:image" content="<?php echo $metaImage; ?>">

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="savenest">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <link rel="manifest" href="manifest.json">

  <!-- Schema.org JSON-LD -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "SaveNest Australia",
    "url": "https://savenest.au",
    "logo": "https://savenest.au/assets/assets/images/logo.png",
    "description": "Compare utility services and save money on electricity, gas, internet, and insurance in Australia.",
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "Sydney",
      "addressRegion": "NSW",
      "addressCountry": "AU"
    },
    "contactPoint": {
      "@type": "ContactPoint",
      "contactType": "customer service",
      "areaServed": "AU",
      "availableLanguage": "English"
    }
  }
  </script>

  <!-- Global site tag (gtag.js) - Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-P1K9W1BY9P"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'G-P1K9W1BY9P');
  </script>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
