import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'blog_model.dart';

class BlogRepository {
  Future<List<BlogPost>> getPosts() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final jsonString = await rootBundle.loadString('assets/data/blog_posts.json');
      final List<dynamic> rawList = json.decode(jsonString);
      
      return rawList.map((j) => BlogPost.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error loading blog posts: $e. Using fallback data.');
      // Fallback data so the UI doesn't break
      return [
        BlogPost(
          id: 'b1',
          slug: 'slash-your-electricity-bill-the-vampire-power-myth',
          title: 'Slash Your Electricity Bill: The Vampire Power Myth',
          category: 'Energy',
          author: 'Sarah Jenkins',
          date: 'Jan 15, 2026',
          imageUrl: 'assets/images/energy.png',
          thumbnailUrl: 'assets/images/energy.png',
          summary: "Are you paying for electricity you aren't even using? It sounds like a conspiracy theory, but for most Australian households, 'Vampire Power' is a real financial drain.",
          content: r'''Are you paying for electricity you aren't even using? It sounds like a conspiracy theory, but for most Australian households, 'Vampire Power' (also known as standby power) is a very real drain on your finances.

Vampire power refers to the electricity consumed by appliances when they are switched off or in standby mode. While a single television in standby might only cost a few dollars a year, the cumulative effect of a modern home is staggering. Game consoles, microwaves, smart speakers, washing machines, and even your phone charger are constantly sipping energy.

Recent studies suggest that standby power can account for up to 10% of a household's total electricity usage. If your quarterly bill is $500, that is $200 a year wasted on appliances doing absolutely nothing.

So, how do you stop it?

1. The Smart Power Board: This is your best weapon. These boards detect when your main device (like a TV) is turned off and automatically cut power to the peripherals (soundbar, game console, subwoofer).

2. The 'Off' Habit: It sounds simple, but switching off the microwave and washing machine at the wall can save $20-$30 a year alone.

3. Audit Your Old Tech: That old plasma TV in the spare room or the beer fridge in the garage? They are energy guzzlers. If you aren't using them daily, unplug them.

By attacking vampire power, you are essentially giving yourself a 10% discount on electricity before you even compare providers. Combine this with a better market rate from SaveNest, and your savings will skyrocket.''',
        ),
        BlogPost(
          id: 'b2',
          slug: 'is-your-nbn-plan-too-fast-the-speed-trap',
          title: 'Is Your NBN Plan Too Fast? The Speed Trap',
          category: 'Internet',
          author: 'Mike Chen',
          date: 'Jan 12, 2026',
          imageUrl: 'assets/images/internet.png',
          thumbnailUrl: 'assets/images/internet.png',
          summary: "We all want the fastest internet possible, but are you paying a premium for speed you literally cannot use?",
          content: r'''We all want the fastest internet possible, but are you paying a premium for speed you literally cannot use? Many Australians are subscribed to NBN 100 (Fast) or NBN 250 (Superfast) plans, assuming they need it for streaming and working from home. The reality is often quite different.

Let's look at the numbers. Streaming a movie in 4K Ultra HD on Netflix requires a stable connection of about 25 Mbps. A high-quality Zoom call requires roughly 3-4 Mbps. Even online gaming relies more on latency (ping) than raw download speed.

This means that a standard NBN 50 plan is more than enough to handle two people streaming 4K content while a third person is on a video call—simultaneously.

If you are a household of two or three people paying $110/month for an NBN 100 plan, you are likely wasting $20 to $30 every month. That is over $300 a year spent on 'headroom' that your devices never utilize.

The Speed Trap:
ISPs love to upsell you on speed tiers because it is pure profit for them. They market 'Gigabit speed' as a necessity for the modern home. But unless you are regularly downloading massive files (like 100GB video games or 4K video editing projects), that gigabit speed sits idle 99% of the time.

The Solution:
Try downgrading. Switch to a high-quality NBN 50 plan for a month. If you don't notice a difference (and you likely won't), you have just pocketed an easy $300 a year. If you do notice a slowdown, you can upgrade back instantly.''',
        ),
        BlogPost(
          id: 'b3',
          slug: 'prepaid-vs-postpaid-the-mobile-data-trap',
          title: 'Prepaid vs Postpaid: The Mobile Data Trap',
          category: 'Mobile',
          author: 'Emma Wilson',
          date: 'Jan 10, 2026',
          imageUrl: 'assets/images/mobile.png',
          thumbnailUrl: 'assets/images/mobile.png',
          summary: "For years, the standard way to own a mobile phone was the 24-month contract. But as hardware improvements plateau, the contract model has become a financial trap.",
          content: r'''For years, the standard way to own a mobile phone in Australia was the 24-month contract. You got a 'free' phone, a set amount of data, and a hefty monthly bill. But as phone hardware improvements plateau and SIM-only plans become aggressive, the contract model has become a financial trap.

The 'Loyalty Tax' in the mobile market is severe. Major telcos bank on you setting up a direct debit and forgetting about it. Meanwhile, smaller providers (MVNOs) who rent the exact same network towers are offering double the data for half the price.

Here is the math:
A typical major telco postpaid plan might be $69/month for 80GB of data. Over a year, that is $828.
A competitor using the same network might offer a '365-day Long Expiry' prepaid plan: 140GB for $200.

By switching to the prepaid annual model, you save $628 a year. Even if you need to buy a brand new mid-range phone outright for $500, you are still ahead financially after just one year.

Why Prepaid Wins:
1. No Bill Shock: You cannot accidentally spend $500 on excess data or premium calls. When your credit is done, it's done.
2. Data Banking: Many prepaid plans let you keep unused data indefinitely.
3. Flexibility: You are never locked in. If a better deal pops up next month, you can switch instantly.

Stop renting your usage. Own your plan and pocket the difference.''',
        ),
        BlogPost(
          id: 'b4',
          slug: 'home-insurance-the-set-and-forget-mistake',
          title: 'Home Insurance: The \'Set and Forget\' Mistake',
          category: 'Insurance',
          author: 'David Ross',
          date: 'Jan 05, 2026',
          imageUrl: 'assets/images/home_ins.png',
          thumbnailUrl: 'assets/images/home_ins.png',
          summary: "Home and Contents insurance is the classic 'grudge purchase.' We buy it because we have to, but this 'set and forget' mentality is leaving thousands underinsured.",
          content: r'''Home and Contents insurance is the classic 'grudge purchase.' We buy it because we have to, and we rarely look at it again until something goes wrong or the renewal notice arrives. But this 'set and forget' mentality is leaving thousands of Australians underinsured and overcharged.

The Inflation Problem:
Building costs in Australia have skyrocketed by over 20% in the last few years. If you set your 'Sum Insured' (the amount you are covered for) back in 2021 and haven't updated it, you are likely underinsured. If your home burns down today, your payout might only cover 80% of the rebuild cost, leaving you hundreds of thousands of dollars out of pocket.

The Lazy Tax:
Insurers rely on inertia. They know that 80% of customers will simply auto-renew even if the premium jumps by 15%. They reserve their best 'new customer' rates for people who switch.

The Strategy:
1. Review your Sum Insured immediately using an online calculator. Ensure it reflects 2026 building prices.
2. Get three quotes. It takes less than 10 minutes on SaveNest to compare policies.
3. Call your current insurer. Before you switch, give them a chance. Say, 'I have a quote for the same cover that is $300 cheaper. Can you match it?'
4. If they say no, switch. Loyalty in insurance does not pay; it costs.''',
        ),
        BlogPost(
          id: 'b5',
          slug: 'car-insurance-loyalty-tax-switch-every-year',
          title: 'Car Insurance Loyalty Tax: Switch Every Year',
          category: 'Car Insurance',
          author: 'Sarah Jenkins',
          date: 'Jan 02, 2026',
          imageUrl: 'assets/images/car_ins.png',
          thumbnailUrl: 'assets/images/car_ins.png',
          summary: "Car insurance is perhaps the most volatile expense in the household budget. Unlike registration, your premium is calculated by an algorithm testing your willingness to pay.",
          content: r'''Car insurance is perhaps the most volatile expense in the household budget. Unlike your car registration which is a fixed fee, your insurance premium is calculated by an algorithm that tries to guess how much you are willing to pay.

The 'New Customer' Bonus:
Insurers spend millions on advertising to acquire new customers. To get you in the door, they often offer an artificially low premium for the first year. They might even make a loss on you initially.

The 'Renewal' Hike:
Once you are a customer, the algorithm changes. It knows you are already signed up. Next year, your renewal notice arrives, and the price has jumped by $200. Have you become a worse driver? No. The insurer is simply testing your price elasticity. They are betting you are too busy to switch.

How to Win:
You must treat car insurance as a 12-month product. Never auto-renew without checking the market.
1. Set a calendar reminder for 25 days before your policy expires.
2. Run a comparison. You will almost certainly find a 'new customer' offer from a competitor that beats your renewal price.
3. Switch.

By switching every year, you effectively surf the 'new customer' bonuses of different insurers, ensuring you never pay the loyalty tax. It is the single highest 'hourly wage' task you can do—saving $500 for 15 minutes of work.''',
        ),
      ];
    }
  }
}

final blogRepositoryProvider = Provider<BlogRepository>((ref) => BlogRepository());

final blogPostsProvider = FutureProvider<List<BlogPost>>((ref) async {
  return ref.read(blogRepositoryProvider).getPosts();
});
