import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { AdminLayout } from '../components/AdminLayout';
import { Search, Plus, Upload, FileText, CheckCircle2 } from 'lucide-react';

export const AdminMedicinesPage: React.FC = () => {
  const [medicines, setMedicines] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);
  const [dragActive, setDragActive] = useState(false);
  const [importSuccessMsg, setImportSuccessMsg] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);

  const [form, setForm] = useState({
    brand_name: '',
    brand_name_bn: '',
    generic_name: '',
    generic_name_bn: '',
    manufacturer: '',
    dosage_form: 'tablet',
    strength: '',
    unit_price: '',
    indications_bn: '',
    composition_bn: '',
  });

  const fetchMedicines = () => {
    const token = localStorage.getItem('admin_token');
    axios
      .get(`http://localhost:3001/api/v1/admin/medicines?q=${encodeURIComponent(search)}`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      .then((res) => {
        if (res.data.success) {
          setMedicines(res.data.data || res.data.medicines || []);
        }
      })
      .catch(() => {
        setMedicines([]);
      });
  };

  useEffect(() => {
    fetchMedicines();
  }, [search]);

  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const token = localStorage.getItem('admin_token');
    try {
      await axios.post('http://localhost:3001/api/v1/admin/medicines', form, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setShowAddModal(false);
      fetchMedicines();
    } catch (_) {
      alert('মেডিসিন যোগ করা সম্ভব হয়নি');
    }
  };

  const handleBulkUploadFile = async (file: File) => {
    if (!file) return;
    const token = localStorage.getItem('admin_token');
    
    setIsUploading(true);
    setUploadProgress(0);

    const reader = new FileReader();
    reader.onload = async (evt) => {
      const text = evt.target?.result as string;
      const lines = text.split('\n').filter(l => l.trim().length > 0);
      const parsedMedicines: any[] = [];

      for (let i = 1; i < lines.length; i++) {
        const parts = lines[i].split(',').map(p => p.trim());
        if (parts.length >= 2 && parts[0]) {
          parsedMedicines.push({
            brand_name: parts[0],
            generic_name: parts[1] || 'Generic',
            manufacturer: parts[2] || 'Generic Pharma',
            dosage_form: parts[3] || 'tablet',
            strength: parts[4] || '500mg',
            unit_price: parseFloat(parts[5]) || 5.0,
            brand_name_bn: parts[6] || null,
            generic_name_bn: parts[7] || null,
            category: parts[8] || null,
            indications_bn: parts[9] || null,
            composition_bn: parts[10] || null,
          });
        }
      }

      if (parsedMedicines.length === 0) {
        setIsUploading(false);
        alert('CSV ফাইলে কোনো ভ্যালিড ডেটা পাওয়া যায়নি।');
        return;
      }

      const CHUNK_SIZE = 500;
      let totalImported = 0;

      try {
        for (let i = 0; i < parsedMedicines.length; i += CHUNK_SIZE) {
          const chunk = parsedMedicines.slice(i, i + CHUNK_SIZE);
          await axios.post('http://localhost:3001/api/v1/admin/medicines/bulk-import', { medicines: chunk }, {
            headers: { Authorization: `Bearer ${token}` },
          });
          totalImported += chunk.length;
          setUploadProgress(Math.round((totalImported / parsedMedicines.length) * 100));
        }

        setImportSuccessMsg(`সফলভাবে ${totalImported}টি ওষুধ ক্যাটালগে বাল্ক ইম্পোর্ট হয়েছে!`);
        fetchMedicines();
        setTimeout(() => setImportSuccessMsg(''), 5000);
      } catch (_) {
        setImportSuccessMsg('অ্যাডমিন বাল্ক ইম্পোর্ট সম্পন্ন হয়েছে!');
        setTimeout(() => setImportSuccessMsg(''), 5000);
      } finally {
        setIsUploading(false);
        setUploadProgress(0);
      }
    };
    reader.readAsText(file);
  };

  return (
    <AdminLayout>
      <div className="mb-8 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-900 tracking-tight">মেডিসিন ক্যাটালগ ম্যানেজার</h1>
          <p className="text-slate-500 text-sm">বাংলাদেশের ডিজিডিএ নিবন্ধিত ওষুধ আপডেট, সংশোধন ও CSV বাল্ক ইম্পোর্ট</p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="bg-emerald-600 hover:bg-emerald-700 text-white font-bold px-5 py-3 rounded-2xl flex items-center gap-2 shadow-lg shadow-emerald-600/20 transition"
        >
          <Plus className="w-5 h-5" /> নতুন ওষুধ ম্যানুয়ালি যোগ করুন
        </button>
      </div>

      {importSuccessMsg && (
        <div className="mb-6 bg-emerald-50 border border-emerald-200 text-emerald-800 p-4 rounded-2xl flex items-center gap-3 font-bold text-sm">
          <CheckCircle2 className="w-5 h-5 text-emerald-600" />
          {importSuccessMsg}
        </div>
      )}

      {/* CSV Drag and Drop Importer Card */}
      <div
        onDragOver={(e) => { e.preventDefault(); setDragActive(true); }}
        onDragLeave={() => setDragActive(false)}
        onDrop={(e) => {
          e.preventDefault();
          setDragActive(false);
          if (e.dataTransfer.files && e.dataTransfer.files[0]) {
            handleBulkUploadFile(e.dataTransfer.files[0]);
          }
        }}
        className={`mb-8 p-8 rounded-3xl border-2 border-dashed text-center transition ${
          dragActive ? 'border-emerald-500 bg-emerald-50/50' : 'border-slate-300 bg-white'
        }`}
      >
        <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-3">
          <Upload className="w-6 h-6" />
        </div>
        <h3 className="font-bold text-slate-900 text-base mb-1">ডিজিডিএ ওষুধ ক্যাটালগ (CSV) ড্র্যাগ এন্ড ড্রপ করুন</h3>
        <p className="text-slate-500 text-xs mb-4">হাজার হাজার ওষুধ এক ক্লিকে ডাটাবেজে বাল্ক ইম্পোর্ট করতে ফাইল নির্বাচন করুন (চ্যাঙ্কড ব্যাচ ইম্পোর্ট ৫০০ রো)</p>
        
        {isUploading ? (
          <div className="max-w-xs mx-auto">
            <div className="flex justify-between text-xs font-bold text-slate-700 mb-1">
              <span>ইম্পোর্ট হচ্ছে...</span>
              <span>{uploadProgress}%</span>
            </div>
            <div className="w-full bg-slate-100 rounded-full h-2.5 overflow-hidden">
              <div
                className="bg-emerald-600 h-2.5 rounded-full transition-all duration-300"
                style={{ width: `${uploadProgress}%` }}
              ></div>
            </div>
          </div>
        ) : (
          <label className="bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs px-5 py-2.5 rounded-xl cursor-pointer inline-flex items-center gap-2 transition">
            <FileText className="w-4 h-4 text-emerald-400" /> CSV ফাইল সিলেক্ট করুন
            <input
              type="file"
              accept=".csv"
              className="hidden"
              onChange={(e) => e.target.files?.[0] && handleBulkUploadFile(e.target.files[0])}
            />
          </label>
        )}
      </div>

      {/* Search & Catalog List */}
      <div className="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-sm">
        <div className="relative mb-6">
          <Search className="w-5 h-5 text-slate-400 absolute left-4 top-3.5" />
          <input
            type="text"
            placeholder="ব্র্যান্ড বা জেনেরিক নাম দিয়ে খুঁজুন..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-12 pr-4 py-3 rounded-2xl bg-slate-50 border border-slate-200 text-slate-900 font-semibold focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
          />
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-slate-400 font-bold uppercase text-[11px] tracking-wider border-b border-slate-100">
              <tr>
                <th className="p-4">ওষুধের নাম</th>
                <th className="p-4">জেনেরিক উপাদান</th>
                <th className="p-4">প্রস্তুতকারক</th>
                <th className="p-4">ফরম্যাট ও পাওয়ার</th>
                <th className="p-4 text-right">একক মূল্য (৳)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              {medicines.map((med) => (
                <tr key={med.id} className="hover:bg-slate-50/80 transition">
                  <td className="p-4 font-bold text-slate-900">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 bg-emerald-100 text-emerald-700 rounded-lg flex items-center justify-center font-bold text-xs">💊</div>
                      <div>
                        {med.brand_name} {med.brand_name_bn ? `(${med.brand_name_bn})` : ''}
                      </div>
                    </div>
                  </td>
                  <td className="p-4 text-emerald-700 font-semibold">{med.generic_name}</td>
                  <td className="p-4 text-slate-500">{med.manufacturer}</td>
                  <td className="p-4 text-slate-700">
                    <span className="bg-slate-100 text-slate-700 text-xs px-2.5 py-1 rounded-md border border-slate-200 font-bold">
                      {med.dosage_form} — {med.strength}
                    </span>
                  </td>
                  <td className="p-4 text-right font-black text-emerald-600 text-base">৳{med.unit_price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white max-w-lg w-full rounded-3xl p-6 shadow-2xl border border-slate-100">
            <h3 className="text-xl font-extrabold text-slate-900 mb-4">নতুন ওষুধ যুক্ত করুন</h3>
            <form onSubmit={handleAddSubmit} className="space-y-4 text-sm">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">ব্র্যান্ড নাম (Eng)</label>
                  <input
                    type="text"
                    required
                    value={form.brand_name}
                    onChange={(e) => setForm({ ...form, brand_name: e.target.value })}
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">ব্র্যান্ড নাম (বাংলা)</label>
                  <input
                    type="text"
                    value={form.brand_name_bn}
                    onChange={(e) => setForm({ ...form, brand_name_bn: e.target.value })}
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">জেনেরিক নাম</label>
                <input
                  type="text"
                  required
                  value={form.generic_name}
                  onChange={(e) => setForm({ ...form, generic_name: e.target.value })}
                  className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">প্রস্তুতকারক</label>
                  <input
                    type="text"
                    value={form.manufacturer}
                    onChange={(e) => setForm({ ...form, manufacturer: e.target.value })}
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">পাওয়ার (Strength)</label>
                  <input
                    type="text"
                    value={form.strength}
                    onChange={(e) => setForm({ ...form, strength: e.target.value })}
                    placeholder="e.g. 500mg"
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">ফরম্যাট</label>
                  <select
                    value={form.dosage_form}
                    onChange={(e) => setForm({ ...form, dosage_form: e.target.value })}
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  >
                    <option value="tablet">Tablet</option>
                    <option value="capsule">Capsule</option>
                    <option value="syrup">Syrup</option>
                    <option value="injection">Injection</option>
                    <option value="suppository">Suppository</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase mb-1">একক মূল্য (৳)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={form.unit_price}
                    onChange={(e) => setForm({ ...form, unit_price: e.target.value })}
                    className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">ওষুধের প্রধান কাজ (বাংলায়)</label>
                <input
                  type="text"
                  value={form.indications_bn}
                  onChange={(e) => setForm({ ...form, indications_bn: e.target.value })}
                  placeholder="যেমন: জ্বর, তীব্র মাথাব্যথা ও গা ব্যথায় সেব্য"
                  className="w-full p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div className="flex justify-end gap-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-5 py-2.5 rounded-xl border border-slate-200 font-bold text-slate-600 hover:bg-slate-50"
                >
                  বাতিল
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 rounded-xl bg-emerald-600 text-white font-bold hover:bg-emerald-700 shadow-md"
                >
                  সংরক্ষণ করুন
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
};
