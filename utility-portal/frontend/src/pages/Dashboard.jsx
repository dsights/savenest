import React, { useState, useEffect } from 'react';
import { Typography, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Chip, Box, IconButton, Dialog, DialogTitle, DialogContent, DialogContentText, TextField, DialogActions, Button, InputAdornment } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import SearchIcon from '@mui/icons-material/Search';
import api from '../api';
import dayjs from 'dayjs';

function Dashboard() {
  const [switches, setSwitches] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  
  // Delete Dialog State
  const [deleteId, setDeleteId] = useState(null);
  const [password, setPassword] = useState('');
  const [passwordError, setPasswordError] = useState('');

  useEffect(() => {
    fetchSwitches();
  }, []);

  const fetchSwitches = async () => {
    try {
      const response = await api.get('/switches/pending');
      setSwitches(response.data);
    } catch (error) {
      console.error('Failed to fetch pending switches', error);
    }
  };

  const handleOpenDelete = (id) => {
    setDeleteId(id);
    setPassword('');
    setPasswordError('');
  };

  const handleCloseDelete = () => {
    setDeleteId(null);
    setPassword('');
  };

  const handleConfirmDelete = async () => {
    try {
      await api.post('/verify-password', { password });
      await api.delete(`/switches/${deleteId}`);
      fetchSwitches();
      handleCloseDelete();
    } catch (error) {
      if (error.response && error.response.status === 401) {
        setPasswordError('Incorrect password');
      } else {
        console.error('Failed to delete switch', error);
        setPasswordError('An error occurred');
      }
    }
  };

  const filteredSwitches = switches.filter(s => 
    s.customer_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.customer_email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h4" gutterBottom>Dashboard</Typography>
          <Typography variant="subtitle1" color="textSecondary">
            Overview of upcoming and pending utility switches.
          </Typography>
        </Box>
        <TextField
          variant="outlined"
          placeholder="Search Customer..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
          sx={{ width: 300, bgcolor: 'white' }}
        />
      </Box>

      <Paper sx={{ width: '100%', overflow: 'hidden' }}>
        <TableContainer sx={{ maxHeight: 650 }}>
          <Table stickyHeader aria-label="sticky table">
            <TableHead>
              <TableRow>
                <TableCell>Switch Date</TableCell>
                <TableCell>Billing Date</TableCell>
                <TableCell>Customer</TableCell>
                <TableCell>Category</TableCell>
                <TableCell>Provider & Product Details</TableCell>
                <TableCell>Rate</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredSwitches.map((row) => {
                const isDueTodayOrPast = dayjs(row.switch_date).isBefore(dayjs().add(1, 'day'), 'day');
                return (
                  <TableRow hover role="checkbox" tabIndex={-1} key={row.id}>
                    <TableCell>
                      {row.switch_date}
                      {isDueTodayOrPast && (
                        <Chip size="small" label="DUE" color="error" sx={{ ml: 1, fontWeight: 'bold' }} />
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="textSecondary">{row.billing_date || 'N/A'}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body1" sx={{ fontWeight: 'bold' }}>{row.customer_name}</Typography>
                      <Typography variant="caption" color="textSecondary">{row.customer_email}</Typography>
                    </TableCell>
                    <TableCell>
                      <Chip label={row.category} size="small" sx={{ textTransform: 'capitalize' }} />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontWeight: 'bold' }}>{row.provider_name}</Typography>
                      <Typography variant="body2">{row.plan_name}</Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontWeight: 'bold', color: 'primary.main' }}>
                        ${row.price} {row.price_unit}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <IconButton color="error" onClick={() => handleOpenDelete(row.id)} title="Delete Switch">
                        <DeleteIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                );
              })}
              {filteredSwitches.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} align="center">
                    No pending switches match your search.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Delete Confirmation Dialog */}
      <Dialog open={Boolean(deleteId)} onClose={handleCloseDelete}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent>
          <DialogContentText>
            To delete this scheduled switch, please enter your admin password. This action cannot be undone.
          </DialogContentText>
          <TextField
            autoFocus
            margin="dense"
            label="Admin Password"
            type="password"
            fullWidth
            variant="outlined"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={Boolean(passwordError)}
            helperText={passwordError}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDelete}>Cancel</Button>
          <Button onClick={handleConfirmDelete} color="error" variant="contained">
            Delete Record
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default Dashboard;