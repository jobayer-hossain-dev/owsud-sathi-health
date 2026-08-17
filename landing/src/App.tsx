import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { HomePage } from './pages/HomePage';
import { MedicineSeoPage } from './pages/MedicineSeoPage';
import { FamilySharedPage } from './pages/FamilySharedPage';

export function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/medicine/:name" element={<MedicineSeoPage />} />
        <Route path="/family/:userId" element={<FamilySharedPage />} />
      </Routes>
    </Router>
  );
}

export default App;
