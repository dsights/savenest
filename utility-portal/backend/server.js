require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const db = require('./database');
const { startCronJob } = require('./scheduler');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;

// ----- AUTHENTICATION -----
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  
  if (username === process.env.ADMIN_USERNAME && password === process.env.ADMIN_PASSWORD) {
    const token = jwt.sign({ role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Middleware to protect routes
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      console.error("JWT Error:", err, "Token:", token);
      return res.sendStatus(403);
    }
    req.user = user;
    next();
  });
};

// Protect all routes below this line
app.use('/api', authenticateToken);

// Verify Password Route (for sensitive actions like delete)
app.post('/api/verify-password', (req, res) => {
  const { password } = req.body;
  if (password === process.env.ADMIN_PASSWORD) {
    res.json({ success: true });
  } else {
    res.status(401).json({ error: 'Incorrect password' });
  }
});

// ----- API ROUTES ----- 

// Get all customers
app.get('/api/customers', (req, res) => {
  db.all("SELECT * FROM customers", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Delete a customer
app.delete('/api/customers/:id', (req, res) => {
  const id = req.params.id;
  db.run("DELETE FROM customers WHERE id = ?", [id], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "Deleted", changes: this.changes });
  });
});

// Add a new customer
app.post('/api/customers', (req, res) => {
  const { name, email, phone, house_no, street, suburb, state, post_code } = req.body;
  if (!name || !email) return res.status(400).json({ error: "Name and email are required" });

  // Generate a random 6-character alphanumeric code for uniqueness
  const randomStr = Math.random().toString(36).substring(2, 8).toUpperCase();
  const customer_code = `CUS-${randomStr}`;

  db.run(`INSERT INTO customers (customer_code, name, email, phone, house_no, street, suburb, state, post_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`, [customer_code, name, email, phone, house_no, street, suburb, state, post_code], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: this.lastID, customer_code, name, email, phone, house_no, street, suburb, state, post_code });
  });
});

// Update a customer
app.put('/api/customers/:id', (req, res) => {
  const id = req.params.id;
  const { name, email, phone, house_no, street, suburb, state, post_code } = req.body;
  if (!name || !email) return res.status(400).json({ error: "Name and email are required" });

  db.run(`UPDATE customers SET name = ?, email = ?, phone = ?, house_no = ?, street = ?, suburb = ?, state = ?, post_code = ? WHERE id = ?`, [name, email, phone, house_no, street, suburb, state, post_code, id], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id, name, email, phone, house_no, street, suburb, state, post_code });
  });
});

// Get all products (groups can be built on frontend, or we can just send the list)
app.get('/api/products', (req, res) => {
  db.all("SELECT * FROM products ORDER BY category, provider_name", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Create a switch request
app.post('/api/switches', (req, res) => {
  const { customer_id, product_id, switch_date, billing_date } = req.body;
  if (!customer_id || !product_id || !switch_date) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  
  const final_billing_date = billing_date || switch_date;

  db.run(`INSERT INTO switch_requests (customer_id, product_id, switch_date, billing_date, status) VALUES (?, ?, ?, ?, 'PENDING')`,
    [customer_id, product_id, switch_date, final_billing_date], function(err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID, status: 'PENDING' });
    }
  );
});

// Get pending switch requests (Dashboard Data)
app.get('/api/switches/pending', (req, res) => {
  const query = `
    SELECT sr.id, sr.switch_date, sr.billing_date, sr.status, 
           c.name as customer_name, c.email as customer_email,
           p.category, p.sub_category, p.provider_name, p.plan_name, p.price, p.price_unit
    FROM switch_requests sr
    JOIN customers c ON sr.customer_id = c.id
    JOIN products p ON sr.product_id = p.id
    WHERE sr.status = 'PENDING'
    ORDER BY sr.switch_date ASC
  `;
  db.all(query, [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Start scheduler
startCronJob();

// Delete a switch request
app.delete('/api/switches/:id', (req, res) => {
  const id = req.params.id;
  db.run("DELETE FROM switch_requests WHERE id = ?", [id], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "Deleted", changes: this.changes });
  });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
