import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { CheckCircle2, AlertTriangle, HeartPulse, UserX, ArrowLeft } from 'lucide-react';

export const FamilySharedPage: React.FC = () => {
  const { userId } = useParams<{ userId: string }>();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      setErrorMsg('সদস্য আইডি লিংকটি সঠিক নয়।');
      return;
    }
    setLoading(true);
    setErrorMsg(null);
    axios
      .get(`http://localhost:3001/api/v1/family/${userId}/today`)
      .then((res) => {
        if (res.data.success && res.data.data) {
          setData(res.data.data);
        } else {
          setErrorMsg('সদস্যের লাইভ তথ্য পাওয়া যায়নি।');
        }
      })
      .catch((err) => {
        setErrorMsg(err.response?.data?.message || 'সদস্যের লাইভ আপডেট ডাটাবেজ থেকে লোড করতে সমস্যা হয়েছে।');
      })
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center font-sans text-slate-700 font-bold text-lg">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600 mr-3"></div>
        পরিবারের সদস্যের স্বাস্থ্য তথ্য লোড হচ্ছে...
      </div>
    );
  }

  if (errorMsg || !data) {
    return (
      <div className="min-h-screen bg-slate-50 p-6 md:p-12 font-sans flex items-center justify-center">
        <div className="max-w-md w-full bg-white rounded-3xl p-8 border border-slate-200 shadow-xl text-center">
          <div className="w-16 h-16 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <UserX className="w-8 h-8" />
          </div>
          <h2 className="text-2xl font-bold text-slate-900 mb-2">সদস্যের তথ্য পাওয়া যায়নি</h2>
          <p className="text-slate-600 text-sm mb-6">{errorMsg || 'আইডি বা লিংকটি সঠিক কিনা পুনরায় যাচাই করুন।'}</p>
          <Link
            to="/"
            className="inline-flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold px-6 py-3 rounded-xl transition shadow-md"
          >
            <ArrowLeft className="w-4 h-4" /> হোমে ফিরে যান
          </Link>
        </div>
      </div>
    );
  }

  const user = data.user || { name: 'পরিবারের সদস্য', phone: '' };
  const logs = data.logs || [];
  const takenCount = data.takenCount ?? 0;
  const totalCount = data.totalCount ?? 0;

  return (
    <div className="min-h-screen bg-slate-50 p-6 md:p-12 font-sans">
      <div className="max-w-xl mx-auto bg-white rounded-3xl p-8 border border-slate-200 shadow-md">
        <div className="text-center mb-8">
          <span className="text-5xl">👨👩👧</span>
          <h1 className="text-2xl font-bold text-slate-900 mt-2">{user.name}</h1>
          <p className="text-emerald-600 font-medium">আজকের লাইভ হেলথ আপডেট</p>
        </div>

        <div className="bg-emerald-50 border border-emerald-200 p-6 rounded-2xl mb-6">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold text-slate-900 text-lg">📊 আজকের ওষুধ স্ট্যাটাস</span>
            <span className="bg-emerald-600 text-white text-xs font-bold px-3 py-1 rounded-full">
              {takenCount}/{totalCount} টি খেয়েছেন
            </span>
          </div>
          {logs.length === 0 ? (
            <p className="text-sm text-slate-500 text-center py-4">আজকের কোনো ওষুধের শিডিউল যুক্ত করা নেই।</p>
          ) : (
            <div className="space-y-3">
              {logs.map((log: any, idx: number) => (
                <div
                  key={log.id || idx}
                  className={`flex items-center justify-between p-3 rounded-xl border ${
                    log.status === 'taken'
                      ? 'bg-white border-emerald-100'
                      : 'bg-amber-50 border-amber-200'
                  }`}
                >
                  <span className="font-medium text-slate-800">
                    {log.time} — {log.medicine}
                  </span>
                  <span
                    className={`font-bold text-sm flex items-center gap-1 ${
                      log.status === 'taken' ? 'text-emerald-600' : 'text-amber-600'
                    }`}
                  >
                    {log.status === 'taken' ? (
                      <>
                        <CheckCircle2 className="w-4 h-4" /> খেয়েছেন
                      </>
                    ) : (
                      <>
                        <AlertTriangle className="w-4 h-4" /> মিসড / পেন্ডিং
                      </>
                    )}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-sky-50 border border-sky-200 p-6 rounded-2xl mb-8">
          <div className="flex items-center gap-2 mb-2 text-sky-800 font-bold text-lg">
            <HeartPulse className="w-6 h-6 text-sky-600" /> সাম্প্রতিক রিডিং (আজকের তথ্য)
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            <div className="bg-white p-4 rounded-xl border border-sky-100">
              <span className="text-xs text-slate-500 font-bold uppercase block">রক্তচাপ (BP)</span>
              <span className="text-2xl font-extrabold text-sky-700">{data.latestBp || 'তথ্য নেই'}</span>
              <span className="text-xs text-slate-400 block">mmHg</span>
            </div>
            <div className="bg-white p-4 rounded-xl border border-sky-100">
              <span className="text-xs text-slate-500 font-bold uppercase block">রক্তের সুগার</span>
              <span className="text-2xl font-extrabold text-sky-700">{data.latestSugar || 'তথ্য নেই'}</span>
              <span className="text-xs text-slate-400 block">mmol/L</span>
            </div>
          </div>
        </div>

        {user.phone && (
          <a
            href={`tel:${user.phone}`}
            className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-3.5 rounded-xl flex items-center justify-center gap-2 transition shadow-md"
          >
            📞 সদস্যকে সরাসরি কল করুন ({user.phone})
          </a>
        )}
      </div>
    </div>
  );
};
