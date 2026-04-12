import React, { useState, useEffect } from 'react';
import { Typography, Paper, Box, Button, TextField, Grid, MenuItem, Alert } from '@mui/material';
import api from '../api';
import dayjs from 'dayjs';
import { useNavigate } from 'react-router-dom';

function CreateSwitch() {
  const [customers, setCustomers] = useState([]);
  const [products, setProducts] = useState([]);

  const [selectedCustomerId, setSelectedCustomerId] = useState('');
  
  // Cascading Selection States
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedSubCategory, setSelectedSubCategory] = useState('');
  const [selectedProvider, setSelectedProvider] = useState('');
  const [selectedProductId, setSelectedProductId] = useState('');
  
  // Date states
  const [billingDate, setBillingDate] = useState(dayjs().format('YYYY-MM-DD'));
  const [switchDate, setSwitchDate] = useState(dayjs().format('YYYY-MM-DD'));
  const [manualSwitchDate, setManualSwitchDate] = useState(false);

  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const navigate = useNavigate();

  const handleBillingDateChange = (e) => {
    const newDate = e.target.value;
    setBillingDate(newDate);
    // Automatically sync switch date with billing date unless manually overridden
    if (!manualSwitchDate) {
      setSwitchDate(newDate);
    }
  };

  const handleSwitchDateChange = (e) => {
    setSwitchDate(e.target.value);
    setManualSwitchDate(true);
  };

  useEffect(() => {
    fetchData();
  }, []);

  // Reset dependent fields when higher-level field changes
  useEffect(() => {
    setSelectedSubCategory('');
    setSelectedProvider('');
    setSelectedProductId('');
  }, [selectedCategory]);

  useEffect(() => {
    setSelectedProvider('');
    setSelectedProductId('');
  }, [selectedSubCategory]);

  useEffect(() => {
    setSelectedProductId('');
  }, [selectedProvider]);

  const fetchData = async () => {
    try {
      const [custRes, prodRes] = await Promise.all([
        api.get('/customers'),
        api.get('/products')
      ]);
      setCustomers(custRes.data);
      setProducts(prodRes.data);
    } catch (error) {
      console.error('Failed to fetch initial data', error);
      setErrorMsg('Failed to load initial data from server.');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setSuccessMsg('');

    try {
      await api.post('/switches', {
        customer_id: selectedCustomerId,
        product_id: selectedProductId,
        switch_date: switchDate,
        billing_date: billingDate
      });
      setSuccessMsg('Plan purchase recorded and switch scheduled!');
      
      setTimeout(() => {
        navigate('/');
      }, 2000);

    } catch (error) {
      console.error('Failed to schedule switch', error);
      setErrorMsg('Failed to schedule the switch.');
    }
  };

  // Derive unique categories
  const categories = [...new Set(products.map(p => p.category))];
  
  // Derive sub-categories for the selected category
  const subCategories = selectedCategory 
    ? [...new Set(products.filter(p => p.category === selectedCategory && p.sub_category).map(p => p.sub_category))]
    : [];
  
  // Derive providers based on selected category AND selected sub-category (if any)
  const providers = selectedCategory 
    ? [...new Set(products
        .filter(p => p.category === selectedCategory && (!subCategories.length || p.sub_category === selectedSubCategory))
        .map(p => p.provider_name)
      )] 
    : [];

  // Derive available plans based on selected category, sub-category AND provider
  const availablePlans = (selectedCategory && selectedProvider)
    ? products.filter(p => 
        p.category === selectedCategory && 
        (!subCategories.length || p.sub_category === selectedSubCategory) &&
        p.provider_name === selectedProvider
      )
    : [];

  const selectedCustomer = customers.find(c => c.id === selectedCustomerId);

  return (
    <Box>
      <Typography variant='h4' gutterBottom>
        Record Plan Purchase
      </Typography>
      <Typography variant='subtitle1' gutterBottom color='textSecondary'>
        Assign a master product to a customer to schedule their auto-switch.
      </Typography>

      <Paper sx={{ p: 4, mt: 3, maxWidth: 1200, width: '100%' }}>
        {successMsg && <Alert severity='success' sx={{ mb: 2 }}>{successMsg}</Alert>}
        {errorMsg && <Alert severity='error' sx={{ mb: 2 }}>{errorMsg}</Alert>}

        <form onSubmit={handleSubmit}>
          <Grid container spacing={4}>
            {/* Customer Dropdown */}
            <Grid item xs={12}>
              <TextField
                select
                required
                fullWidth
                label='Customer'
                variant='outlined'
                value={selectedCustomerId}
                onChange={(e) => setSelectedCustomerId(e.target.value)}
                sx={{ minWidth: 500 }}
              >
                {customers.map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    <Box sx={{ display: 'flex', flexDirection: 'column' }}>
                      <Typography variant='body1' sx={{ fontWeight: 'bold' }}>{c.name}</Typography>
                      <Typography variant='caption' sx={{ color: 'text.secondary' }}>
                        {c.email} {c.post_code ? ' | Post Code: ' + c.post_code : ''}
                      </Typography>
                    </Box>
                  </MenuItem>
                ))}
              </TextField>
              {selectedCustomer && selectedCustomer.address && (
                <Typography variant='caption' sx={{ mt: 1, display: 'block', color: 'primary.main' }}>
                  Selected Address: {selectedCustomer.address}, {selectedCustomer.post_code}
                </Typography>
              )}
            </Grid>

            {/* Cascading Product Selection: Category -> Sub-Category (Optional) -> Provider -> Plan */}
            <Grid item xs={12} md={subCategories.length > 0 ? 3 : 4}>
              <TextField
                select
                required
                fullWidth
                label='1. Select Category'
                variant='outlined'
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                sx={{ minWidth: 200 }}
              >
                {categories.map((cat) => (
                  <MenuItem key={cat} value={cat} sx={{ textTransform: 'capitalize' }}>
                    {cat}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>

            {subCategories.length > 0 && (
              <Grid item xs={12} md={3}>
                <TextField
                  select
                  required
                  fullWidth
                  label='1.5. Sub Category'
                  variant='outlined'
                  value={selectedSubCategory}
                  onChange={(e) => setSelectedSubCategory(e.target.value)}
                  sx={{ minWidth: 200 }}
                >
                  {subCategories.map((sub) => (
                    <MenuItem key={sub} value={sub}>
                      {sub}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>
            )}

            <Grid item xs={12} md={subCategories.length > 0 ? 3 : 4}>
              <TextField
                select
                required
                fullWidth
                label='2. Select Provider'
                variant='outlined'
                value={selectedProvider}
                onChange={(e) => setSelectedProvider(e.target.value)}
                disabled={!selectedCategory || (subCategories.length > 0 && !selectedSubCategory)}
                sx={{ minWidth: 200 }}
              >
                {providers.map((prov) => (
                  <MenuItem key={prov} value={prov}>
                    {prov}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>

            <Grid item xs={12} md={subCategories.length > 0 ? 3 : 4}>
              <TextField
                select
                required
                fullWidth
                label='3. Select Specific Plan'
                variant='outlined'
                value={selectedProductId}
                onChange={(e) => setSelectedProductId(e.target.value)}
                disabled={!selectedProvider}
                sx={{ minWidth: 200 }}
              >
                {availablePlans.map((plan) => (
                  <MenuItem key={plan.id} value={plan.id}>
                    {plan.plan_name} - {plan.price}{plan.price_unit}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>

            {/* Date Selection */}
            <Grid item xs={12} md={6}>
              <TextField
                required
                fullWidth
                type='date'
                label='Billing Date (Next Bill)'
                variant='outlined'
                value={billingDate}
                onChange={handleBillingDateChange}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <TextField
                required
                fullWidth
                type='date'
                label='Switch Date'
                variant='outlined'
                value={switchDate}
                onChange={handleSwitchDateChange}
                InputLabelProps={{ shrink: true }}
                helperText='Date the new provider will take over. Usually same as billing date.'
              />
            </Grid>

            <Grid item xs={12}>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
                <Button variant='outlined' onClick={() => navigate('/')}>Cancel</Button>
                <Button 
                  type='submit' 
                  variant='contained' 
                  color='primary' 
                  size='large'
                  disabled={!selectedCustomerId || !selectedProductId}
                >
                  Schedule Auto-Switch
                </Button>
              </Box>
            </Grid>
          </Grid>
        </form>
      </Paper>
    </Box>
  );
}

export default CreateSwitch;
