import React, { useState, useEffect, useRef } from 'react';
import { Typography, Paper, Box, Button, TextField, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, IconButton, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, Autocomplete, CircularProgress } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import axios from 'axios';
import api from '../api';

function Customers() {
  const [customers, setCustomers] = useState([]);
  const [formData, setFormData] = useState({ name: '', email: '', phone: '', house_no: '', street: '', suburb: '', state: '', post_code: '' });

  // Geocoding States
  const [suggestions, setSuggestions] = useState([]);
  const [loading, setLoading] = useState(false);
  const debounceTimer = useRef(null);

  // Dialog States
  const [editingCustomer, setEditingCustomer] = useState(null);
  const [editFormData, setEditFormData] = useState({ name: '', email: '', phone: '', house_no: '', street: '', suburb: '', state: '', post_code: '' });
  const [deleteId, setDeleteId] = useState(null);
  const [password, setPassword] = useState('');
  const [passwordError, setPasswordError] = useState('');

  useEffect(() => {
    fetchCustomers();
  }, []);

  const fetchCustomers = async () => {
    try {
      const response = await api.get('/customers');
      setCustomers(response.data);
    } catch (error) {
      console.error('Failed to fetch customers', error);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleEditInputChange = (e) => {
    const { name, value } = e.target;
    setEditFormData(prev => ({ ...prev, [name]: value }));
  };

  const performSearch = (query) => {
    if (!query || query.length < 3) {
      setSuggestions([]);
      return;
    }

    if (debounceTimer.current) clearTimeout(debounceTimer.current);
    
    debounceTimer.current = setTimeout(async () => {
      setLoading(true);
      try {
        const url = 'https://photon.komoot.io/api/?q=' + encodeURIComponent(query + ', Australia') + '&bbox=112.9,-43.7,159.1,-9.1&limit=15';
        const response = await axios.get(url);
        
        const results = response.data.features
          .filter(f => f.properties.country === 'Australia' || f.properties.countrycode === 'AU')
          .map(f => {
            const p = f.properties;
            const sub = p.suburb || p.district || p.city || p.town;
            const labelParts = [];
            if (p.housenumber) labelParts.push(p.housenumber);
            if (p.street) labelParts.push(p.street);
            if (sub) labelParts.push(sub);
            if (p.state) labelParts.push(p.state);
            if (p.postcode) labelParts.push(p.postcode);

            return {
                label: labelParts.join(', '),
                house_no: p.housenumber || '',
                street: p.street || '',
                suburb: sub || '',
                state: p.state || '',
                post_code: p.postcode || ''
            };
          });
          
        setSuggestions(results);
      } catch (error) {
        console.error('Search failed', error);
      } finally {
        setLoading(false);
      }
    }, 400);
  };

  const handleSelectAddress = (newValue, isEdit = false) => {
    if (newValue && typeof newValue === 'object') {
      const update = {
        house_no: newValue.house_no || (isEdit ? editFormData.house_no : formData.house_no),
        street: newValue.street || (isEdit ? editFormData.street : formData.street),
        suburb: newValue.suburb,
        state: newValue.state,
        post_code: newValue.post_code || (isEdit ? editFormData.post_code : formData.post_code)
      };

      if (isEdit) {
        setEditFormData(prev => ({ ...prev, ...update }));
      } else {
        setFormData(prev => ({ ...prev, ...update }));
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await api.post('/customers', formData);
      setFormData({ name: '', email: '', phone: '', house_no: '', street: '', suburb: '', state: '', post_code: '' });
      setSuggestions([]);
      fetchCustomers();
    } catch (error) {
      console.error('Failed to add customer', error);
      const msg = error.response?.data?.error || error.message;
      alert('Error adding customer: ' + msg);
    }
  };

  const handleOpenEdit = (customer) => {
    setEditingCustomer(customer);
    setEditFormData({ 
        name: customer.name || '',
        email: customer.email || '',
        phone: customer.phone || '',
        house_no: customer.house_no || '',
        street: customer.street || '',
        suburb: customer.suburb || '',
        state: customer.state || '',
        post_code: customer.post_code || ''
    });
  };

  const handleSaveEdit = async () => {
    try {
      await api.put('/customers/' + editingCustomer.id, editFormData);
      fetchCustomers();
      setEditingCustomer(null);
    } catch (error) {
      console.error('Failed to update customer', error);
      alert('Error updating customer');
    }
  };

  const handleConfirmDelete = async () => {
    try {
      await api.post('/verify-password', { password });
      await api.delete('/customers/' + deleteId);
      fetchCustomers();
      setDeleteId(null);
    } catch (error) {
      setPasswordError('Incorrect password or error occurred.');
    }
  };

  return (
    <Box>
      <Typography variant='h4' gutterBottom>Customers</Typography>

      <Paper sx={{ p: 4, mb: 4, maxWidth: 1200 }}>
        <Typography variant='h6' gutterBottom sx={{ mb: 3 }}>Add New Customer</Typography>
        <form onSubmit={handleSubmit}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            {/* Row 1: Basic Info */}
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <TextField required sx={{ flex: 1, minWidth: '250px' }} label='Full Name' name='name' value={formData.name} onChange={handleInputChange} />
              <TextField required sx={{ flex: 1, minWidth: '250px' }} type='email' label='Email Address' name='email' value={formData.email} onChange={handleInputChange} />
              <TextField sx={{ flex: 1, minWidth: '200px' }} label='Phone Number' name='phone' value={formData.phone} onChange={handleInputChange} />
            </Box>
            
            {/* Row 2: House and Street */}
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <TextField sx={{ flex: 1, minWidth: '150px' }} label='House/Unit #' name='house_no' value={formData.house_no} onChange={handleInputChange} />
              <Autocomplete
                freeSolo
                sx={{ flex: 3, minWidth: '350px' }}
                options={suggestions}
                loading={loading}
                getOptionLabel={(opt) => (typeof opt === 'string' ? opt : opt.label)}
                onInputChange={(e, val) => {
                    setFormData(prev => ({ ...prev, street: val }));
                    performSearch(val);
                }}
                onChange={(e, val) => handleSelectAddress(val)}
                renderInput={(params) => (
                  <TextField {...params} label='Street Name' fullWidth placeholder='Start typing street...' 
                    InputProps={{ ...params.InputProps, endAdornment: ( <React.Fragment>{loading ? <CircularProgress color='inherit' size={20} /> : null}{params.InputProps.endAdornment}</React.Fragment> ) }}
                  />
                )}
              />
            </Box>

            {/* Row 3: Suburb and Post Code */}
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <Autocomplete
                freeSolo
                sx={{ flex: 3, minWidth: '350px' }}
                options={suggestions}
                loading={loading}
                getOptionLabel={(opt) => (typeof opt === 'string' ? opt : opt.label)}
                onInputChange={(e, val) => {
                    setFormData(prev => ({ ...prev, suburb: val }));
                    performSearch(val);
                }}
                onChange={(e, val) => handleSelectAddress(val)}
                renderInput={(params) => (
                  <TextField {...params} label='Suburb / City' fullWidth placeholder='Start typing suburb...' 
                    InputProps={{ ...params.InputProps, endAdornment: ( <React.Fragment>{loading ? <CircularProgress color='inherit' size={20} /> : null}{params.InputProps.endAdornment}</React.Fragment> ) }}
                  />
                )}
              />
              <TextField sx={{ flex: 1, minWidth: '150px' }} label='Post Code' name='post_code' value={formData.post_code} onChange={handleInputChange} />
            </Box>
            
            <Box><Button type='submit' variant='contained' color='primary' size='large'>Add Customer</Button></Box>
          </Box>
        </form>
      </Paper>

      <Typography variant='h6' gutterBottom>Existing Customers</Typography>
      <TableContainer component={Paper} sx={{ maxWidth: 1200, overflowX: 'auto' }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Code</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell>House #</TableCell>
              <TableCell>Street</TableCell>
              <TableCell>Suburb</TableCell>
              <TableCell>Post Code</TableCell>
              <TableCell align='right'>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {customers.map((c) => (
              <TableRow key={c.id}>
                <TableCell>
                  <Typography variant='body2' sx={{ fontWeight: 'bold', bgcolor: '#e3f2fd', display: 'inline-block', padding: '2px 8px', borderRadius: '4px', border: '1px solid #90caf9' }}>
                    {c.customer_code || 'CUST-' + c.id}
                  </Typography>
                </TableCell>
                <TableCell>{c.name}</TableCell>
                <TableCell>{c.email}</TableCell>
                <TableCell>{c.phone}</TableCell>
                <TableCell>{c.house_no}</TableCell>
                <TableCell>{c.street}</TableCell>
                <TableCell>{c.suburb}</TableCell>
                <TableCell>{c.post_code}</TableCell>
                <TableCell align='right'>
                  <IconButton color='primary' onClick={() => handleOpenEdit(c)}><EditIcon /></IconButton>
                  <IconButton color='error' onClick={() => setDeleteId(c.id)}><DeleteIcon /></IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Edit Dialog */}
      <Dialog open={Boolean(editingCustomer)} onClose={() => setEditingCustomer(null)} maxWidth='md' fullWidth>
        <DialogTitle>Edit Customer</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, mt: 2 }}>
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <TextField label='Full Name' name='name' sx={{ flex: 1 }} value={editFormData.name} onChange={handleEditInputChange} />
              <TextField label='Email Address' name='email' sx={{ flex: 1 }} value={editFormData.email} onChange={handleEditInputChange} />
              <TextField label='Phone Number' name='phone' sx={{ flex: 1 }} value={editFormData.phone} onChange={handleEditInputChange} />
            </Box>
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <TextField label='House/Unit #' name='house_no' sx={{ flex: 1 }} value={editFormData.house_no} onChange={handleEditInputChange} />
              <Autocomplete freeSolo sx={{ flex: 3 }} options={suggestions} loading={loading} getOptionLabel={(opt) => (typeof opt === 'string' ? opt : opt.label)}
                onInputChange={(e, val) => { setEditFormData(prev => ({ ...prev, street: val })); performSearch(val); }}
                onChange={(e, val) => handleSelectAddress(val, true)}
                renderInput={(params) => <TextField {...params} label='Street Name' />}
              />
            </Box>
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <Autocomplete freeSolo sx={{ flex: 3 }} options={suggestions} loading={loading} getOptionLabel={(opt) => (typeof opt === 'string' ? opt : opt.label)}
                onInputChange={(e, val) => { setEditFormData(prev => ({ ...prev, suburb: val })); performSearch(val); }}
                onChange={(e, val) => handleSelectAddress(val, true)}
                renderInput={(params) => <TextField {...params} label='Suburb / City' />}
              />
              <TextField label='Post Code' name='post_code' sx={{ flex: 1 }} value={editFormData.post_code} onChange={handleEditInputChange} />
            </Box>
          </Box>
        </DialogContent>
        <DialogActions sx={{ p: 3 }}>
          <Button onClick={() => setEditingCustomer(null)}>Cancel</Button>
          <Button onClick={handleSaveEdit} color='primary' variant='contained'>Save Changes</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={Boolean(deleteId)} onClose={() => setDeleteId(null)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><TextField autoFocus margin='dense' label='Admin Password' type='password' fullWidth variant='outlined' value={password} onChange={(e) => setPassword(e.target.value)} error={Boolean(passwordError)} helperText={passwordError} /></DialogContent>
        <DialogActions><Button onClick={() => setDeleteId(null)}>Cancel</Button><Button onClick={handleConfirmDelete} color='error' variant='contained'>Delete Record</Button></DialogActions>
      </Dialog>
    </Box>
  );
}

export default Customers;
