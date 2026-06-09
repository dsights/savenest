target_plan = {'current_revenue': 0, 'target_revenue_mrr': 10000}
print(f"💰 Pure Profit: ${target_plan.get('current_revenue', 0):,.2f} / ${target_plan.get('target_revenue_mrr', 10000):,.0f}")
