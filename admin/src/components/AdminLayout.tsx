import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { LayoutDashboard, Pill, Users, Bell, LogOut } from 'lucide-react';

export const AdminLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    navigate('/login');
  };

  const navItems = [
    { label: 'ড্যাশবোর্ড', path: '/dashboard', icon: LayoutDashboard },
    { label: 'মেডিসিন ডাটাবেজ', path: '/medicines', icon: Pill },
    { label: 'ইউজার ম্যানেজমেন্ট', path: '/users', icon: Users },
    { label: 'পুষ নোটিফিকেশন', path: '/notifications', icon: Bell },
  ];

  return (
    <div className="min-h-screen flex bg-slate-50 font-sans text-slate-800">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-white flex flex-col justify-between p-6">
        <div>
          <div className="flex items-center gap-3 mb-10">
            <span className="text-3xl">💊</span>
            <div>
              <h2 className="font-bold text-lg text-emerald-400">ওষুধসাথী Admin</h2>
              <span className="text-xs text-slate-400">v1.0.0 Panel</span>
            </div>
          </div>

          <nav className="space-y-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.path;
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition ${
                    isActive
                      ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-600/20'
                      : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>

        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-red-400 hover:bg-red-500/10 transition"
        >
          <LogOut className="w-5 h-5" />
          লগআউট
        </button>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8 overflow-y-auto">{children}</main>
    </div>
  );
};
