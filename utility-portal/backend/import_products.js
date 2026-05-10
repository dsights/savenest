const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const db = require('./database');

const CSV_PATH = path.resolve(__dirname, '../../products_template.csv');

function importProducts() {
  console.log(`Starting import from: ${CSV_PATH}`);
  
  const results = [];
  
  fs.createReadStream(CSV_PATH)
    .pipe(csv())
    .on('data', (data) => results.push(data))
    .on('end', () => {
      let updatedCount = 0;
      
      db.serialize(() => {
        const stmt = db.prepare(`
          INSERT INTO products (id, category, sub_category, provider_name, plan_name, price, price_unit, description, key_features)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            category=excluded.category,
            sub_category=excluded.sub_category,
            provider_name=excluded.provider_name,
            plan_name=excluded.plan_name,
            price=excluded.price,
            price_unit=excluded.price_unit,
            description=excluded.description,
            key_features=excluded.key_features
        `);

        results.forEach((row) => {
          // New Standardized Headers
          const id = row.id;
          const category = row.category;
          const subCategory = row.sub_category || ''; 
          const providerName = row.provider_name;
          const planName = row.plan_name;
          const price = parseFloat(row.price) || 0;
          const priceUnit = row.price_unit;
          const description = row.description;
          const keyFeatures = row.key_features;

          if (id && providerName && planName) {
            stmt.run(
              id, 
              category,
              subCategory,
              providerName, 
              planName, 
              price, 
              priceUnit, 
              description, 
              keyFeatures
            );
            updatedCount++;
          }
        });
        
        stmt.finalize();
        console.log(`Successfully imported/updated ${updatedCount} products from the standardized daily file.`);
      });
    });
}

// Execute the import
importProducts();