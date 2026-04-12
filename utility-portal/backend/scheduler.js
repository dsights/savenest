const cron = require('node-cron');
const db = require('./database');
const dayjs = require('dayjs'); // Optional date library for simpler date comparisons

function startCronJob() {
  console.log('Starting scheduler...');

  // This cron job runs every day at 1:00 AM ('0 1 * * *')
  // For testing purposes, we can run it every minute: '* * * * *'
  cron.schedule('0 1 * * *', () => {
    console.log(`[Scheduler] Running daily check for switches due today at ${new Date().toISOString()}`);
    processDueSwitches();
  });

  // Adding a test endpoint/manual trigger logic just for development/demo ease
  // Uncomment the line below to test it every minute
  cron.schedule('* * * * *', () => {
    console.log(`[Testing Scheduler] Checking switches every minute for demo... `);
    processDueSwitches();
  });
}

function processDueSwitches() {
  // We want to find PENDING switches where switch_date is today or earlier (in case it failed yesterday)
  const today = dayjs().format('YYYY-MM-DD');

  const query = `
    SELECT sr.id, sr.switch_date,
           c.name as customer_name, c.email as customer_email,
           p.provider_name, p.plan_name
    FROM switch_requests sr
    JOIN customers c ON sr.customer_id = c.id
    JOIN products p ON sr.product_id = p.id
    WHERE sr.status = 'PENDING' AND sr.switch_date <= ?
  `;

  db.all(query, [today], (err, rows) => {
    if (err) {
      console.error('[Scheduler Error] Database fetch failed:', err);
      return;
    }

    if (rows.length === 0) {
      console.log(`[Scheduler] No switches due on or before ${today}.`);
      return;
    }

    console.log(`[Scheduler] Found ${rows.length} switch request(s) due today. Processing...`);

    rows.forEach((req) => {
      // Simulate API call to Utility Provider
      console.log(`[Processing] Switching ${req.customer_name} (${req.customer_email}) to ${req.provider_name} (${req.plan_name})...`);

      // Mark as completed
      db.run("UPDATE switch_requests SET status = 'COMPLETED' WHERE id = ?", [req.id], function(updateErr) {
        if (updateErr) {
          console.error(`[Error] Failed to update request ${req.id}:`, updateErr);
        } else {
          console.log(`[Success] Switch Request ${req.id} completed.`);
        }
      });
    });
  });
}

module.exports = { startCronJob };
