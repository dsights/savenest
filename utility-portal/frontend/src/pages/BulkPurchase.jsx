import React, { useState, useEffect } from 'react';
import { Typography, Paper, Box, Button, TextField, Grid, MenuItem, Alert, Checkbox, FormControlLabel, Divider } from '@mui/material';
import api from '../api';
import dayjs from 'dayjs';
import { useNavigate } from 'react-router-dom';

function BulkPurchase() {
  const [customers, setCustomers] = useState([]);
  const [products, setProducts] = useState([]);

  const [selectedCustomerId, setSelectedCustomerId] = useState('');
  const [selections, setSelections] = useState({});
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [custRes, prodRes] = await Promise.all([
        api.get('/customers'),
        api.get('/products')
      ]);
      setCustomers(custRes.data);
      setProducts(prodRes.data);

      // Extract unique categories from products
      const categories = [...new Set(prodRes.data.map(p => p.category))];

      // Initialize selections state for each category
      const initialSelections = {};
      categories.forEach(category => {
        const categoryProducts = prodRes.data.filter(p => p.category === category);
        initialSelections[category] = {
          selected: false,
          subCategory: '',
          providerName: '',
          productId: categoryProducts.length > 0 ? categoryProducts[0].id : '',
          billingDate: dayjs().format('YYYY-MM-DD'),
          switchDate: dayjs().format('YYYY-MM-DD'),
          manualSwitchDate: false
        };
      });
      setSelections(initialSelections);
    } catch (error) {
      console.error('Failed to fetch data', error);
      setErrorMsg('Failed to load initial data from server.');
    }
  };

  const handleSelectionChange = (category, field, value) => {
    setSelections(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [field]: value
      }
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setSuccessMsg('');

    if (!selectedCustomerId) {
      setErrorMsg('Please select a customer.');
      return;
    }

    const selectedCategories = Object.keys(selections).filter(cat => selections[cat].selected);
    if (selectedCategories.length === 0) {
      setErrorMsg('Please tick at least one service category.');
      return;
    }

    try {
      const promises = selectedCategories.map(category => {
        const sel = selections[category];
        return api.post('/switches', {
          customer_id: selectedCustomerId,
          product_id: sel.productId,
          switch_date: sel.switchDate,
          billing_date: sel.billingDate
        });
      });

      await Promise.all(promises);
      setSuccessMsg('Bulk purchases recorded successfully!');
      setTimeout(() => {
        navigate('/');
      }, 2000);
    } catch (error) {
      console.error('Failed to record some purchases', error);
      setErrorMsg('Failed to record some or all purchases.');
    }
  };

  // Group products by category to easily populate the sub-dropdowns
  const groupedProducts = products.reduce((acc, curr) => {
    if (!acc[curr.category]) acc[curr.category] = [];
    acc[curr.category].push(curr);
    return acc;
  }, {});

  const categories = Object.keys(groupedProducts);

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Bulk Plan Entry
      </Typography>
      <Typography variant="subtitle1" gutterBottom color="textSecondary">
        Quickly select multiple products purchased by a customer across different categories.
      </Typography>

      <Paper sx={{ p: 4, mt: 3, maxWidth: 1200, width: '100%' }}>
        {successMsg && <Alert severity="success" sx={{ mb: 2 }}>{successMsg}</Alert>}
        {errorMsg && <Alert severity="error" sx={{ mb: 2 }}>{errorMsg}</Alert>}

        <form onSubmit={handleSubmit}>
          <Grid container spacing={3}>
            {/* Customer Dropdown */}
            <Grid item xs={12}>
              <TextField
                select
                required
                fullWidth
                label="Select Customer"
                variant="outlined"
                value={selectedCustomerId}
                onChange={(e) => setSelectedCustomerId(e.target.value)}
                sx={{ mb: 2, minWidth: 500 }}
              >
                {customers.map((c) => (
                  <MenuItem key={c.id} value={c.id}>
                    <Typography variant="body1" sx={{ fontWeight: 'bold' }}>{c.name}</Typography>
                    <Typography variant="body2" sx={{ ml: 1, color: 'text.secondary' }}>({c.email})</Typography>
                  </MenuItem>
                ))}
              </TextField>
            </Grid>

            {/* Categories List */}
            <Grid item xs={12}>
              <Typography variant="h6" sx={{ mt: 1, mb: 1 }}>Select Purchased Services</Typography>
              <Divider sx={{ mb: 2 }} />
              
              {categories.map(category => {
                const sel = selections[category];
                if (!sel) return null;
                const categoryProducts = groupedProducts[category];
                const subCategories = [...new Set(categoryProducts.filter(p => p.sub_category).map(p => p.sub_category))];

                const filteredBySub = subCategories.length > 0 && sel.subCategory 
                  ? categoryProducts.filter(p => p.sub_category === sel.subCategory)
                  : categoryProducts;

                return (
                  <Box key={category} sx={{ mb: 3, p: 2, border: '1px solid', borderColor: sel.selected ? 'primary.main' : 'grey.300', borderRadius: 2, bgcolor: sel.selected ? '#f8f9fa' : 'transparent' }}>
                    <FormControlLabel
                      control={<Checkbox checked={sel.selected} onChange={(e) => handleSelectionChange(category, 'selected', e.target.checked)} color="primary" />}
                      label={<Typography variant="h6" sx={{ fontWeight: sel.selected ? 'bold' : 'normal', textTransform: 'capitalize' }}>{category}</Typography>}
                    />
                    
                    {sel.selected && (
                      <Grid container spacing={2} sx={{ mt: 1, pl: 4 }}>
                        {/* Sub Category Selection (if applicable) */}
                        {subCategories.length > 0 && (
                          <Grid item xs={12} md={3}>
                            <TextField
                              select
                              fullWidth
                              label="Sub Category"
                              value={sel.subCategory || ''}
                              onChange={(e) => {
                                handleSelectionChange(category, 'subCategory', e.target.value);
                                handleSelectionChange(category, 'providerName', ''); // Reset
                                handleSelectionChange(category, 'productId', '');
                              }}
                              required={sel.selected}
                            >
                              {subCategories.map(sub => (
                                <MenuItem key={sub} value={sub}>
                                  {sub}
                                </MenuItem>
                              ))}
                            </TextField>
                          </Grid>
                        )}

                        {/* Provider Selection */}
                        <Grid item xs={12} md={subCategories.length > 0 ? 3 : 4}>
                          <TextField
                            select
                            fullWidth
                            label="Provider"
                            value={sel.providerName || ''}
                            onChange={(e) => {
                              handleSelectionChange(category, 'providerName', e.target.value);
                              handleSelectionChange(category, 'productId', ''); // Reset product when provider changes
                            }}
                            required={sel.selected}
                            disabled={subCategories.length > 0 && !sel.subCategory}
                          >
                            {[...new Set(filteredBySub.map(p => p.provider_name))].map(prov => (
                              <MenuItem key={prov} value={prov}>
                                {prov}
                              </MenuItem>
                            ))}
                          </TextField>
                        </Grid>
                        
                        {/* Plan Selection */}
                        <Grid item xs={12} md={subCategories.length > 0 ? 6 : 8}>
                          <TextField
                            select
                            fullWidth
                            label="Plan Purchased"
                            value={sel.productId || ''}
                            onChange={(e) => handleSelectionChange(category, 'productId', e.target.value)}
                            required={sel.selected}
                            disabled={!sel.providerName}
                            sx={{ minWidth: 300 }}
                          >
                            {filteredBySub.filter(p => p.provider_name === sel.providerName).map(p => (
                              <MenuItem key={p.id} value={p.id}>
                                <Typography sx={{ fontWeight: 'medium' }}>{p.plan_name} (${p.price})</Typography>
                              </MenuItem>
                            ))}
                          </TextField>
                        </Grid>

                        {/* Date and Interval */}
                        <Grid item xs={12} md={3}>
                          <TextField
                            type="date"
                            fullWidth
                            label="Billing Cutoff Date"
                            InputLabelProps={{ shrink: true }}
                            value={sel.billingDate}
                            onChange={(e) => {
                              const newDate = e.target.value;
                              handleSelectionChange(category, 'billingDate', newDate);
                              if (!sel.manualSwitchDate) {
                                handleSelectionChange(category, 'switchDate', newDate);
                              }
                            }}
                            required={sel.selected}
                          />
                        </Grid>
                        <Grid item xs={12} md={3}>
                          <TextField
                            type="date"
                            fullWidth
                            label="Switch Date"
                            InputLabelProps={{ shrink: true }}
                            value={sel.switchDate}
                            onChange={(e) => {
                              handleSelectionChange(category, 'switchDate', e.target.value);
                              handleSelectionChange(category, 'manualSwitchDate', true);
                            }}
                            required={sel.selected}
                            helperText="Override switch date"
                          />
                        </Grid>
                      </Grid>
                    )}
                  </Box>
                );
              })}
            </Grid>

            <Grid item xs={12}>
              <Button type="submit" variant="contained" color="primary" size="large">
                Save All Purchases
              </Button>
            </Grid>
          </Grid>
        </form>
      </Paper>
    </Box>
  );
}

export default BulkPurchase;