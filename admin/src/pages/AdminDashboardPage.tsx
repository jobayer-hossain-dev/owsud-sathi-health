import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { AdminLayout } from '../components/AdminLayout';
import { Users, Pill, Activity, CheckCircle2, TrendingUp, Sparkles, ArrowUpRight } from 'lucide-react';

export const AdminDashboardPage: React.FC = () => {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('admin_token');
    axios
      .get('http://localhost:3001/api/v1/admin/dashboard/stats', {
        headers: { Authorization: `Bearer ${token}` },
      })
      .then((res) => {
        if (res.data.success) {
          const d = res.data.stats || res.data.data || res.data;
          setStats({
            totalUsers: d.totalUsers ?? 0,
            activeUsers: d.totalActiveMeds ?? d.activeUsers ?? 0,
            totalMedicines: d.totalMedicines ?? 0,
            todayAdherence: d.todayAdherence ?? 0,
            todayDoses: d.todayDoses ?? 0,
            todayTaken: d.todayTaken ?? 0,
            newUsersWeek: d.newUsersWeek ?? 0,
          });
        }
      })
      .catch((err) => {
        console.error('Failed to load dashboard stats:', err);
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout>
      <div className="mb-8 flex justify-between items-end">
        <div>
          <div className="inline-flex items-center gap-2 bg-emerald-100 text-emerald-800 text-xs font-bold px-3 py-1 rounded-full mb-2">
            <Sparkles className="w-3.5 h-3.5" />
            লাইভ রিয়েলটাইম সিস্টেম ওভারভিউ
          </div>
          <h1 className="text-3xl font-black text-slate-900 tracking-tight">এডমিন ড্যাশবোর্ড</h1>
          <p className="text-slate-500 text-sm">ওষুধসাথী প্ল্যাটফর্মের সার্বিক ইউজার ও মেডিসিন অ্যানালিটিক্স</p>
        </div>
        <div className="text-right">
          <span className="text-xs font-bold text-slate-400 block uppercase">সার্ভার স্ট্যাটাস</span>
          <span className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-md border border-emerald-200">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
            সচল (MySQL 8.0 Live Engine)
          </span>
        </div>
      </div>

      {loading ? (
        <div className="p-12 text-center text-slate-500 font-bold">ডাটাবেজ থেকে আসল ড্যাশবোর্ড স্ট্যাটস লোড হচ্ছে...</div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <div className="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-sm hover:shadow-md transition">
              <div className="flex justify-between items-center mb-4">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">মোট নিবন্ধিত ইউজার</span>
                <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center">
                  <Users className="w-5 h-5" />
                </div>
              </div>
              <p className="text-3xl font-black text-slate-900 mb-1">{stats?.totalUsers ?? 0}</p>
              <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
                <TrendingUp className="w-3.5 h-3.5" />
                <span>+{stats?.newUsersWeek ?? 0} জন এই সপ্তাহে নিবন্ধিত</span>
              </div>
            </div>

            <div className="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-sm hover:shadow-md transition">
              <div className="flex justify-between items-center mb-4">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">সক্রিয় রিমাইন্ডার</span>
                <div className="w-10 h-10 bg-sky-100 text-sky-600 rounded-xl flex items-center justify-center">
                  <Activity className="w-5 h-5" />
                </div>
              </div>
              <p className="text-3xl font-black text-slate-900 mb-1">{stats?.activeUsers ?? 0}</p>
              <div className="flex items-center gap-1 text-xs font-bold text-sky-600">
                <ArrowUpRight className="w-3.5 h-3.5" />
                <span>লাইভ ওষুধ শিডিউল</span>
              </div>
            </div>

            <div className="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-sm hover:shadow-md transition">
              <div className="flex justify-between items-center mb-4">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">মেডিসিন ক্যাটালগ</span>
                <div className="w-10 h-10 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center">
                  <Pill className="w-5 h-5" />
                </div>
              </div>
              <p className="text-3xl font-black text-slate-900 mb-1">{stats?.totalMedicines ?? 0}</p>
              <div className="flex items-center gap-1 text-xs font-bold text-purple-600">
                <span>DGDA রেজিস্টার্ড ওষুধ</span>
              </div>
            </div>

            <div className="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-sm hover:shadow-md transition">
              <div className="flex justify-between items-center mb-4">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">আজকের ডোজ সম্পন্ন</span>
                <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center">
                  <CheckCircle2 className="w-5 h-5" />
                </div>
              </div>
              <p className="text-3xl font-black text-slate-900 mb-1">{stats?.todayAdherence ?? 0}%</p>
              <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
                <span>{stats?.todayTaken ?? 0} / {stats?.todayDoses ?? 0} টি ওষুধ খাওয়া শেষ</span>
              </div>
            </div>
          </div>
        </>
      )}
    </AdminLayout>
  );
};
