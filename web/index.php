<?php
// Default Metadata
$metaTitle = "Energy Comparison Australia | Save on Plans with SaveNest";
$metaDescription = "Compare energy, internet, and insurance in Australia. Find the best deals and save up to $500 with SaveNest's free comparison tool. Instant quotes online.";
$metaImage = "https://savenest.au/assets/assets/images/hero_energy.jpg";
$metaUrl = "https://savenest.au/";
$metaType = "website";

// Get current path
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);
$path = trim($path, '/');

// Data Files - Flutter Web puts assets in assets/assets/
$blogFile = __DIR__ . '/assets/assets/data/blog_posts.json';
if (!file_exists($blogFile)) {
    $blogFile = __DIR__ . '/../assets/assets/data/blog_posts.json';
}

$productFile = __DIR__ . '/assets/assets/data/products.json';
if (!file_exists($productFile)) {
    $productFile = __DIR__ . '/../assets/assets/data/products.json';
}

// Helper to resolve image URL
function resolveImageUrl($img) {
    if (empty($img)) return "https://savenest.au/assets/assets/images/hero_energy.jpg";
    if (strpos($img, 'http') === 0) return $img;
    
    $cleanPath = ltrim($img, '/');
    // Remove 'assets/' if it's already there to prevent triple assets/
    if (strpos($cleanPath, 'assets/') === 0) {
        $cleanPath = substr($cleanPath, 7);
    }
    return "https://savenest.au/assets/assets/" . $cleanPath;
}

// 1. Blog Post Detection
if (preg_match('/^blog\/([^\/]+)$/', $path, $matches)) {
    $slug = $matches[1];
    if (file_exists($blogFile)) {
        $blogs = json_decode(file_get_contents($blogFile), true);
        if ($blogs) {
            foreach ($blogs as $post) {
                if ($post['slug'] === $slug) {
                    $metaTitle = $post['title'] . " | SaveNest Blog";
                    $metaDescription = $post['summary'];
                    $metaImage = resolveImageUrl($post['imageUrl']);
                    $metaUrl = "https://savenest.au/blog/" . $slug;
                    $metaType = "article";
                    break;
                }
            }
        }
    }
}

// 2. State Guide Detection
elseif (preg_match('/^guides\/([^\/]+)\/([^\/]+)$/', $path, $matches)) {
    $state = strtoupper($matches[1]);
    $utility = ucfirst($matches[2]);
    $metaTitle = "Best $utility Plans in $state | 2026 Guide | SaveNest";
    $metaDescription = "Compare the cheapest $utility providers in $state. Read our expert guide to tariffs and rebates.";
    $metaUrl = "https://savenest.au/" . $path;
    
    if (strtolower($utility) == 'electricity') $metaImage = "https://savenest.au/assets/assets/images/hero_energy.jpg";
    elseif (strtolower($utility) == 'gas') $metaImage = "https://savenest.au/assets/assets/images/energy.png";
    elseif (strtolower($utility) == 'internet') $metaImage = "https://savenest.au/assets/assets/images/hero_internet.jpg";
}

// 3. Deal Detail Detection
elseif (preg_match('/^deal\/([^\/]+)$/', $path, $matches)) {
    $dealId = $matches[1];
    if (file_exists($productFile)) {
        $products = json_decode(file_get_contents($productFile), true);
        if ($products) {
            foreach ($products as $category => $deals) {
                if (is_array($deals)) {
                    foreach ($deals as $deal) {
                        if (isset($deal['id']) && $deal['id'] === $dealId) {
                            $metaTitle = $deal['providerName'] . " - " . $deal['planName'] . " | SaveNest";
                            $metaDescription = $deal['description'];
                            $metaImage = resolveImageUrl($deal['logoUrl']);
                            $metaUrl = "https://savenest.au/deal/" . $dealId;
                            $metaType = "product";
                            break 2;
                        }
                    }
                }
            }
        }
    }
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
  <link rel="canonical" href="<?php echo $metaUrl; ?>">

  <!-- Open Graph / Facebook -->
  <meta property="og:site_name" content="SaveNest Australia">
  <meta property="og:locale" content="en_AU">
  <meta property="og:type" content="<?php echo $metaType; ?>">
  <meta property="og:url" content="<?php echo $metaUrl; ?>">
  <meta property="og:title" content="<?php echo $metaTitle; ?>">
  <meta property="og:description" content="<?php echo $metaDescription; ?>">
  <meta property="og:image" content="<?php echo $metaImage; ?>">
  <meta property="og:image:secure_url" content="<?php echo $metaImage; ?>">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">

  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="<?php echo $metaUrl; ?>">
  <meta property="twitter:title" content="<?php echo $metaTitle; ?>">
  <meta property="twitter:description" content="<?php echo $metaDescription; ?>">
  <meta property="twitter:image" content="<?php echo $metaImage; ?>">

  <!-- Google Search Console Verification - Replace with your real code from GSC -->
  <meta name="google-site-verification" content="NABVIt55C39H9pCJOKcTbaa50I5IQLdbuJ7Yj9RxTes" />

  <!-- Pre-render Debug: Served via index.php -->
  <!-- Route: <?php echo $path; ?> -->
  <!-- Image: <?php echo $metaImage; ?> -->

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="savenest">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/jpeg" href="favicon.jpg"/>

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