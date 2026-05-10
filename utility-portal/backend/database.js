const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'utility-switcher.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error connecting to database', err);
  } else {
    console.log('Connected to SQLite database.');
    initDb();
  }
});

function initDb() {
  db.serialize(() => {
    // Customers Table
    db.run(`CREATE TABLE IF NOT EXISTS customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_code TEXT UNIQUE,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      phone TEXT,
      house_no TEXT,
      street TEXT,
      suburb TEXT,
      state TEXT,
      address TEXT,
      post_code TEXT
    )`);

    // Master Products Table (to be updated daily from CSV)
    db.run(`CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      category TEXT NOT NULL,
      sub_category TEXT,
      provider_name TEXT NOT NULL,
      plan_name TEXT NOT NULL,
      price REAL,
      price_unit TEXT,
      description TEXT,
      key_features TEXT
    )`);

    // SwitchRequests Table (Maps Customer directly to a Product)
    db.run(`CREATE TABLE IF NOT EXISTS switch_requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER,
      product_id TEXT,
      switch_date TEXT NOT NULL,
      billing_date TEXT,
      status TEXT DEFAULT 'PENDING',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(customer_id) REFERENCES customers(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    )`);

    console.log('Database tables verified/created.');
    seedData();
  });
}

// Function to add a test customer
function seedData() {
  db.get("SELECT COUNT(*) AS count FROM customers", (err, row) => {
    if (row && row.count === 0) {
      db.run(`INSERT INTO customers (name, email, phone) VALUES ('John Doe', 'john@example.com', '555-0100')`);
      console.log('Database seeded with test customer.');
    }
  });
}

module.exports = db;