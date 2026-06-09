print(f"📅 Day {day_data['day']}/30: {day_data['title']} (Status: {day_data['status']})")
print(f"💰 Pure Profit: ${target_plan.get('current_revenue', 0):,.2f} / ${target_plan.get('target_revenue_mrr', 10000):,.0f}")

metrics = target_plan.get('metrics', {})
print(f"🤝 JV Partners: {metrics.get('jv_partners_signed', 0)} / {metrics.get('target_jv_partners', 15)}")
