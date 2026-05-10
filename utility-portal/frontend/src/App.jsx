import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Customers from './pages/Customers';
import CreateSwitch from './pages/CreateSwitch';
import BulkPurchase from './pages/BulkPurchase';
import Login from './pages/Login';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    // Simple check: if there's a token, assume they are logged in.
    // In a real app, you'd validate the token with the server here.
    const token = localStorage.getItem('adminToken');
    if (token) {
      setIsAuthenticated(true);
    }
    setIsChecking(false);
  }, []);

  if (isChecking) return null; // Don't render anything while checking auth state

  if (!isAuthenticated) {
    return <Login onLoginSuccess={() => setIsAuthenticated(true)} />;
  }

  return (
    <Routes>
      <Route path="/" element={<Layout onLogout={() => setIsAuthenticated(false)} />}>
        <Route index element={<Dashboard />} />
        <Route path="customers" element={<Customers />} />
        <Route path="create-switch" element={<CreateSwitch />} />
        <Route path="bulk-purchase" element={<BulkPurchase />} />
        {/* Catch-all redirect */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}

export default App;