import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft, ShieldAlert, AlertCircle, Activity, Pill } from 'lucide-react';

export const MedicineSeoPage: React.FC = () => {
  const { name } = useParams<{ name: string }>();
  const [medicine, setMedicine] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!name) {
      setLoading(false);
      setErrorMsg('ওষুধের নাম প্রদান করা হয়নি।');
      return;
    }
    setLoading(true);
    setErrorMsg(null);
    axios
      .get(`http://localhost:3001/api/v1/medicines?q=${encodeURIComponent(name)}&limit=1`)
      .then((res) => {
        if (res.data.success && res.data.data && res.data.data.length > 0) {
          setMedicine(res.data.data[0]);
        } else {
          setMedicine(null);
          setErrorMsg(`"${name}" নামে কোনো ওষুধ ডাটাবেজে পাওয়া যায়নি।`);
        }
      })
      .catch((err) => {
        setMedicine(null);
        setErrorMsg(err.response?.data?.message || 'ডাটাবেজ সার্ভার থেকে ওষুধ তথ্য আনতে ব্যর্থ হয়েছে।');
      })
      .finally(() => setLoading(false));
  }, [name]);

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center font-sans text-slate-700 font-bold text-lg">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600 mr-3"></div>
        মেডিসিন তথ্য ডাটাবেজ থেকে লোড হচ্ছে...
      </div>
    );
  }

  if (errorMsg || !medicine) {
    return (
      <div className="min-h-screen bg-slate-50 p-6 md:p-12 font-sans flex items-center justify-center">
        <div className="max-w-md w-full bg-white rounded-3xl p-8 border border-slate-200 shadow-xl text-center">
          <div className="w-16 h-16 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="w-8 h-8" />
          </div>
          <h2 className="text-2xl font-bold text-slate-900 mb-2">ওষুধ পাওয়া যায়নি</h2>
          <p className="text-slate-600 text-sm mb-6">{errorMsg || 'সঠিক ব্র্যান্ড বা জেনেরিক নাম লিখে সার্চ করুন।'}</p>
          <Link
            to="/"
            className="inline-flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold px-6 py-3 rounded-xl transition shadow-md"
          >
            <ArrowLeft className="w-4 h-4" /> হোমে ফিরে গিয়ে অনুসন্ধান করুন
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 p-6 md:p-12 font-sans">
      <div className="max-w-3xl mx-auto bg-white rounded-3xl p-8 border border-slate-200 shadow-md space-y-6">
        <Link to="/" className="inline-flex items-center gap-2 text-emerald-600 font-bold hover:underline">
          <ArrowLeft className="w-5 h-5" /> হোমে ফিরে যান
        </Link>

        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-extrabold text-slate-900">
              {medicine.brand_name} {medicine.brand_name_bn ? `(${medicine.brand_name_bn})` : ''}
            </h1>
            <p className="text-emerald-700 font-semibold text-lg">{medicine.generic_name} {medicine.generic_name_bn ? `(${medicine.generic_name_bn})` : ''}</p>
            <p className="text-slate-500 text-sm">{medicine.manufacturer}</p>
          </div>
          <div className="bg-emerald-50 border border-emerald-200 p-4 rounded-2xl text-right">
            <span className="text-xs text-slate-500 uppercase font-bold block">খুচরা মূল্য (MRP)</span>
            <span className="text-2xl font-extrabold text-emerald-600">৳{medicine.unit_price}</span>
            <span className="text-xs text-slate-500 block">/ প্রতি পিস</span>
          </div>
        </div>

        {/* Indications & Active Composition */}
        <div className="grid md:grid-cols-2 gap-4">
          <div className="bg-amber-50/80 p-5 rounded-2xl border border-amber-200/80">
            <h3 className="font-bold text-amber-900 flex items-center gap-2 mb-2">
              <Activity className="w-4 h-4 text-amber-600" /> মূল কাজ (Indications)
            </h3>
            <p className="text-slate-700 text-sm leading-relaxed">
              {medicine.indications_bn || medicine.indications || 'জ্বর, ব্যথা বা নির্দিষ্ট শারীরিক জটিলতায় প্রদেয়।'}
            </p>
          </div>

          <div className="bg-sky-50/80 p-5 rounded-2xl border border-sky-200/80">
            <h3 className="font-bold text-sky-900 flex items-center gap-2 mb-2">
              <Pill className="w-4 h-4 text-sky-600" /> রাসায়নিক উপাদান (Composition)
            </h3>
            <p className="text-slate-700 text-sm leading-relaxed">
              {medicine.composition_bn || medicine.composition || `সক্রিয় উপাদান: ${medicine.generic_name} (${medicine.strength})`}
            </p>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-slate-50 p-4 rounded-xl border border-slate-200">
            <h3 className="font-bold text-slate-900 mb-1">ফরম্যাট ও পাওয়ার</h3>
            <p className="text-slate-600">{medicine.dosage_form} — {medicine.strength}</p>
          </div>
          <div className="bg-slate-50 p-4 rounded-xl border border-slate-200">
            <h3 className="font-bold text-slate-900 mb-1">সেবনবিধি</h3>
            <p className="text-slate-600">{medicine.instructions || 'ডাক্তারের পরামর্শ মত খাবেন'}</p>
          </div>
        </div>

        <div className="bg-red-50 border border-red-200 p-4 rounded-2xl">
          <h3 className="font-bold text-red-900 flex items-center gap-2 mb-1">
            <ShieldAlert className="w-5 h-5 text-red-600" /> পার্শ্বপ্রতিক্রিয়া ও সতর্কতা
          </h3>
          <p className="text-red-800 text-sm">{medicine.side_effects || 'চিকিৎসকের নির্দেশ ছাড়া মাত্রা পরিবর্তন করবেন না।'}</p>
        </div>

        <div className="text-center pt-4 border-t border-slate-200">
          <p className="text-sm text-slate-500 mb-4">এই ওষুধ প্রতিদিন নিয়মিত খেতে ওষুধসাথী অ্যাপ ডাউনলোড করুন</p>
          <Link to="/" className="inline-block bg-emerald-600 text-white font-bold px-8 py-3 rounded-xl hover:bg-emerald-700 transition">
            ওষুধসাথী অ্যাপ নামান
          </Link>
        </div>
      </div>
    </div>
  );
};
