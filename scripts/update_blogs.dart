import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('assets/data/blog_posts.json');
  final content = await file.readAsString();
  List<dynamic> posts = jsonDecode(content);

  // The 15 new articles (b21-b35)
  final newPosts = [
    {
        "id": "b21",
        "title": "24% Bill Hikes: The DMO 7 Reality Check",
        "category": "Energy",
        "author": "David Ross",
        "date": "Feb 12, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1550565118-c974095cc3d5?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1550565118-c974095cc3d5?auto=format&fit=crop&w=400&q=80",
        "summary": "Retail energy bills are set to rise by up to 24% from July 2026 as government subsidies expire. Here is how to shield your wallet from DMO 7.",
        "content": "<p class=\"intro-text\">If you thought the energy crisis was over, think again. The Australian Energy Regulator's latest draft determination for Default Market Offer (DMO) 7 paints a sobering picture for 2026. While wholesale costs have technically dropped, the expiry of federal \"Bill Relief\" rebates means effective prices for households in NSW, SA, and SE QLD are projected to jump by up to 24%.</p><h2>The \"Rebate Cliff\" Explained</h2><p>For the past two years, your electricity bill has been artificially suppressed by taxpayer-funded rebates. These rebates, ranging from \$500 to \$700 per household, masked the underlying cost of energy. As of July 1, 2026, those training wheels are coming off.</p><p>Data from the AER indicates that while the \"base\" price of energy has stabilized, the consumer's out-of-pocket expense will spike. This is what we call the \"Rebate Cliff\".</p><h2>Why Wholesale Drops Didn't Save Us</h2><p>It seems counterintuitive: renewables are generating cheaper power than ever, so why are bills going up? The answer lies in the \"poles and wires\". Network costs—the price to transport electricity—have surged due to inflation and the massive infrastructure build required to connect new solar and wind farms.</p><p>Additionally, retailers are clawing back margins after years of volatility. The \"standing offer\" (the default price) is no longer a safe haven.</p><h2>Your 3-Step Shield Strategy</h2><ol><li><strong>Ditch the Standing Offer:</strong> If you haven't switched in 12 months, you are likely on the DMO. Market offers are currently 18-27% cheaper than the DMO. Switching now locks in a lower rate before the July hike hype begins.</li><li><strong>Target \"Solar Soaker\" Plans:</strong> Retailers like OVO and Amber are offering free or extremely cheap electricity between 11 AM and 2 PM to soak up excess solar. Shift your laundry and dishwasher to this window.</li><li><strong>Pre-pay for Winter:</strong> Some retailers offer \"bill smoothing\" or pay-in-advance discounts. Locking in credit now can offset the winter heating shock.</li></ol>",
        "slug": "24-percent-bill-hikes-dmo-7-reality-check"
    },
    {
        "id": "b22",
        "title": "NBN Speed Boost: The Great Upgrade of 2026",
        "category": "Internet",
        "author": "Mike Chen",
        "date": "Feb 18, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1558346490-a72e53ae2d4f?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1558346490-a72e53ae2d4f?auto=format&fit=crop&w=400&q=80",
        "summary": "NBN Co is deleting the 100Mbps limit for millions. With new 500, 750, and 2000 Mbps tiers, is it time to upgrade your copper connection for free?",
        "content": "<p class=\"intro-text\">The days of buffering 4K streams are officially numbered. In a bid to future-proof Australia's digital spine, NBN Co has unleashed a wave of speed upgrades that make the old \"NBN 100\" look like dial-up. Welcome to the era of multi-gigabit home internet.</p><h2>The New Speed Hierarchy</h2><p>As of late 2025, the speed tiers have shifted. The old \"premium\" 100Mbps is now the new mid-range. Here is the new landscape for 2026:</p><ul><li><strong>Home Superfast (NBN 500):</strong> Up to 500Mbps download. Perfect for large families with 5+ devices streaming simultaneously.</li><li><strong>Home Ultrafast (NBN 1000):</strong> Now with doubled upload speeds (100Mbps) on selected plans, making it viable for content creators.</li><li><strong>Hyperfast (NBN 2000):</strong> The new 2Gbps frontier. Overkill for most? Yes. Incredible for downloading a 100GB game in under 7 minutes? Absolutely.</li></ul><h2>The Death of Copper (FTTC)</h2><p>Perhaps the biggest news for 2026 is the relaxation of upgrade rules for Fibre to the Curb (FTTC) households. Previously, you had to order a pricey high-speed plan to trigger a free fibre upgrade. From July 2026, NBN Co is expected to wave this requirement for over 600,000 homes.</p><p>This means you can get a full Fibre to the Premises (FTTP) line installed—increasing your home's value and internet reliability—without committing to a \$130/month contract initially.</p><h2>Is it Worth the Cost?</h2><p>While speeds are up, so are wholesale costs. The NBN 50 plan price has crept up by roughly \$5/month. However, the price-per-megabit has plummeted. If you are paying \$95 for NBN 50, you might find an NBN 250 plan for just \$10 more.</p><p><strong>Verdict:</strong> If you work from home or have teenagers, the jump to FTTP is a no-brainer. Check your address on the SaveNest NBN comparison tool to see if you are eligible for the free upgrade today.</p>",
        "slug": "nbn-speed-boost-great-upgrade-2026"
    },
    {
        "id": "b23",
        "title": "Home Insurance Crisis: The Uninsurable Zones",
        "category": "Insurance",
        "author": "Emma Wilson",
        "date": "Mar 02, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=400&q=80",
        "summary": "With a 29% rise in building costs and extreme weather events, some Australian suburbs are becoming 'uninsurable'. Are you in a red zone?",
        "content": "<p class=\"intro-text\">It is the letter no homeowner wants to open: a renewal notice with a 50% premium hike, or worse, a \"we can no longer insure you\" notification. In 2026, the Australian home insurance market is facing a perfect storm of climate risk and inflation.</p><h2>The \"Red Zone\" Expansion</h2><p>Insurers are redrawing their risk maps. Areas previously considered \"safe\" are now being flagged for flood or bushfire risk due to updated climate modeling. If you live in parts of Northern NSW, SE Queensland, or even certain suburbs of Melbourne, you might be facing what experts call \"technical uninsurability\"—where insurance exists, but at \$15,000+ a year, it is effectively unaffordable.</p><h2>The 29% Construction Premium</h2><p>It's not just the weather. The cost to rebuild a home in Australia has surged by 29% over the last 5 years. Labour shortages and material costs mean that a home insured for \$500,000 in 2021 might cost \$750,000 to replace in 2026.</p><p><strong>The Trap:</strong> If you haven't updated your \"Sum Insured\", you are likely underinsured. In the event of a total loss, you could be left hundreds of thousands of dollars short.</p><h2>How to Lower Your Premium</h2><ul><li><strong>Increase Your Excess:</strong> Raising your excess from \$500 to \$2,000 can drop your premium by up to 20%.</li><li><strong>Mitigation Discounts:</strong> Some insurers (like Suncorp and NRMA) offer discounts if you install cyclone-rated roofing or bushfire sprinklers.</li><li><strong>Shop Around (Aggressively):</strong> The \"loyalty tax\" in insurance is brutal. Switching providers is often the only way to reset your premium to a market rate.</li></ul>",
        "slug": "home-insurance-crisis-uninsurable-zones"
    },
    {
        "id": "b24",
        "title": "The EV Tariff Revolution: Charging for 8c/kWh",
        "category": "EV",
        "author": "Dr. Alan Grant",
        "date": "Mar 10, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=400&q=80",
        "summary": "Fueling your car for the price of a coffee? New dedicated EV tariffs from AGL, OVO, and Origin are changing the math on electric vehicle ownership.",
        "content": "<p class=\"intro-text\">Petrol prices are hovering around \$2.20/litre, but smart EV owners are \"filling up\" for less than \$5. The secret? The explosion of dedicated EV home charging tariffs in 2026.</p><h2>The 8-Cent Club</h2><p>Retailers are fighting for the EV market share. Providers like OVO Energy and AGL have introduced \"super off-peak\" windows, specifically for EV charging. These windows typically run between midnight and 6 AM, offering rates as low as 8 cents per kWh.</p><p><strong>The Math:</strong><br>Battery Size: 60kWh (e.g., Tesla Model 3 RWD)<br>Cost to Fill (0-100%): 60 * \$0.08 = <strong>\$4.80</strong><br>Range: ~450km<br><strong>Cost per 100km: \$1.06</strong></p><p>Compare that to a petrol car consuming 8L/100km at \$2.20/L, costing you <strong>\$17.60</strong> for the same distance.</p><h2>Smart Charging Required</h2><p>The catch? You need a smart charger or a compatible car API. These tariffs often require the retailer to have \"managed control\" or visibility of your charging to ensuring you are only drawing power when the grid is quiet. It is a small price to pay for 90% fuel savings.</p><h2>V2G: The Next Step</h2><p>Keep an eye out for Vehicle-to-Grid (V2G) trials expanding in SA and ACT later this year. This technology allows your car to power your house during peak evening rates, effectively wiping out your remaining electricity bill.</p>",
        "slug": "ev-tariff-revolution-charging-8c-kwh"
    },
    {
        "id": "b25",
        "title": "5G Home Internet: The NBN Killer?",
        "category": "Internet",
        "author": "Sarah Jenkins",
        "date": "Mar 22, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1519389950476-658c14c5d45d?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1519389950476-658c14c5d45d?auto=format&fit=crop&w=400&q=80",
        "summary": "With mmWave technology rolling out in CBDs, 5G home internet is hitting speeds of 500Mbps+. Is it finally reliable enough to ditch the cable?",
        "content": "<p class=\"intro-text\">For years, 5G Home Internet was the \"budget alternative\"—good for renters, but bad for gamers due to lag. In 2026, the deployment of mmWave (millimeter wave) technology in Australian capital cities is changing the narrative.</p><h2>Speed vs. Stability</h2><p>Our latest tests in suburban Sydney and Melbourne show 5G plans from Telstra and Optus consistently hitting 300-500Mbps download speeds. That rivals NBN Superfast plans for a fraction of the price (typically \$60-\$70/month).</p><p>However, physics still applies. 5G signals struggle to penetrate double-brick walls, and \"congestion\" during the Netflix peak hour (7 PM - 9 PM) can see speeds drop by 40%.</p><h2>Who Should Switch?</h2><ul><li><strong>Renters:</strong> No technician visits, no modem setup fees. Just plug and play.</li><li><strong>Solo/Couple Households:</strong> Perfect for 1-2 simultaneous streams.</li><li><strong>Budget Conscious:</strong> Savings of \$240/year compared to NBN 50 plans.</li></ul><p><strong>Who Should Stay on NBN?</strong><br>Gamers (ping is still higher on 5G), large families, and work-from-home pros who need bulletproof reliability for Zoom calls.</p>",
        "slug": "5g-home-internet-nbn-killer"
    },
    {
        "id": "b26",
        "title": "Sydney Water Bills Up 50%: The New Liquid Gold",
        "category": "Utilities",
        "author": "David Ross",
        "date": "Apr 05, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1585822765668-24357732a328?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1585822765668-24357732a328?auto=format&fit=crop&w=400&q=80",
        "summary": "It is not just energy. Water bills in Sydney and Melbourne are skyrocketing to fund new infrastructure. Here is how to audit your usage.",
        "content": "<p class=\"intro-text\">While we all focused on electricity prices, another utility bill has been quietly exploding. Sydney Water's recent 50% price hike for 2025-2029 has sent shockwaves through strata committees and households alike.</p><h2>Why the Hike?</h2><p>Aging infrastructure and a booming population. The cost to service new housing developments in Western Sydney and maintain century-old pipes in the Inner West is being passed on to the consumer. Melbourne is seeing similar trends with \"Greater Western Water\" raising rates to manage demand from data centers.</p><h2>The Data Centre Drain</h2><p>A surprising factor in water scarcity? AI. Data centers require massive amounts of water for cooling. In 2025, tech giants applied for gigalitres of potable water in Melbourne alone—equivalent to the usage of 330,000 residents. This corporate demand puts upward pressure on residential pricing.</p><h2>Saving Water (and Money)</h2><p>Unlike electricity, you can't switch water providers. Your only lever is usage.</p><ul><li><strong>Check for Leaks:</strong> A dripping tap can waste 10,000L a year. Read your meter before bed and when you wake up. If it moved, you have a leak.</li><li><strong>WELS Ratings:</strong> Replace that old showerhead. A 3-star WELS showerhead uses 9L/min vs 20L/min for an old one.</li><li><strong>Rainwater Tanks:</strong> Rebates are back in some council areas for tank installation. Use it for the garden and toilet.</li></ul>",
        "slug": "sydney-water-bills-up-50-percent"
    },
    {
        "id": "b27",
        "title": "Apartment Solar: Breaking the Strata Lock",
        "category": "Solar",
        "author": "Emma Wilson",
        "date": "Apr 15, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?auto=format&fit=crop&w=400&q=80",
        "summary": "Living in an apartment used to mean missing out on solar savings. In 2026, 'Solar Banks' and energy sharing technology are changing the game.",
        "content": "<p class=\"intro-text\">For decades, 30% of Australians living in apartments were locked out of the solar revolution. Roof space was \"common property\", and splitting the energy bill was a logistical nightmare. Enter the \"Solar Bank\" and Allume technology.</p><h2>How It Works</h2><p>New hardware, like the Allume SolShare, allows a single rooftop solar system to split power dynamically between multiple apartments. It monitors who is using power and directs the solar energy to them in real-time. No more dedicated panels for specific units.</p><h2>Government Rebates for Strata</h2><p>The Federal \"Solar Banks\" initiative is now in full swing, offering rebates of up to 50% for strata bodies to install shared solar and batteries. If you are on a strata committee, this is your golden ticket to lower levies and happier tenants.</p><h2>The Rental Benefit</h2><p>Even renters are benefiting. Landlords can install these systems and offer \"solar included\" leases, charging a premium that is still cheaper than a standard grid electricity bill. It is a rare win-win in the property market.</p>",
        "slug": "apartment-solar-breaking-strata-lock"
    },
    {
        "id": "b28",
        "title": "The End of 3G: Is Your Medical Alarm Safe?",
        "category": "Mobile",
        "author": "Mike Chen",
        "date": "Apr 20, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=400&q=80",
        "summary": "The 3G network shutdown is complete, but thousands of devices are still offline. Check your medical alarms, EFTPOS machines, and farm sensors now.",
        "content": "<p class=\"intro-text\">The 3G network is officially dead in Australia. Telstra and Optus have switched off the towers to repurpose spectrum for 5G. While most phones transitioned fine, a silent crisis is unfolding for IoT (Internet of Things) devices.</p><h2>The Forgotten Devices</h2><p>It is not just about old Nokias. Thousands of critical devices relied on 3G:</p><ul><li><strong>Medical Alarms:</strong> Many personal emergency alarms used 3G sims. If you haven't upgraded yours, it may not connect to 000.</li><li><strong>Smart Meters:</strong> older electricity meters used 3G modems to send data. If they go offline, you will receive \"estimated bills\" which are notoriously inaccurate.</li><li><strong>Farm Tech:</strong> Remote water gate sensors and trackers often used cheap 3G chips.</li></ul><h2>What To Do</h2><p>Check your device model immediately. If it is more than 4 years old, contact the manufacturer. For mobile phones, ensure VoLTE (Voice over LTE) is enabled in your settings, otherwise, you won't be able to make calls even if you have 4G data.</p>",
        "slug": "end-of-3g-medical-alarm-safe"
    },
    {
        "id": "b29",
        "title": "Virtual Power Plants: Selling Your Battery to the Grid",
        "category": "Solar & Batteries",
        "author": "Dr. Alan Grant",
        "date": "May 01, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=400&q=80",
        "summary": "Join a VPP and earn up to \$400/year just for letting the grid borrow your battery during heatwaves. Is the loss of control worth the cash?",
        "content": "<p class=\"intro-text\">A Virtual Power Plant (VPP) links thousands of home batteries together to form a giant, distributed power station. When the grid is under stress (like a 40-degree day in February), the VPP operator discharges a small amount from everyone's battery to stabilize the network.</p><h2>The Economics</h2><p>In exchange for joining, you typically get:<br>1. An upfront discount on the battery (up to \$2,000).<br>2. Monthly bill credits or high feed-in tariffs.</p><p>In 2026, VPP offers from Origin (Loop) and AGL represent the best value for battery owners. Some users are reporting earning \$400-\$600 a year in credits.</p><h2>The Downside?</h2><p>You lose some autonomy. The retailer controls your battery. They might drain it to support the grid right before a blackout (though most guarantee a minimum 20% reserve). It is a trade-off: lower bills vs. absolute energy independence.</p>",
        "slug": "virtual-power-plants-selling-battery"
    },
    {
        "id": "b30",
        "title": "Gas Disconnection: The Victorian Trend Spreading North",
        "category": "Energy",
        "author": "David Ross",
        "date": "May 12, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=400&q=80",
        "summary": "Victoria banned gas in new homes. Now, ACT and NSW residents are voluntarily disconnecting to save on the 'Daily Supply Charge'.",
        "content": "<p class=\"intro-text\">The flame is going out for residential gas. Following Victoria's ban on gas connections in new homes, thousands of existing homeowners are voluntarily cutting the pipe. Why? The economics of the \"Daily Supply Charge\".</p><h2>The \$400/Year Fee for Nothing</h2><p>Even if you don't use a single mega-joule of gas, you pay a supply charge of roughly 90c to \$1.10 a day. That is nearly \$400 a year just for the privilege of being connected. By switching your hot water to a Heat Pump and your stove to Induction, you can abolish this bill entirely.</p><h2>The \"Abolishment\" Cost</h2><p>Historically, networks charged heavily to remove the meter. In 2026, regulatory pressure has lowered these \"abolishment fees\", and in some cases (like Victoria), it is subsidized. Electrification is no longer just an environmental choice; with gas prices rising 15% this year, it is a financial survival strategy.</p>",
        "slug": "gas-disconnection-trend-spreading"
    },
    {
        "id": "b31",
        "title": "AI Customer Service: Why You Can't Call Telstra Anymore",
        "category": "Mobile",
        "author": "Sarah Jenkins",
        "date": "Jun 01, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1531746790731-6c087fecd65a?auto=format&fit=crop&w=800&q=80",
        "summary": "Telecommunication companies are pivoting to 'AI-First' support. What does this mean for resolving your billing disputes in 2026?",
        "content": "<p class=\"intro-text\">Try calling your ISP today. Chances are, you won't speak to a human. 2026 has seen the mass deployment of Generative AI customer service agents by major telcos. These aren't the clunky chatbots of 2023—they can process refunds, reset ports, and schedule technicians.</p><h2>The Pros and Cons</h2><p><strong>Pros:</strong> Zero wait times. AI agents are available 24/7. Simple tasks like \"Change my plan\" or \"Pay my bill\" are instant.</p><p><strong>Cons:</strong> Complex issues fall into the void. If your NBN drop-out is intermittent or weather-dependent, AI struggles to diagnose it. The \"escalate to human\" button is becoming harder to find, hidden behind layers of digital triage.</p><h2>How to Game the System</h2><p>If you need a human, use keywords like \"Complaint\", \"TIO\", or \"Ombudsman\". These trigger words often bypass the AI's containment logic and route you to a specialized (human) team.</p>",
        "slug": "ai-customer-service-telco-trends"
    },
    {
        "id": "b32",
        "title": "Green Loans: The Cheapest Money in Australia",
        "category": "Financial",
        "author": "David Ross",
        "date": "Jun 15, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=400&q=80",
        "summary": "Banks are offering 0.99% interest loans for energy upgrades. Here is how to use them for solar, batteries, and double glazing.",
        "content": "<p class=\"intro-text\">Interest rates for mortgages are stabilizing around 5-6%, but there is a secret tier of lending available at under 1%. \"Green Loans\" are the banking sector's push to decarbonize their mortgage books.</p><h2>Who is Offering What?</h2><ul><li><strong>CommBank:</strong> Green Home Offer.</li><li><strong>Brighte:</strong> 0% interest payment plans for solar.</li><li><strong>Clean Energy Finance Corp (CEFC):</strong> Backing low-rate loans via smaller lenders.</li></ul><h2>What Can You Buy?</h2><p>It is not just solar panels. These loans cover:<br>- Double glazed windows<br>- Insulation upgrades<br>- Heat Pump hot water systems<br>- EV Chargers</p><p>If you are planning a renovation in 2026, using a Green Loan instead of a redraw facility could save you thousands in interest repayments.</p>",
        "slug": "green-loans-cheapest-money-australia"
    },
    {
        "id": "b33",
        "title": "Community Batteries: The 'Street Storage' Solution",
        "category": "Energy",
        "author": "Dr. Alan Grant",
        "date": "Jul 01, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1617791160505-6f00504e3519?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1617791160505-6f00504e3519?auto=format&fit=crop&w=400&q=80",
        "summary": "Can't afford a Tesla Powerwall? You might be able to rent space in a 'Community Battery' installed on your street corner.",
        "content": "<p class=\"intro-text\">Not everyone has \$12,000 for a home battery. Enter the \"Community Battery\"—a refrigerator-sized storage unit installed on the nature strip that serves 50-100 homes. It's the Airbnb of energy storage.</p><h2>How It Works</h2><p>During the day, your excess solar flows into the community battery (instead of the grid). At night, you draw that power back for free (or a very low fee). You pay a small \"subscription\" to participate, often around \$15/month.</p><h2>Why It's Trending</h2><p>The federal government's \"Community Batteries for Household Solar\" program has rolled out 400 of these across Australia in 2025-2026. It solves the voltage issues in the grid caused by too much solar export and gives renters/apartment owners a way to participate in the storage game.</p>",
        "slug": "community-batteries-street-storage"
    },
    {
        "id": "b34",
        "title": "The 'Sun Tax': Why You Might Pay to Export Solar",
        "category": "Solar",
        "author": "Emma Wilson",
        "date": "Jul 12, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1509391364309-38f7f32d278a?auto=format&fit=crop&w=800&q=80",
        "thumbnailUrl": "https://images.unsplash.com/photo-1509391364309-38f7f32d278a?auto=format&fit=crop&w=400&q=80",
        "summary": "The controversial 'Two-Way Pricing' rule is live. Exporting solar at noon might cost you money, but exporting at 5 PM pays big.",
        "content": "<p class=\"intro-text\">The \"Sun Tax\" is here, but it's not as scary as the headlines suggest. Officially known as \"Two-Way Pricing,\" this AER rule allows networks to charge solar owners a small fee (approx 1-2c/kWh) for exporting energy during \"solar traffic jams\" (typically 10 AM - 2 PM).</p><h2>The Flip Side: Reward Pricing</h2><p>To balance this, networks now pay a <em>premium</em> rebate for exporting solar during the evening peak (4 PM - 8 PM). If you have a battery (or an EV with V2G), you can discharge during this window and earn 30-40c/kWh.</p><h2>Adapt or Pay</h2><p>For most households without batteries, the cost is negligible (estimated \$20/year). But it signals a shift: the grid wants your power in the evening, not at lunch. Orienting new panels West instead of North is now a smart strategy to catch that afternoon sun and avoid the tax.</p>",
        "slug": "sun-tax-two-way-pricing-explained"
    },
    {
        "id": "b35",
        "title": "Demand Response: Get Paid to Turn Off the AC",
        "category": "Energy",
        "author": "Mike Chen",
        "date": "Jul 20, 2026",
        "imageUrl": "https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&w=800&q=80",
        "summary": "Programs like 'Peak Smart' are paying households to reduce usage during grid emergencies. It is the easiest money you will make this summer.",
        "content": "<p class=\"intro-text\">Imagine getting a text message: \"Turn down your AC for 2 hours tonight and we'll give you \$20.\" This is Demand Response, and in 2026, it has gone mainstream.</p><h2>The Grid Emergency</h2><p>On super-hot days, the grid struggles to cope. Instead of building expensive new power plants that run for 10 hours a year, operators prefer to pay you to use less.</p><h2>How to Participate</h2><p>Retailers like Origin (Spike) and AGL (Peak Energy Rewards) gamify this. You earn points or cash for beating your baseline usage. Smart thermostats and plugs can even automate this—turning off the pool pump or dimming the lights automatically when a \"Demand Event\" is triggered.</p><p>It is free money for flexible households, and it helps prevent blackouts.</p>",
        "slug": "demand-response-paid-to-turn-off"
    }
  ];

  // Append new posts to existing ones, checking for duplicates by ID
  for (var newPost in newPosts) {
    bool exists = false;
    for (var existingPost in posts) {
      if (existingPost['id'] == newPost['id']) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      posts.add(newPost);
    }
  }

  // Write back to file
  final encoded = jsonEncode(posts);
  await file.writeAsString(encoded);
  print('Updated blog_posts.json with ${posts.length} articles.');
}
