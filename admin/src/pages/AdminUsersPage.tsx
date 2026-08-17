import React, { useState } from 'react';
import { AdminLayout } from '../components/AdminLayout';
import { UserCheck } from 'lucide-react';

export const AdminUsersPage: React.FC = () => {
  const [users] = useState<any[]>([
    { id: 1, name: 'রহিম চৌধুরী', phone: '01711223344', blood_group: 'B+', is_active: 1, created_at: '2026-08-15' },
    { id: 2, name: 'জাহানারা বেগম', phone: '01899887766', blood_group: 'A+', is_active: 1, created_at: '2026-08-16' },
    { id: 3, name: 'আসিফ মাহমুদ', phone: '01500112233', blood_group: 'O+', is_active: 1, created_at: '2026-08-17' },
  ]);

  return (
    <AdminLayout>
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-slate-900">ইউজার ট্র্যাকিং ও এনালিটিক্স</h1>
        <p className="text-slate-500">রেজিস্টার্ড ইউজারদের তালিকা ও অ্যাকাউন্ট স্ট্যাটাস</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 text-slate-500 text-xs uppercase border-b border-slate-200">
              <th className="p-4">ইউজার ID</th>
              <th className="p-4">পূর্ণ নাম</th>
              <th className="p-4">ফোন নম্বর</th>
              <th className="p-4">রক্তের গ্রুপ</th>
              <th className="p-4">স্ট্যাটাস</th>
              <th className="p-4">নিবন্ধন তারিখ</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {users.map((u) => (
              <tr key={u.id} className="hover:bg-slate-50">
                <td className="p-4 font-mono text-slate-500">#{u.id}</td>
                <td className="p-4 font-bold text-slate-900 flex items-center gap-2">
                  <UserCheck className="w-4 h-4 text-emerald-600" />
                  {u.name}
                </td>
                <td className="p-4 text-slate-600">{u.phone}</td>
                <td className="p-4 font-bold text-red-600">{u.blood_group || '-'}</td>
                <td className="p-4">
                  <span className="bg-emerald-100 text-emerald-700 text-xs font-bold px-2.5 py-1 rounded-full">
                    সক্রিয় ✅
                  </span>
                </td>
                <td className="p-4 text-slate-500">{u.created_at}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  );
};
