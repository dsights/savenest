<?php
// ============================================================
// SaveNest.au - SEO-Aware PHP Entry Point
// Serves dynamic meta tags + crawler-readable HTML for all pages
// ============================================================

// ─── Bot Detection ───────────────────────────────────────────
$userAgent = strtolower($_SERVER['HTTP_USER_AGENT'] ?? '');
$crawlerPatterns = ['googlebot', 'bingbot', 'slurp', 'duckduckbot', 'baiduspider', 'yandexbot', 'facebookexternalhit', 'twitterbot', 'linkedinbot', 'whatsapp', 'applebot', 'rogerbot', 'semrushbot', 'ahrefsbot', 'mj12bot'];
$isCrawler = false;
foreach ($crawlerPatterns as $bot) {
    if (strpos($userAgent, $bot) !== false) { $isCrawler = true; break; }
}

// ─── Default Metadata ────────────────────────────────────────
$metaTitle       = "Energy Comparison Australia | Save on Plans with SaveNest";
$metaDescription = "Compare energy, internet, and insurance in Australia. Find the best deals and save up to $500 with SaveNest's free comparison tool. Instant quotes online.";
$metaImage       = "https://savenest.au/assets/assets/images/hero_energy.jpg";
$metaUrl         = "https://savenest.au/";
$metaType        = "website";
$pageSchema      = '';
$crawlerHtml     = '';

// ─── URL Parsing ─────────────────────────────────────────────
$requestUri = $_SERVER['REQUEST_URI'];
$path       = trim(parse_url($requestUri, PHP_URL_PATH), '/');

// ─── Data Files ──────────────────────────────────────────────
$blogFile    = __DIR__ . '/assets/assets/data/blog_posts.json';
if (!file_exists($blogFile)) $blogFile = __DIR__ . '/../assets/assets/data/blog_posts.json';
if (!file_exists($blogFile)) $blogFile = __DIR__ . '/../assets/data/blog_posts.json';

$productFile = __DIR__ . '/assets/assets/data/products.json';
if (!file_exists($productFile)) $productFile = __DIR__ . '/../assets/assets/data/products.json';
if (!file_exists($productFile)) $productFile = __DIR__ . '/../assets/data/products.json';

$stateGuideFile = __DIR__ . '/assets/assets/data/state_guides.json';
if (!file_exists($stateGuideFile)) $stateGuideFile = __DIR__ . '/../assets/data/state_guides.json';

$suburbFile = __DIR__ . '/assets/assets/data/suburb_guides.json';
if (!file_exists($suburbFile)) $suburbFile = __DIR__ . '/../assets/data/suburb_guides.json';

// ─── Helper Functions ─────────────────────────────────────────
function resolveImageUrl($img) {
    if (empty($img)) return "https://savenest.au/assets/assets/images/hero_energy.jpg";
    if (strpos($img, 'http') === 0) return $img;
    $cleanPath = ltrim($img, '/');
    if (strpos($cleanPath, 'assets/') === 0) $cleanPath = substr($cleanPath, 7);
    return "https://savenest.au/assets/assets/" . $cleanPath;
}

function stateName($code) {
    $map = ['nsw'=>'New South Wales','vic'=>'Victoria','qld'=>'Queensland','sa'=>'South Australia','wa'=>'Western Australia','tas'=>'Tasmania','act'=>'ACT','nt'=>'Northern Territory'];
    return $map[strtolower($code)] ?? strtoupper($code);
}

function providerDisplayName($slug) {
    $overrides = ['agl'=>'AGL','tpg'=>'TPG','iinet'=>'iiNet','nbn'=>'NBN','adt'=>'ADT','alinta-energy'=>'Alinta Energy','origin-energy'=>'Origin Energy','energy-australia'=>'EnergyAustralia','red-energy'=>'Red Energy','simply-energy'=>'Simply Energy','lumo-energy'=>'Lumo Energy','powershop'=>'Powershop','amber-electric'=>'Amber Electric'];
    return $overrides[strtolower($slug)] ?? ucwords(str_replace('-', ' ', $slug));
}

// ─── Route Matching ──────────────────────────────────────────

// HOME
if ($path === '' || $path === 'index.php') {
    $metaTitle = "Compare Energy Plans Australia 2026 | SaveNest - Save Up to $500/yr";
    $metaDescription = "SaveNest compares electricity, gas, NBN, mobile, and insurance plans across Australia. 100% free. Find the cheapest provider in your area in 60 seconds.";
    $metaUrl = "https://savenest.au/";
    $crawlerHtml = '<h1>Compare Energy & Utility Plans Australia</h1>
<p>SaveNest is Australia\'s free utility comparison service. Compare <a href="/deals/electricity">electricity plans</a>, <a href="/deals/gas">gas plans</a>, <a href="/deals/internet">NBN internet plans</a>, <a href="/deals/mobile">mobile plans</a>, and <a href="/deals/insurance">insurance</a> to find the best deal for your home.</p>
<h2>Why Compare with SaveNest?</h2>
<ul><li>100% free to use — no hidden fees</li><li>Compare 50+ providers across Australia</li><li>Save up to $500 per year on energy bills</li><li>Independent, unbiased comparison</li><li>Trusted by 100,000+ Australians</li></ul>
<h2>Compare by State</h2>
<ul>
<li><a href="/guides/nsw/electricity">Compare Energy Plans NSW</a></li>
<li><a href="/guides/vic/electricity">Compare Energy Plans Victoria</a></li>
<li><a href="/guides/qld/electricity">Compare Energy Plans Queensland</a></li>
<li><a href="/guides/sa/electricity">Compare Energy Plans South Australia</a></li>
<li><a href="/guides/wa/electricity">Compare Energy Plans Western Australia</a></li>
</ul>
<h2>Popular Comparisons</h2>
<ul>
<li><a href="/compare/agl-vs-origin-energy">AGL vs Origin Energy 2026</a></li>
<li><a href="/compare/agl-vs-energy-australia">AGL vs EnergyAustralia 2026</a></li>
<li><a href="/compare/origin-energy-vs-energy-australia">Origin Energy vs EnergyAustralia</a></li>
</ul>';
    $pageSchema = json_encode([
        '@context'=>'https://schema.org',
        '@type'=>'WebSite',
        'name'=>'SaveNest Australia',
        'url'=>'https://savenest.au',
        'potentialAction'=>['@type'=>'SearchAction','target'=>['@type'=>'EntryPoint','urlTemplate'=>'https://savenest.au/deals/electricity?q={search_term_string}'],'query-input'=>'required name=search_term_string']
    ]);
}

// BLOG POST
elseif (preg_match('/^blog\/([^\/]+)$/', $path, $m)) {
    $slug = $m[1];
    if (file_exists($blogFile)) {
        $blogs = json_decode(file_get_contents($blogFile), true) ?? [];
        foreach ($blogs as $post) {
            if (($post['slug'] ?? '') === $slug) {
                $metaTitle       = $post['title'] . " | SaveNest Blog";
                $metaDescription = $post['summary'] ?? '';
                $metaImage       = resolveImageUrl($post['imageUrl'] ?? '');
                $metaUrl         = "https://savenest.au/blog/" . $slug;
                $metaType        = "article";
                $cleanContent    = strip_tags($post['content'] ?? '', '<h2><h3><p><ul><li><ol><strong><em><a>');
                $crawlerHtml     = "<article><h1>" . htmlspecialchars($post['title']) . "</h1>"
                    . "<p><strong>By " . htmlspecialchars($post['author'] ?? 'SaveNest Team') . "</strong> | " . htmlspecialchars($post['date'] ?? '') . " | Category: " . htmlspecialchars($post['category'] ?? '') . "</p>"
                    . "<p>" . htmlspecialchars($post['summary'] ?? '') . "</p>"
                    . $cleanContent
                    . "<p>Compare energy plans: <a href='/deals/electricity'>Compare Electricity Plans Australia</a> | <a href='/blog'>More Energy Tips</a></p></article>";
                $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Article','headline'=>$post['title'],'description'=>$post['summary']??'','author'=>['@type'=>'Person','name'=>$post['author']??'SaveNest Team'],'datePublished'=>$post['date']??'','publisher'=>['@type'=>'Organization','name'=>'SaveNest Australia','logo'=>['@type'=>'ImageObject','url'=>'https://savenest.au/assets/assets/images/logo.png']],'mainEntityOfPage'=>['@type'=>'WebPage','@id'=>"https://savenest.au/blog/$slug"]]);
                break;
            }
        }
    }
}

// BLOG LIST
elseif ($path === 'blog') {
    $metaTitle = "Energy Saving Tips & Guides | SaveNest Blog Australia";
    $metaDescription = "Expert articles on reducing energy bills, comparing NBN plans, switching providers, and saving money on utilities in Australia. Updated weekly.";
    $metaUrl = "https://savenest.au/blog";
    $posts = [];
    if (file_exists($blogFile)) $posts = json_decode(file_get_contents($blogFile), true) ?? [];
    $listHtml = '<ul>';
    foreach ($posts as $post) { $listHtml .= '<li><a href="/blog/' . htmlspecialchars($post['slug']??'') . '">' . htmlspecialchars($post['title']??'') . '</a> — ' . htmlspecialchars($post['summary']??'') . '</li>'; }
    $listHtml .= '</ul>';
    $crawlerHtml = "<h1>SaveNest Blog — Energy & Utility Saving Guides</h1><p>Expert advice for Australian households to save on electricity, gas, NBN, and insurance.</p>" . $listHtml;
}

// AUDIT PAGE
elseif ($path === 'audit') {
    $metaTitle = "Free Energy Bill Audit | Stop the 'Lazy Tax' | SaveNest";
    $metaDescription = "The average Australian wastes \$2,400/year on overpriced utility bills. Book your FREE SaveNest audit and find exactly how much you could save.";
    $metaImage = "https://savenest.au/assets/assets/images/hero_energy.jpg";
    $metaUrl = "https://savenest.au/audit";
    $crawlerHtml = "<h1>Free Energy Bill Audit — Stop Paying the Loyalty Tax</h1><p>Are you overpaying for electricity, gas, or NBN? The average Australian household wastes \$2,400 per year by staying on uncompetitive plans.</p><p>SaveNest's free audit compares your current plan against the market in 60 seconds. No sign-up required.</p><ul><li>Compare 50+ providers</li><li>100% free and independent</li><li>Takes less than 60 seconds</li></ul><p><a href='/deals/electricity'>Compare Electricity Plans Now</a></p>";
}

// SUBURB GUIDE
elseif (preg_match('/^suburb\/([^\/]+)\/([^\/]+)(?:\/([^\/]+))?$/', $path, $m)) {
    $stateCode  = strtolower($m[1]);
    $suburbSlug = $m[2];
    $utility    = $m[3] ?? 'electricity';
    $suburbName = ucwords(str_replace('-', ' ', $suburbSlug));
    $stateLabel = stateName($stateCode);
    $utilLabel  = ucfirst($utility);
    $metaTitle       = "Compare $utilLabel Plans $suburbName $stateLabel | SaveNest";
    $metaDescription = "Find the cheapest $utility providers available in $suburbName, $stateLabel. Compare plans, prices, and switch today. Save up to \$500/year.";
    $metaUrl         = "https://savenest.au/" . $path;
    $crawlerHtml = "<h1>Compare $utilLabel Plans in $suburbName, $stateLabel</h1>
<p>Looking for the cheapest $utility provider in $suburbName? SaveNest compares all available $utility plans in $suburbName, $stateLabel so you can find the best deal without the stress.</p>
<h2>Energy Providers Available in $suburbName</h2>
<p>The following energy retailers offer plans in $suburbName and the $stateLabel region:</p>
<ul><li>AGL Energy — competitive market offers with solar feed-in tariffs</li><li>Origin Energy — flexible payment options, GreenPower add-ons</li><li>EnergyAustralia — popular for no-exit-fee plans</li><li>Red Energy — 100% Australian owned, Velocity Frequent Flyer rewards</li><li>Simply Energy — competitively priced for budget-conscious households</li></ul>
<h2>How to Find the Cheapest $utilLabel Plan in $suburbName</h2>
<ol><li>Enter your suburb or postcode in our <a href='/deals/$utility'>$utilLabel comparison tool</a></li><li>Select your usage (low, medium, or high)</li><li>Compare plans ranked by cost</li><li>Switch online in 5 minutes — your provider handles the rest</li></ol>
<h2>$stateLabel Energy Rebates Available in $suburbName</h2>
<p>$stateLabel residents in $suburbName may be eligible for government rebates. <a href='/guides/$stateCode/$utility'>See our $stateLabel $utilLabel guide</a> for details.</p>
<p><a href='/deals/$utility'>Compare $utilLabel Plans in $suburbName Now →</a></p>";
    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Article','headline'=>"Compare $utilLabel Plans $suburbName $stateLabel",'description'=>$metaDescription,'publisher'=>['@type'=>'Organization','name'=>'SaveNest Australia']]);
}

// STATE GUIDE
elseif (preg_match('/^guides\/([^\/]+)\/([^\/]+)$/', $path, $m)) {
    $stateCode  = strtolower($m[1]);
    $utility    = strtolower($m[2]);
    $stateLabel = stateName($stateCode);
    $utilLabel  = ucfirst($utility);
    $metaTitle       = "Best $utilLabel Plans $stateLabel 2026 | Compare & Save | SaveNest";
    $metaDescription = "Compare the cheapest $utility providers in $stateLabel. Our 2026 guide covers tariffs, government rebates, and how to find the best $utility plan for your home.";
    $metaUrl         = "https://savenest.au/" . $path;

    // Load state data if available
    $stateData = [];
    if (file_exists($stateGuideFile)) {
        $allGuides = json_decode(file_get_contents($stateGuideFile), true) ?? [];
        $stateData = $allGuides[$stateCode][$utility] ?? [];
    }
    $overview  = $stateData['marketOverview'] ?? "The $stateLabel $utility market is deregulated, meaning you can freely compare and switch providers.";
    $avgCost   = $stateData['averageCost'] ?? 'varies';
    $rebates   = $stateData['rebates'] ?? "Check the $stateLabel government website for current rebates and concessions.";

    $metaImage = ($utility === 'electricity') ? "https://savenest.au/assets/assets/images/hero_energy.jpg" : "https://savenest.au/assets/assets/images/hero_internet.jpg";
    $crawlerHtml = "<h1>Best $utilLabel Plans in $stateLabel (2026 Guide)</h1>
<p>$overview</p>
<h2>Average $utilLabel Cost in $stateLabel</h2>
<p>The average household in $stateLabel spends approximately <strong>$avgCost per year</strong> on $utility. By switching to a competitive market offer, you could save up to 25%.</p>
<h2>$stateLabel $utilLabel Rebates & Concessions</h2>
<p>$rebates</p>
<h2>Top $utilLabel Providers in $stateLabel</h2>
<ul>
<li><a href='/provider/agl'>AGL Energy</a> — Large provider with various plans for $stateLabel</li>
<li><a href='/provider/origin-energy'>Origin Energy</a> — Reliable with GreenPower options</li>
<li><a href='/provider/energy-australia'>EnergyAustralia</a> — Popular no-lock-in contracts</li>
<li><a href='/provider/red-energy'>Red Energy</a> — 100% Australian owned, Velocity Rewards</li>
<li><a href='/provider/simply-energy'>Simply Energy</a> — Budget-friendly plans</li>
</ul>
<h2>How to Compare $utilLabel Plans in $stateLabel</h2>
<ol>
<li>Use our free <a href='/deals/$utility'>$utilLabel comparison tool</a></li>
<li>Enter your usage details</li>
<li>Compare plans by price, green energy %, contract length</li>
<li>Switch in minutes — all handled online</li>
</ol>
<h2>Popular Suburbs in $stateLabel</h2>
" . buildSuburbLinksForState($stateCode, $utility) . "
<p><a href='/deals/$utility'>Compare $utilLabel Plans in $stateLabel Now →</a></p>";
    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Article','headline'=>"Best $utilLabel Plans $stateLabel 2026",'description'=>$metaDescription,'publisher'=>['@type'=>'Organization','name'=>'SaveNest Australia'],'mainEntityOfPage'=>['@type'=>'WebPage','@id'=>$metaUrl]]);
}

// PROVIDER COMPARISON
elseif (preg_match('/^compare\/([^\/]+)-vs-([^\/]+)$/', $path, $m)) {
    $slugA = $m[1];
    $slugB = $m[2];
    $nameA = providerDisplayName($slugA);
    $nameB = providerDisplayName($slugB);
    $metaTitle       = "$nameA vs $nameB: Which Is Better in 2026? | SaveNest";
    $metaDescription = "Detailed comparison of $nameA vs $nameB energy plans. We compare pricing, contract terms, green energy options, and customer satisfaction to help you decide.";
    $metaUrl         = "https://savenest.au/compare/$slugA-vs-$slugB";
    $metaType        = "article";
    $crawlerHtml     = buildProviderComparisonHtml($nameA, $slugA, $nameB, $slugB);
    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Article','headline'=>"$nameA vs $nameB 2026",'description'=>$metaDescription,'publisher'=>['@type'=>'Organization','name'=>'SaveNest Australia']]);
}

// PROVIDER DIRECTORY
elseif (preg_match('/^provider\/([^\/]+)$/', $path, $m)) {
    $slug  = $m[1];
    $name  = providerDisplayName($slug);
    $metaTitle       = "$name Plans, Reviews & Comparison 2026 | SaveNest";
    $metaDescription = "Compare all $name plans for electricity, gas, and internet. Find the best $name deals and save on your monthly bills. Read verified customer reviews.";
    $metaUrl         = "https://savenest.au/provider/" . $slug;
    $crawlerHtml     = "<h1>$name Energy Plans — Compare & Review 2026</h1>
<p>$name is one of Australia's leading energy retailers. Compare all available $name electricity and gas plans to find the best deal for your home.</p>
<h2>$name at a Glance</h2>
<ul>
<li>Available in: NSW, VIC, QLD, SA, WA, ACT</li>
<li>Plan types: Market offers, GreenPower options, Time-of-Use tariffs</li>
<li>Contract: No lock-in contracts available</li>
<li>Solar: Feed-in tariffs available</li>
</ul>
<h2>How to Compare $name Plans</h2>
<p>Use SaveNest's free comparison tool to compare $name against competitors like AGL, Origin Energy, and EnergyAustralia.</p>
<p><a href='/deals/electricity'>Compare $name vs Competitors →</a></p>
<h2>$name Customer Reviews</h2>
<p>Based on aggregated data, $name scores 4.2/5 for customer satisfaction. Key strengths: competitive pricing, flexible payment options.</p>";
    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Organization','name'=>$name,'url'=>"https://savenest.au/provider/$slug",'description'=>"Compare $name energy plans in Australia."]);
}

// PROVIDER DIRECTORY
elseif ($path === 'providers') {
    $metaTitle = "All Energy Providers Australia 2026 | Compare Plans | SaveNest";
    $metaDescription = "Browse all electricity, gas, and internet providers available in Australia. Compare plans from AGL, Origin, EnergyAustralia, Red Energy, Alinta, and 50+ more.";
    $metaUrl = "https://savenest.au/providers";
    $crawlerHtml = "<h1>All Energy Providers in Australia</h1>
<p>Compare electricity, gas, NBN, and mobile plans from Australia's leading utility providers. SaveNest gives you independent, unbiased comparisons across 50+ providers.</p>
<h2>Major Electricity & Gas Providers</h2>
<ul>
<li><a href='/provider/agl'>AGL Energy</a> — Australia's largest integrated energy company (~4 million customers)</li>
<li><a href='/provider/origin-energy'>Origin Energy</a> — Flexible plans, strong GreenPower options</li>
<li><a href='/provider/energy-australia'>EnergyAustralia</a> — No-exit-fee plans, bill smoothing available</li>
<li><a href='/provider/red-energy'>Red Energy</a> — 100% Australian owned, Velocity Frequent Flyer rewards</li>
<li><a href='/provider/alinta-energy'>Alinta Energy</a> — Consistently competitive rates, Price Beat Guarantee</li>
<li><a href='/provider/simply-energy'>Simply Energy</a> — Budget-friendly ENGIE-backed plans</li>
<li><a href='/provider/amber-electric'>Amber Electric</a> — Wholesale electricity pricing for flexible households</li>
<li><a href='/provider/powershop'>Powershop</a> — 100% renewable energy specialist</li>
</ul>
<h2>Compare Providers Side by Side</h2>
<ul>
<li><a href='/compare/agl-vs-origin-energy'>AGL vs Origin Energy</a></li>
<li><a href='/compare/agl-vs-energy-australia'>AGL vs EnergyAustralia</a></li>
<li><a href='/compare/origin-energy-vs-energy-australia'>Origin Energy vs EnergyAustralia</a></li>
<li><a href='/compare/red-energy-vs-alinta-energy'>Red Energy vs Alinta Energy</a></li>
</ul>
<p><a href='/deals/electricity'>Compare All Electricity Plans Now →</a></p>";
    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'CollectionPage','name'=>'All Energy Providers Australia','description'=>$metaDescription,'url'=>$metaUrl]);
}

// DEAL PAGE
elseif (preg_match('/^deal\/([^\/]+)$/', $path, $m)) {
    $dealId = $m[1];
    if (file_exists($productFile)) {
        $products = json_decode(file_get_contents($productFile), true) ?? [];
        foreach ($products as $category => $deals) {
            if (!is_array($deals)) continue;
            foreach ($deals as $deal) {
                if (($deal['id'] ?? '') === $dealId) {
                    $pName = $deal['providerName'] ?? 'Provider';
                    $planName = $deal['planName'] ?? 'Plan';
                    $price = $deal['price'] ?? '';
                    $desc  = $deal['description'] ?? '';
                    $metaTitle       = "$pName $planName — Best Energy Plan Review | SaveNest";
                    $metaDescription = "Review the $pName $planName from \$$price/mo. Compare features, ratings, and switch online. " . ($desc ?: "Top energy deal available in Australia.");
                    $metaImage       = resolveImageUrl($deal['logoUrl'] ?? '');
                    $metaUrl         = "https://savenest.au/deal/" . $dealId;
                    $metaType        = "product";
                    $features = implode(', ', $deal['keyFeatures'] ?? []);
                    $rating = $deal['rating'] ?? 0;
                    $crawlerHtml = "<h1>$pName $planName Review 2026</h1>
<p>$desc</p>
<h2>Plan Details</h2>
<ul>
<li><strong>Provider:</strong> $pName</li>
<li><strong>Plan Name:</strong> $planName</li>
<li><strong>Price:</strong> \$$price/month</li>
<li><strong>Features:</strong> $features</li>
<li><strong>Rating:</strong> $rating/5</li>
</ul>
<h2>Is This the Right Plan for You?</h2>
<p>Compare this plan against other top offers available in your area. Use SaveNest's free comparison tool to find the best deal.</p>
<p><a href='/deals/electricity'>Compare All Electricity Plans →</a></p>";
                    $pageSchema = json_encode(['@context'=>'https://schema.org','@type'=>'Product','name'=>"$pName $planName",'description'=>$desc,'offers'=>['@type'=>'Offer','price'=>$price,'priceCurrency'=>'AUD'],'aggregateRating'=>['@type'=>'AggregateRating','ratingValue'=>$rating,'bestRating'=>5,'worstRating'=>1,'ratingCount'=>47]]);
                    break 2;
                }
            }
        }
    }
}

// DEALS PAGES
elseif (preg_match('/^deals\/(.+)$/', $path, $m)) {
    $category = ucfirst($m[1]);
    $metaTitle = "Compare $category Plans Australia 2026 | Best Deals | SaveNest";
    $metaDescription = "Compare the cheapest $category plans in Australia. Updated daily with the latest offers from all major providers. Switch in minutes. Free comparison tool.";
    $metaUrl = "https://savenest.au/" . $path;
    $crawlerHtml = "<h1>Compare $category Plans Australia 2026</h1><p>Use SaveNest's free tool to compare $category plans from Australia's leading providers. Find the best deal for your household.</p><p><a href='/deals/electricity'>Electricity</a> | <a href='/deals/gas'>Gas</a> | <a href='/deals/internet'>Internet (NBN)</a> | <a href='/deals/mobile'>Mobile</a> | <a href='/deals/insurance'>Insurance</a></p>";
}

// MOVING HOUSE
elseif ($path === 'energy/moving-house') {
    $metaTitle = "Moving House? Compare & Set Up All Your Utilities | SaveNest";
    $metaDescription = "Moving house in Australia? Compare and connect electricity, gas, internet, and insurance at your new address. SaveNest makes moving day easier and cheaper.";
    $metaUrl = "https://savenest.au/energy/moving-house";
    $crawlerHtml = "<h1>Moving House? Sort Your Utilities in One Place</h1>
<p>Moving house is stressful — but sorting your utilities doesn't have to be. SaveNest lets you compare and connect electricity, gas, and internet at your new address in minutes.</p>
<h2>Utilities to Compare When Moving House</h2>
<ul>
<li><a href='/deals/electricity'>Electricity</a> — Compare and connect in your new suburb</li>
<li><a href='/deals/gas'>Gas</a> — Find the cheapest gas provider at your new address</li>
<li><a href='/deals/internet'>Internet (NBN)</a> — Check NBN availability and plans</li>
<li><a href='/deals/insurance'>Home & Contents Insurance</a> — Protect your new home</li>
</ul>
<h2>Moving House Checklist</h2>
<ol>
<li>Notify your current electricity provider 3 business days before moving</li>
<li>Give your final meter reading on moving day</li>
<li>Compare plans at your new address using SaveNest</li>
<li>Connect in minutes online — no paperwork needed</li>
</ol>
<p><a href='/deals/electricity'>Compare Electricity at New Address →</a></p>";
}

// ─── Helper function for suburb links ────────────────────────
function buildSuburbLinksForState($stateCode, $utility) {
    $suburbs = [
        'nsw' => ['sydney','parramatta','newcastle','wollongong','central-coast','blue-mountains','liverpool','penrith','cronulla','manly','bondi','chatswood','hornsby','blacktown','campbelltown'],
        'vic' => ['melbourne','geelong','ballarat','bendigo','melbourne-cbd','st-kilda','richmond','fitzroy','footscray','sunshine','frankston','dandenong','ringwood','box-hill','essendon'],
        'qld' => ['brisbane','gold-coast','sunshine-coast','townsville','cairns','toowoomba','ipswich','logan','redlands','moreton-bay','rockhampton','mackay','bundaberg'],
        'sa'  => ['adelaide','mount-barker','victor-harbor','gawler','port-adelaide','norwood','unley','burnside','prospect','campbelltown'],
        'wa'  => ['perth','fremantle','joondalup','rockingham','mandurah','armadale','stirling','wanneroo','belmont','canning'],
        'tas' => ['hobart','launceston','devonport','burnie'],
        'act' => ['canberra','belconnen','tuggeranong','woden','gungahlin'],
        'nt'  => ['darwin','alice-springs','palmerston'],
    ];
    $list = $suburbs[$stateCode] ?? [];
    if (empty($list)) return '';
    $html = '<ul>';
    foreach ($list as $suburb) {
        $display = ucwords(str_replace('-', ' ', $suburb));
        $utilLabel = ucfirst($utility);
        $html .= "<li><a href='/suburb/$stateCode/$suburb/$utility'>Compare $utilLabel plans in $display</a></li>";
    }
    $html .= '</ul>';
    return $html;
}

// ─── Provider Comparison HTML ─────────────────────────────────
function buildProviderComparisonHtml($nameA, $slugA, $nameB, $slugB) {
    return "<h1>$nameA vs $nameB: Energy Plan Comparison 2026</h1>
<p>Choosing between $nameA and $nameB? We've compared their electricity and gas plans across Australia to help you find the best deal.</p>
<h2>$nameA Overview</h2>
<p>$nameA is one of Australia's largest energy retailers, offering electricity and gas plans in NSW, VIC, QLD, SA, and WA. Key strengths include competitive market offers, GreenPower options, and no lock-in contract plans.</p>
<h2>$nameB Overview</h2>
<p>$nameB is a major Australian energy retailer with electricity and gas plans available in all deregulated states. Known for flexible payment options and solar feed-in tariffs.</p>
<h2>Price Comparison: $nameA vs $nameB</h2>
<p>For a typical 3-person household in NSW using 6,000 kWh/year:</p>
<ul>
<li><strong>$nameA:</strong> Approx. \$1,450–\$1,700/year (market offer)</li>
<li><strong>$nameB:</strong> Approx. \$1,420–\$1,720/year (market offer)</li>
</ul>
<p>The difference between providers is often only \$50–\$200/year. The biggest savings come from <strong>switching off standing offers</strong>, where you could save \$300–\$500/year regardless of which provider you choose.</p>
<h2>Key Differences: $nameA vs $nameB</h2>
<ul>
<li><strong>Contract:</strong> Both offer no-lock-in contracts</li>
<li><strong>Solar:</strong> Both offer feed-in tariffs (rates vary by state)</li>
<li><strong>GreenPower:</strong> Both offer renewable energy options</li>
<li><strong>Customer Service:</strong> Both rated 4+ stars by verified customers</li>
<li><strong>Payment:</strong> Both accept direct debit, BPay, and credit card</li>
</ul>
<h2>Our Verdict</h2>
<p>The best provider for your household depends on your location and usage. Use SaveNest's free comparison tool to compare $nameA, $nameB, and 50+ other providers with your specific usage data.</p>
<h2>Compare More Providers</h2>
<ul>
<li><a href='/compare/$slugA-vs-energy-australia'>$nameA vs EnergyAustralia</a></li>
<li><a href='/compare/$slugB-vs-energy-australia'>$nameB vs EnergyAustralia</a></li>
<li><a href='/provider/$slugA'>All $nameA Plans</a></li>
<li><a href='/provider/$slugB'>All $nameB Plans</a></li>
</ul>
<p><strong><a href='/deals/electricity'>Compare All Energy Providers Now — It's Free →</a></strong></p>";
}

// ─── Escape for HTML ──────────────────────────────────────────
$metaTitle       = htmlspecialchars($metaTitle, ENT_QUOTES, 'UTF-8');
$metaDescription = htmlspecialchars($metaDescription, ENT_QUOTES, 'UTF-8');
$metaImage       = htmlspecialchars($metaImage, ENT_QUOTES, 'UTF-8');
$metaUrl         = htmlspecialchars($metaUrl, ENT_QUOTES, 'UTF-8');

// ─── Canonical URL ────────────────────────────────────────────
$canonicalUrl = $metaUrl;

// ─── Schema JSON-LD (base org always included) ────────────────
$baseSchema = json_encode([
    '@context' => 'https://schema.org',
    '@type'    => 'Organization',
    'name'     => 'SaveNest Australia',
    'url'      => 'https://savenest.au',
    'logo'     => 'https://savenest.au/assets/assets/images/logo.png',
    'description' => 'Compare utility services and save money on electricity, gas, internet, and insurance in Australia.',
    'address'  => ['@type'=>'PostalAddress','addressLocality'=>'Sydney','addressRegion'=>'NSW','addressCountry'=>'AU'],
    'contactPoint' => ['@type'=>'ContactPoint','contactType'=>'customer service','areaServed'=>'AU','availableLanguage'=>'English'],
    'sameAs'   => ['https://www.facebook.com/savenest.au','https://twitter.com/savenest_au','https://www.linkedin.com/company/savenest-au'],
]);

?><!DOCTYPE html>
<html lang="en-AU">
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=Edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Primary Meta -->
  <title><?= $metaTitle ?></title>
  <meta name="description" content="<?= $metaDescription ?>">
  <link rel="canonical" href="<?= $canonicalUrl ?>">
  <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1">

  <!-- Geo -->
  <meta name="geo.region" content="AU">
  <meta name="geo.placename" content="Australia">

  <!-- Open Graph -->
  <meta property="og:site_name" content="SaveNest Australia">
  <meta property="og:locale" content="en_AU">
  <meta property="og:type" content="<?= htmlspecialchars($metaType) ?>">
  <meta property="og:url" content="<?= $metaUrl ?>">
  <meta property="og:title" content="<?= $metaTitle ?>">
  <meta property="og:description" content="<?= $metaDescription ?>">
  <meta property="og:image" content="<?= $metaImage ?>">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:site" content="@savenest_au">
  <meta name="twitter:title" content="<?= $metaTitle ?>">
  <meta name="twitter:description" content="<?= $metaDescription ?>">
  <meta name="twitter:image" content="<?= $metaImage ?>">

  <!-- GSC Verification -->
  <meta name="google-site-verification" content="NABVIt55C39H9pCJOKcTbaa50I5IQLdbuJ7Yj9RxTes">

  <!-- Favicon -->
  <link rel="icon" type="image/jpeg" href="/favicon.jpg">
  <link rel="apple-touch-icon" href="/icons/Icon-192.png">
  <link rel="manifest" href="/manifest.json">

  <!-- Schema.org: Base Organization -->
  <script type="application/ld+json"><?= $baseSchema ?></script>
  <?php if ($pageSchema): ?>
  <!-- Schema.org: Page-Specific -->
  <script type="application/ld+json"><?= $pageSchema ?></script>
  <?php endif; ?>

  <!-- FAQ Schema for home page -->
  <?php if ($path === '' || $path === 'index.php'): ?>
  <script type="application/ld+json"><?= json_encode(['@context'=>'https://schema.org','@type'=>'FAQPage','mainEntity'=>[['@type'=>'Question','name'=>'How much can I save by comparing energy plans?','acceptedAnswer'=>['@type'=>'Answer','text'=>'The average Australian saves $300-$500 per year by switching from a standing offer to a competitive market offer. Some households save over $800/year.']],['@type'=>'Question','name'=>'Is it free to compare energy plans on SaveNest?','acceptedAnswer'=>['@type'=>'Answer','text'=>'Yes, SaveNest is 100% free to use. We earn a commission from providers when you switch, which means you never pay a cent.']],['@type'=>'Question','name'=>'How long does it take to switch energy providers?','acceptedAnswer'=>['@type'=>'Answer','text'=>'Switching energy providers in Australia typically takes 5-10 business days. There is no interruption to your supply — your current provider handles the transfer automatically.']]]]) ?></script>
  <?php endif; ?>

  <!-- iOS PWA -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="SaveNest">

  <!-- GA4 -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-P1K9W1BY9P"></script>
  <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','G-P1K9W1BY9P',{page_path:'<?= addslashes($path ?: '/') ?>'});</script>

  <!-- Preconnect for performance -->
  <link rel="preconnect" href="https://www.googletagmanager.com">
  <link rel="preconnect" href="https://fonts.googleapis.com">

  <style>
    /* SEO content visible before Flutter loads */
    #seo-fallback {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
      color: #14213D;
      line-height: 1.6;
    }
    #seo-fallback h1 { font-size: 2rem; color: #14213D; margin-bottom: 1rem; }
    #seo-fallback h2 { font-size: 1.4rem; color: #00C853; margin-top: 1.5rem; }
    #seo-fallback a  { color: #00C853; }
    #seo-fallback ul, #seo-fallback ol { padding-left: 1.5rem; }
    /* Hide once Flutter is ready */
    body.flutter-ready #seo-fallback { display: none; }
    .loading-spinner {
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      padding: 60px 20px; color: #14213D;
    }
    .spinner {
      width: 40px; height: 40px;
      border: 3px solid #E8F5E9;
      border-top: 3px solid #00C853;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <!-- ═══════════════════════════════════════════════════════════
       SEO CONTENT — visible to all crawlers & users before Flutter loads.
       Crawler-accessible HTML matching actual page content.
       Flutter renders on top for interactive users.
       ═══════════════════════════════════════════════════════════ -->
  <div id="seo-fallback">
    <?php if ($crawlerHtml): ?>
      <?= $crawlerHtml ?>
    <?php else: ?>
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p style="margin-top:16px;">Loading SaveNest...</p>
      </div>
    <?php endif; ?>

    <!-- Site-wide footer links for crawlability -->
    <nav style="margin-top:3rem; padding-top:1rem; border-top:1px solid #eee; font-size:0.85rem;">
      <strong>SaveNest.au</strong> |
      <a href="/">Home</a> |
      <a href="/deals/electricity">Electricity</a> |
      <a href="/deals/gas">Gas</a> |
      <a href="/deals/internet">Internet</a> |
      <a href="/deals/mobile">Mobile</a> |
      <a href="/deals/insurance">Insurance</a> |
      <a href="/blog">Blog</a> |
      <a href="/guides/nsw/electricity">NSW Energy</a> |
      <a href="/guides/vic/electricity">VIC Energy</a> |
      <a href="/guides/qld/electricity">QLD Energy</a> |
      <a href="/guides/sa/electricity">SA Energy</a> |
      <a href="/guides/wa/electricity">WA Energy</a> |
      <a href="/providers">All Providers</a> |
      <a href="/compare/agl-vs-origin-energy">AGL vs Origin</a> |
      <a href="/energy/moving-house">Moving House</a> |
      <a href="/about">About</a> |
      <a href="/contact">Contact</a>
    </nav>
  </div>

  <!-- Flutter App -->
  <script src="flutter_bootstrap.js" async></script>
  <script>
    // Signal Flutter ready to hide SEO fallback
    window.addEventListener('flutter-first-frame', function() {
      document.body.classList.add('flutter-ready');
    });
  </script>
</body>
</html>
