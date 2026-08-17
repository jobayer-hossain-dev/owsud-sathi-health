import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AdminLoginPage } from './pages/AdminLoginPage';
import { AdminDashboardPage } from './pages/AdminDashboardPage';
import { AdminMedicinesPage } from './pages/AdminMedicinesPage';
import { AdminUsersPage } from './pages/AdminUsersPage';
import { AdminNotificationsPage } from './pages/AdminNotificationsPage';

export function App() {
  return (
    <Router basename="/admin">
      <Routes>
        <Route path="/login" element={<AdminLoginPage />} />
        <Route path="/dashboard" element={<AdminDashboardPage />} />
        <Route path="/medicines" element={<AdminMedicinesPage />} />
        <Route path="/users" element={<AdminUsersPage />} />
        <Route path="/notifications" element={<AdminNotificationsPage />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
