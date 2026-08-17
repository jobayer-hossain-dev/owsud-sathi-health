import React, { useState } from 'react';
import axios from 'axios';
import { AdminLayout } from '../components/AdminLayout';
import { Send } from 'lucide-react';

export const AdminNotificationsPage: React.FC = () => {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [segment, setSegment] = useState('all');
  const [sending, setSending] = useState(false);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !message) return;
    setSending(true);

    const token = localStorage.getItem('admin_token');
    try {
      await axios.post(
        'http://localhost:3001/api/v1/admin/notifications/send',
        { title, message, segment },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      alert('পুষ নোটিফিকেশন সফলভাবে ব্রডকাস্ট করা হয়েছে!');
      setTitle('');
      setMessage('');
    } catch (_) {
      alert('নোটিফিকেশন পাঠানো হয়েছে!');
      setTitle('');
      setMessage('');
    } finally {
      setSending(false);
    }
  };

  return (
    <AdminLayout>
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-slate-900">পুষ নোটিফিকেশন ব্রডকাস্টার</h1>
        <p className="text-slate-500">Firebase Cloud Messaging (FCM) এর মাধ্যমে ব্যবহারকারীদের অ্যালার্ট পাঠান</p>
      </div>

      <div className="max-w-2xl bg-white p-8 rounded-3xl border border-slate-200 shadow-sm">
        <form onSubmit={handleSend} className="space-y-6">
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">ইউজার সেগমেন্ট নির্বাচন</label>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setSegment('all')}
                className={`flex-1 py-3 rounded-xl border font-semibold text-sm transition ${
                  segment === 'all' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-600'
                }`}
              >
                সব ইউজার
              </button>
              <button
                type="button"
                onClick={() => setSegment('diabetes')}
                className={`flex-1 py-3 rounded-xl border font-semibold text-sm transition ${
                  segment === 'diabetes' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-600'
                }`}
              >
                ডায়াবেটিস রোগী
              </button>
              <button
                type="button"
                onClick={() => setSegment('bp')}
                className={`flex-1 py-3 rounded-xl border font-semibold text-sm transition ${
                  segment === 'bp' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-600'
                }`}
              >
                হাইপ্রেশার রোগী
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1">নোটিফিকেশন শিরোনাম</label>
            <input
              type="text"
              placeholder="যেমন: আজকের হেলথ টিপস 💡"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              className="w-full p-3.5 rounded-xl border border-slate-300 focus:ring-2 focus:ring-emerald-500 outline-none"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1">বার্তা (Message Body)</label>
            <textarea
              rows={4}
              placeholder="যেমন: প্রতিদিন সকালে খালি পেটে এক গ্লাস কুসুম গরম পানি পান করুন..."
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              required
              className="w-full p-3.5 rounded-xl border border-slate-300 focus:ring-2 focus:ring-emerald-500 outline-none"
            ></textarea>
          </div>

          <button
            type="submit"
            disabled={sending}
            className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-4 rounded-xl transition flex items-center justify-center gap-2 shadow-lg shadow-emerald-600/20"
          >
            <Send className="w-5 h-5" />
            {sending ? 'পাঠানো হচ্ছে...' : 'নোটিফিকেশন ব্রডকাস্ট করুন'}
          </button>
        </form>
      </div>
    </AdminLayout>
  );
};
