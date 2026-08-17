import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import {
  Search,
  Download,
  CheckCircle2,
  Smartphone,
  ChevronDown,
  ChevronUp,
  ShieldAlert,
  Calculator,
  Tag,
  ExternalLink,
  Pill,
  Layers,
  Activity,
  BellRing,
  Users2,
  FileCheck2,
  Sparkles,
  Star,
  ArrowRight,
  ShieldCheck,
  Check,
  Clock
} from 'lucide-react';

export const HomePage: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const [selectedMedicine, setSelectedMedicine] = useState<any>(null);
  const [alternativesData, setAlternativesData] = useState<any>(null);
  const [loadingAlts, setLoadingAlts] = useState(false);

  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const [dailyMedsCount, setDailyMedsCount] = useState(3);
  const [avgPrice, setAvgPrice] = useState(6);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const searchSectionRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  const popularSearches = ['Napa', 'Seclo', 'Sergel', 'Comet', 'Monas', 'Fexo', 'Amlodipine', 'Azithromycin'];

  useEffect(() => {
    if (!searchQuery.trim()) {
      setSearchResults([]);
      setShowDropdown(false);
      return;
    }

    const timer = setTimeout(() => {
      setIsSearching(true);
      axios
        .get(`http://localhost:3001/api/v1/medicines?q=${encodeURIComponent(searchQuery.trim())}&limit=8`)
        .then((res) => {
          if (res.data.success) {
            setSearchResults(res.data.data || []);
            setShowDropdown(true);
          }
        })
        .catch(() => setSearchResults([]))
        .finally(() => setIsSearching(false));
    }, 250);

    return () => clearTimeout(timer);
  }, [searchQuery]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const fetchAlternatives = (med: any) => {
    setSelectedMedicine(med);
    setShowDropdown(false);
    setLoadingAlts(true);
    axios
      .get(`http://localhost:3001/api/v1/medicines/${med.id}/alternatives`)
      .then((res) => {
        if (res.data.success) {
          setAlternativesData(res.data.data || res.data);
        }
      })
      .catch(() => setAlternativesData(null))
      .finally(() => setLoadingAlts(false));
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchResults.length > 0) {
      fetchAlternatives(searchResults[0]);
    } else if (searchQuery.trim()) {
      navigate(`/medicine/${encodeURIComponent(searchQuery.trim())}`);
    }
  };

  const handleQuickChipSearch = (term: string) => {
    setSearchQuery(term);
    setIsSearching(true);
    axios
      .get(`http://localhost:3001/api/v1/medicines?q=${encodeURIComponent(term)}&limit=8`)
      .then((res) => {
        if (res.data.success && res.data.data && res.data.data.length > 0) {
          fetchAlternatives(res.data.data[0]);
        }
      })
      .catch(() => {})
      .finally(() => setIsSearching(false));
  };

  const monthlyEstimate = dailyMedsCount * avgPrice * 30;
  const potentialSavings = Math.round(monthlyEstimate * 0.45);

  const faqs = [
    {
      question: 'ওষুধসাথী কি শতভাগ বিনামূল্যে ব্যবহার করা যায়?',
      answer: 'হ্যাঁ, ওষুধসাথী সম্পূর্ণ ফ্রি। মেডিসিন রিমাইন্ডার, বাংলা ভয়েস নোটিফিকেশন, ফ্যামিলি লিংক ও বিপি/সুগার ট্র্যাকিংয়ে কোনো ফি বা সাবস্ক্রিপশন নেই।',
    },
    {
      question: 'ইন্টারনেট সংযোগ ছাড়া কি ভয়েস অ্যালার্ট বাজবে?',
      answer: 'হ্যাঁ, অফলাইনেও ফোনের সিস্টেম অ্যালার্ম ইন্টিগ্রেশনের মাধ্যমে সময়মতো বাংলা ভয়েসে ওষুধ খাওয়ার অ্যালার্ট রিং হবে।',
    },
    {
      question: 'প্রবাস বা অন্য শহর থেকে কি স্বজনের ওষুধ খাওয়ার খবর রাখা যায়?',
      answer: 'অবশ্যই। অ্যাপের "ফ্যামিলি লিংক" দিয়ে যেকোনো স্থান থেকে বাবা-মা বা স্বজন সময়মতো ওষুধ খেয়াছেন কিনা তা লাইভ দেখতে পারবেন।',
    },
    {
      question: 'ওষুধের সস্তা বিকল্প কীভাবে কাজ করে?',
      answer: 'ঔষধ প্রশাসন অধিদপ্তর (DGDA) নিবন্ধিত একই রাসায়নিক উপাদান ও শক্তির অন্যান্য ব্র্যান্ডের মধ্যে যেসব ব্র্যান্ডের দাম কম, সেগুলো সরাসরি তুলনা করে দেওয়া হয়।',
    },
  ];

  return (
    <div className="min-h-screen bg-[#FAFCFB] font-sans text-slate-800 antialiased selection:bg-emerald-600 selection:text-white">
      {/* ─── Top Ambient Bar ──────────────────────────────────── */}
      <div className="bg-[#042F24] text-emerald-200 text-[12px] py-2 px-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between font-medium">
          <div className="flex items-center gap-2">
            <span className="bg-emerald-500/20 text-emerald-300 text-[10px] font-extrabold px-2 py-0.5 rounded-full border border-emerald-500/30 uppercase tracking-widest">
              DGDA Verified
            </span>
            <span>বাংলাদেশের মানুষের নির্ভরযোগ্য ডিজিটাল স্বাস্থ্য ও ওষুধ নির্দেশিকা</span>
          </div>
          <div className="hidden md:flex items-center gap-5 text-emerald-300/80 text-[11px]">
            <span className="flex items-center gap-1.5"><ShieldCheck className="w-3.5 h-3.5 text-emerald-400" /> ১০০% বিজ্ঞাপনমুক্ত</span>
            <span className="flex items-center gap-1.5"><CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> অফলাইন নোটিফিকেশন</span>
          </div>
        </div>
      </div>

      {/* ─── Glass Navigation Header ──────────────────────────── */}
      <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-xl border-b border-slate-100">
        <div className="max-w-6xl mx-auto px-4 py-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3 cursor-pointer group" onClick={() => navigate('/')}>
            <div className="w-9 h-9 bg-gradient-to-br from-emerald-500 to-emerald-700 text-white rounded-xl flex items-center justify-center shadow-md shadow-emerald-600/20 group-hover:scale-105 transition-transform">
              <Pill className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <span className="text-xl font-black text-slate-900 tracking-tight leading-none">ওষুধসাথী</span>
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              </div>
              <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-widest">OshudhSathi</span>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-8 text-slate-600 font-semibold text-xs tracking-wide">
            <a href="#features" className="hover:text-emerald-700 transition-colors">সুবিধাসমূহ</a>
            <a href="#search" className="hover:text-emerald-700 transition-colors">ওষুধ ও বিকল্প</a>
            <a href="#calculator" className="hover:text-emerald-700 transition-colors">বাজেট ক্যালকুলেটর</a>
            <a href="#faq" className="hover:text-emerald-700 transition-colors">প্রশ্নোত্তর</a>
          </nav>

          <a
            href="#download"
            className="bg-emerald-600 hover:bg-emerald-500 text-white px-5 py-2.5 rounded-full font-bold text-xs shadow-lg shadow-emerald-600/20 hover:shadow-emerald-600/30 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center gap-2"
          >
            <Download className="w-3.5 h-3.5" />
            <span>অ্যাপ নামান</span>
          </a>
        </div>
      </header>

      {/* ─── Hero Section ────────────────────────────────────── */}
      <section className="relative pt-12 pb-20 md:pt-20 md:pb-28 overflow-hidden">
        {/* Subtle Background Glow Spheres */}
        <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[600px] h-[300px] bg-emerald-400/10 blur-[120px] rounded-full pointer-events-none -z-10 animate-pulse-glow"></div>

        <div className="max-w-6xl mx-auto px-4 grid lg:grid-cols-12 gap-12 items-center">
          {/* Hero Left Content */}
          <div className="lg:col-span-7 space-y-6">
            <div className="inline-flex items-center gap-2 bg-emerald-50 text-emerald-800 px-3.5 py-1.5 rounded-full text-xs font-bold shadow-xs">
              <Sparkles className="w-3.5 h-3.5 text-emerald-600" />
              <span>পরিবারের সিনিয়রদের ওষুধ সেবনে শতভাগ নিশ্চিন্ততা</span>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-slate-900 leading-[1.15] tracking-tight">
              সময়মতো ওষুধ সেবন,{' '}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 to-teal-700">
                সুস্থ থাকুন প্রতিদিন
              </span>
            </h1>

            <p className="text-slate-600 text-base sm:text-lg leading-relaxed font-normal max-w-xl">
              বাংলা ভয়েস অ্যালার্ট, বিদেশে বা দূরে থেকে স্বজনের লাইভ কেয়ার ট্র্যাকিং এবং ডিজিডিএ নিবন্ধিত ওষুধ ও কম দামি জেনেরিক বিকল্পের স্মার্ট নির্দেশিকা।
            </p>

            {/* Action Buttons */}
            <div id="download" className="flex flex-col sm:flex-row gap-3 pt-2">
              <a
                href="#playstore"
                className="bg-slate-900 hover:bg-slate-800 text-white px-6 py-3.5 rounded-2xl font-bold text-xs shadow-xl hover:shadow-2xl transition-all transform hover:-translate-y-0.5 flex items-center gap-3 group"
              >
                <div className="w-8 h-8 bg-slate-800 group-hover:bg-slate-700 rounded-xl flex items-center justify-center text-emerald-400 transition">
                  <Smartphone className="w-4 h-4" />
                </div>
                <div className="text-left leading-tight">
                  <span className="text-[10px] text-slate-400 block uppercase">ডাউনলোড করুন</span>
                  <span className="text-sm font-extrabold">Google Play Store</span>
                </div>
              </a>

              <a
                href="#apk"
                className="bg-white hover:bg-emerald-50/50 text-slate-800 border border-slate-200/80 px-6 py-3.5 rounded-2xl font-bold text-xs shadow-xs hover:shadow-md transition-all flex items-center gap-3 group"
              >
                <div className="w-8 h-8 bg-emerald-100/70 text-emerald-700 rounded-xl flex items-center justify-center">
                  <Download className="w-4 h-4" />
                </div>
                <div className="text-left leading-tight">
                  <span className="text-[10px] text-emerald-700 block uppercase">ডাইরেক্ট ইনস্টল</span>
                  <span className="text-sm font-extrabold text-slate-900">Download APK (v2.4)</span>
                </div>
              </a>
            </div>

            {/* Metric Ratings */}
            <div className="flex items-center gap-6 text-xs text-slate-500 pt-4">
              <div className="flex items-center gap-1.5 font-bold text-slate-700">
                <div className="flex text-amber-400">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-3.5 h-3.5 fill-amber-400" />
                  ))}
                </div>
                <span className="ml-1 text-sm font-black text-slate-900">৪.৯/৫</span>
                <span className="text-slate-400 font-normal text-[11px]">(১০,০০০+ পরিবার)</span>
              </div>
            </div>
          </div>

          {/* Hero Right Floating Device Card */}
          <div className="lg:col-span-5 relative">
            <div className="bg-white/90 backdrop-blur-xl rounded-3xl p-6 shadow-premium-lg border border-slate-100 animate-float">
              {/* Header */}
              <div className="flex items-center justify-between pb-4 mb-4 border-b border-slate-100">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-emerald-100 text-emerald-700 rounded-2xl flex items-center justify-center font-bold text-lg">
                    👵
                  </div>
                  <div>
                    <span className="text-[11px] text-slate-400 font-bold uppercase block tracking-wider">লাইভ কেয়ার ড্যাশবোর্ড</span>
                    <h4 className="font-extrabold text-slate-900 text-sm">আম্মার আজকের ওষুধ সূচি</h4>
                  </div>
                </div>
                <span className="bg-emerald-50 text-emerald-700 text-[10px] font-bold px-2.5 py-1 rounded-full border border-emerald-200/60 flex items-center gap-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-ping"></span>
                  সক্রিয়
                </span>
              </div>

              {/* Today's Schedule Cards */}
              <div className="space-y-3">
                <div className="p-3.5 bg-emerald-50/60 rounded-2xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-emerald-600 text-white rounded-xl flex items-center justify-center">
                      <Check className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="font-bold text-slate-900 text-xs">Comet 500mg (Metformin)</p>
                      <p className="text-[11px] text-slate-500">সকাল ৮:০০ — নাস্তার পর (১টি)</p>
                    </div>
                  </div>
                  <span className="bg-emerald-600 text-white text-[10px] font-bold px-2 py-1 rounded-lg">
                    খেয়েছেন
                  </span>
                </div>

                <div className="p-3.5 bg-amber-50/80 rounded-2xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-amber-500 text-white rounded-xl flex items-center justify-center">
                      <Clock className="w-4 h-4 animate-spin" />
                    </div>
                    <div>
                      <p className="font-bold text-slate-900 text-xs">Sergel 20mg (Esomeprazole)</p>
                      <p className="text-[11px] text-slate-500">দুপুর ১:৩০ — নাস্তার পূর্বে</p>
                    </div>
                  </div>
                  <span className="bg-amber-500 text-white text-[10px] font-bold px-2 py-1 rounded-lg">
                    এখনই সেব্য
                  </span>
                </div>

                <div className="p-3.5 bg-slate-50 rounded-2xl flex items-center justify-between opacity-75">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-slate-200 text-slate-600 rounded-xl flex items-center justify-center">
                      <Pill className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="font-bold text-slate-900 text-xs">Lodipin 5mg (Amlodipine)</p>
                      <p className="text-[11px] text-slate-500">রাত ৯:৩০ — ঘুমানোর আগে</p>
                    </div>
                  </div>
                  <span className="text-[10px] font-bold text-slate-400">
                    পরবর্তী
                  </span>
                </div>
              </div>

              {/* Family Care Indicator */}
              <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600">
                <span className="flex items-center gap-1.5 font-medium text-emerald-800 text-[11px]">
                  <Users2 className="w-3.5 h-3.5 text-emerald-600" /> ফ্যামিলি লিঙ্ক: রফিকুল (ছেলে, ঢাকা)
                </span>
                <span className="text-slate-400 font-semibold text-[10px]">লাইভ সিঙ্কড</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ─── Search & Generic Alternatives Section ───────────────── */}
      <section id="search" ref={searchSectionRef} className="py-16 md:py-24 bg-white">
        <div className="max-w-5xl mx-auto px-4">
          <div className="text-center max-w-2xl mx-auto mb-10 space-y-3">
            <span className="bg-emerald-100/70 text-emerald-800 text-[11px] font-bold px-3 py-1 rounded-full uppercase tracking-widest">
              ওষুধ ডিরেক্টরি
            </span>
            <h2 className="text-3xl md:text-4xl font-black text-slate-900 tracking-tight">
              ওষুধের কাজ, উপাদান ও সস্তা বিকল্প খুঁজুন
            </h2>
            <p className="text-slate-600 text-sm">
              প্রেসক্রিপশনের ওষুধের নাম টাইপ করুন। ওষুধটির কাজ, উপাদান ও একই উপাদানের সস্তা বিকল্পের তালিকা জানুন।
            </p>
          </div>

          {/* Search Box */}
          <div className="relative max-w-2xl mx-auto" ref={dropdownRef}>
            <form onSubmit={handleSearchSubmit} className="flex flex-col sm:flex-row gap-2.5">
              <div className="relative flex-1">
                <Search className="w-5 h-5 text-slate-400 absolute left-4 top-3.5" />
                <input
                  type="text"
                  placeholder="যেমন: Napa, Seclo, Sergel, Monas, Fexo, Amlodipine..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  onFocus={() => searchResults.length > 0 && setShowDropdown(true)}
                  className="w-full pl-12 pr-4 py-3.5 rounded-2xl bg-slate-50 border-0 focus:bg-white text-slate-900 font-semibold focus:outline-none focus:ring-2 focus:ring-emerald-500/40 text-sm shadow-premium transition-all"
                />
                {isSearching && (
                  <div className="absolute right-4 top-3.5">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-emerald-600"></div>
                  </div>
                )}
              </div>
              <button
                type="submit"
                className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold px-6 py-3.5 rounded-2xl flex items-center justify-center gap-2 transition shadow-md shadow-emerald-600/20 text-xs uppercase tracking-wider"
              >
                <span>সার্চ করুন</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </form>

            {/* Dropdown Menu */}
            {showDropdown && searchResults.length > 0 && (
              <div className="absolute left-0 right-0 top-full mt-2 bg-white rounded-2xl shadow-2xl border border-slate-100 z-50 max-h-80 overflow-y-auto divide-y divide-slate-100">
                {searchResults.map((med) => (
                  <div
                    key={med.id}
                    onClick={() => fetchAlternatives(med)}
                    className="p-4 hover:bg-emerald-50/60 cursor-pointer transition flex items-center justify-between"
                  >
                    <div>
                      <p className="font-bold text-slate-900 text-sm">
                        {med.brand_name} <span className="text-xs font-medium text-slate-500">({med.strength})</span>
                      </p>
                      <p className="text-xs text-emerald-700 font-semibold">{med.generic_name}</p>
                      <p className="text-[11px] text-slate-400">{med.manufacturer}</p>
                    </div>
                    <div className="text-right">
                      <span className="text-emerald-700 font-black text-base block">৳{med.unit_price}</span>
                      <span className="text-[10px] text-slate-400 block">প্রতি পিস ({med.dosage_form})</span>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Quick Chips */}
            <div className="flex flex-wrap items-center justify-center gap-2 mt-4">
              <span className="text-[11px] font-medium text-slate-400">দ্রুত খুঁজুন:</span>
              {popularSearches.map((term) => (
                <button
                  key={term}
                  onClick={() => handleQuickChipSearch(term)}
                  className="bg-slate-100 hover:bg-emerald-100/60 hover:text-emerald-800 text-slate-600 text-xs font-medium px-3 py-1 rounded-full transition"
                >
                  {term}
                </button>
              ))}
            </div>
          </div>

          {/* Selected Medicine Details */}
          {loadingAlts && (
            <div className="mt-10 text-center py-8">
              <div className="animate-spin rounded-full h-7 w-7 border-b-2 border-emerald-600 mx-auto mb-2"></div>
              <p className="text-emerald-700 font-bold text-xs">ওষুধের কাজ ও সস্তা বিকল্প লোড হচ্ছে...</p>
            </div>
          )}

          {selectedMedicine && !loadingAlts && (
            <div className="mt-10 bg-white rounded-3xl p-6 md:p-8 shadow-premium-lg border border-slate-100 space-y-6">
              {/* Header Details */}
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="bg-emerald-100 text-emerald-800 text-[10px] font-extrabold uppercase px-2.5 py-1 rounded-full mb-2 inline-block">
                    ওষুধ বিবরণী
                  </span>
                  <h3 className="text-2xl md:text-3xl font-black text-slate-900">
                    {selectedMedicine.brand_name} {selectedMedicine.brand_name_bn ? `(${selectedMedicine.brand_name_bn})` : ''}
                  </h3>
                  <p className="text-emerald-700 font-bold text-sm mt-1">
                    জেনেরিক উপাদান: {selectedMedicine.generic_name}
                  </p>
                  <p className="text-slate-500 text-xs mt-0.5">কোম্পানি: {selectedMedicine.manufacturer}</p>
                </div>

                <div className="bg-slate-50 p-4 rounded-2xl text-right flex-shrink-0">
                  <span className="text-[10px] text-slate-400 font-bold uppercase block">একক মূল্য (MRP)</span>
                  <span className="text-3xl font-black text-emerald-600">৳{selectedMedicine.unit_price}</span>
                  <span className="text-xs text-slate-400 block">/ পিস ({selectedMedicine.dosage_form} — {selectedMedicine.strength})</span>
                </div>
              </div>

              {/* Strengths Bar */}
              {selectedMedicine.variants && selectedMedicine.variants.length > 1 && (
                <div className="bg-slate-50/80 p-4 rounded-2xl">
                  <span className="text-xs font-bold text-slate-700 uppercase tracking-wider block mb-2 flex items-center gap-1.5">
                    <Layers className="w-3.5 h-3.5 text-emerald-600" /> উপলব্ধ পাওয়ার ও ভ্যারিয়েন্ট:
                  </span>
                  <div className="flex flex-wrap gap-2">
                    {selectedMedicine.variants.map((v: any) => {
                      const isCurrent = v.id === selectedMedicine.id;
                      return (
                        <button
                          key={v.id}
                          onClick={() => fetchAlternatives(v)}
                          className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition flex items-center gap-2 ${
                            isCurrent
                              ? 'bg-emerald-600 text-white shadow-xs'
                              : 'bg-white text-slate-700 hover:bg-slate-100'
                          }`}
                        >
                          <Pill className="w-3 h-3" />
                          <span>{v.brand_name} ({v.strength})</span>
                          <span className="opacity-80">৳{v.unit_price}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* Indications & Composition */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-slate-50/80 p-4 rounded-2xl">
                  <h4 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-1.5 mb-1.5">
                    <Activity className="w-3.5 h-3.5 text-amber-600" /> ওষুধের মূল কাজ (Indications):
                  </h4>
                  <p className="text-slate-700 text-xs leading-relaxed">
                    {selectedMedicine.indications_bn || selectedMedicine.indications || 'জ্বর, ব্যথা ও অসুস্থতায় রেজিস্টার্ড চিকিৎসকের পরামর্শে সেবনযোগ্য।'}
                  </p>
                </div>

                <div className="bg-slate-50/80 p-4 rounded-2xl">
                  <h4 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-1.5 mb-1.5">
                    <Pill className="w-3.5 h-3.5 text-sky-600" /> রাসায়নিক উপাদান (Composition):
                  </h4>
                  <p className="text-slate-700 text-xs leading-relaxed">
                    {selectedMedicine.composition_bn || selectedMedicine.composition || `সক্রিয় উপাদান: ${selectedMedicine.generic_name} ${selectedMedicine.strength}`}
                  </p>
                </div>
              </div>

              {/* Generic Alternatives Grid */}
              <div className="pt-2">
                <div className="flex items-center justify-between mb-4">
                  <h4 className="text-base font-extrabold text-slate-900 flex items-center gap-2">
                    <Tag className="w-4 h-4 text-emerald-600" />
                    একই উপাদানের কম দামি বিকল্প ব্র্যান্ড ({alternativesData?.alternatives?.length || 0} টি বিকল্প পাওয়া গেছে):
                  </h4>
                  <button
                    onClick={() => navigate(`/medicine/${encodeURIComponent(selectedMedicine.brand_name)}`)}
                    className="text-xs font-bold text-emerald-700 hover:underline flex items-center gap-1"
                  >
                    সম্পূর্ণ তালিকা <ExternalLink className="w-3 h-3" />
                  </button>
                </div>

                {!alternativesData?.alternatives || alternativesData.alternatives.length === 0 ? (
                  <p className="text-slate-500 text-xs py-4 bg-slate-50 p-4 rounded-2xl">
                    এই জেনেরিকের বিকল্প অন্য কোনো ব্র্যান্ড ডাটাবেজে বর্তমানে নিবন্ধিত নেই।
                  </p>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-h-[380px] overflow-y-auto pr-1">
                    {alternativesData.alternatives.map((alt: any) => {
                      const savingsPerPiece = (selectedMedicine.unit_price - alt.unit_price).toFixed(2);
                      const savingsPercent = selectedMedicine.unit_price > 0 && alt.unit_price < selectedMedicine.unit_price
                        ? Math.round(((selectedMedicine.unit_price - alt.unit_price) / selectedMedicine.unit_price) * 100)
                        : 0;

                      return (
                        <div
                          key={alt.id}
                          className="bg-slate-50/70 p-4 rounded-2xl hover:bg-emerald-50/40 transition flex flex-col justify-between"
                        >
                          <div>
                            <div className="flex items-center justify-between mb-1">
                              <span className="text-[10px] font-bold text-emerald-800 uppercase">
                                বিকল্প ব্র্যান্ড
                              </span>
                              {savingsPercent > 0 && (
                                <span className="bg-amber-100 text-amber-900 text-[10px] font-bold px-2 py-0.5 rounded-full">
                                  {savingsPercent}% কম দাম
                                </span>
                              )}
                            </div>
                            <h5 className="font-bold text-slate-900 text-sm">
                              {alt.brand_name} <span className="text-xs text-slate-500 font-normal">({alt.strength})</span>
                            </h5>
                            <p className="text-xs text-slate-400 mt-0.5">{alt.manufacturer}</p>
                          </div>

                          <div className="mt-3 pt-2 border-t border-slate-200/60 flex justify-between items-end">
                            <div>
                              {Number(savingsPerPiece) > 0 ? (
                                <span className="text-[11px] font-bold text-amber-700 block">
                                  সাশ্রয়: ৳{savingsPerPiece}/পিস
                                </span>
                              ) : (
                                <span className="text-[11px] text-slate-400 block">সমমূল্য</span>
                              )}
                            </div>
                            <div className="text-right">
                              <span className="text-lg font-black text-emerald-600 block">৳{alt.unit_price}</span>
                              <span className="text-[10px] text-slate-400 block">প্রতি পিস</span>
                            </div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </section>

      {/* ─── Product Features Grid ────────────────────────────── */}
      <section id="features" className="py-20 bg-[#FAFCFB]">
        <div className="max-w-6xl mx-auto px-4">
          <div className="text-center max-w-2xl mx-auto mb-16 space-y-3">
            <span className="bg-emerald-100/70 text-emerald-800 text-[11px] font-bold px-3 py-1 rounded-full uppercase tracking-widest">
              সুবিধাসমূহ
            </span>
            <h2 className="text-3xl md:text-4xl font-black text-slate-900 tracking-tight">
              কেন ওষুধসাথী আপনার পরিবারের নির্ভরযোগ্য সাথি?
            </h2>
            <p className="text-slate-600 text-sm">
              বাংলাদেশের সিনিয়র নাগরিক ও পরিবারের স্বাস্থ্য নিরাপত্তার চাহিদার কথা ভেবে আমরা প্রতিটি ফিচার তৈরি করেছি।
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Feature 1 */}
            <div className="bg-white p-7 rounded-3xl shadow-premium hover:shadow-premium-lg hover:-translate-y-1 transition-all duration-300">
              <div className="w-11 h-11 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center mb-5">
                <BellRing className="w-5 h-5" />
              </div>
              <h3 className="font-extrabold text-lg mb-2 text-slate-900">বাংলা ভয়েস অ্যালার্ট</h3>
              <p className="text-slate-600 text-xs leading-relaxed font-normal">
                বয়স্ক মানুষেরাও সহজে বুঝতে পারবেন। সময় হলেই ফোন স্পিকারে স্পষ্ট বাংলায় বলে দেবে কোন ওষুধটি কতটুকু খেতে হবে।
              </p>
            </div>

            {/* Feature 2 */}
            <div className="bg-white p-7 rounded-3xl shadow-premium hover:shadow-premium-lg hover:-translate-y-1 transition-all duration-300">
              <div className="w-11 h-11 bg-sky-50 text-sky-600 rounded-2xl flex items-center justify-center mb-5">
                <Users2 className="w-5 h-5" />
              </div>
              <h3 className="font-extrabold text-lg mb-2 text-slate-900">ফ্যামিলি শেয়ারিং</h3>
              <p className="text-slate-600 text-xs leading-relaxed font-normal">
                ঢাকা বা বিদেশে থেকেও আপনার বাবা-মা আজ ওষুধ খেয়াছেন কিনা বা মিস করেছেন কিনা তা লাইভ নোটিফিকেশনে দেখতে পারবেন।
              </p>
            </div>

            {/* Feature 3 */}
            <div className="bg-white p-7 rounded-3xl shadow-premium hover:shadow-premium-lg hover:-translate-y-1 transition-all duration-300">
              <div className="w-11 h-11 bg-amber-50 text-amber-600 rounded-2xl flex items-center justify-center mb-5">
                <Activity className="w-5 h-5" />
              </div>
              <h3 className="font-extrabold text-lg mb-2 text-slate-900">বিপি ও সুগার ট্র্যাকার</h3>
              <p className="text-slate-600 text-xs leading-relaxed font-normal">
                প্রতিদিনের প্রেসার ও রক্তের সুগার রিডিং ইনপুট দিন। ১-ক্লিকে ডাক্তারের দেখার জন্য সুন্দর PDF স্বাস্থ্য রিপোর্ট পান।
              </p>
            </div>

            {/* Feature 4 */}
            <div className="bg-white p-7 rounded-3xl shadow-premium hover:shadow-premium-lg hover:-translate-y-1 transition-all duration-300">
              <div className="w-11 h-11 bg-purple-50 text-purple-600 rounded-2xl flex items-center justify-center mb-5">
                <FileCheck2 className="w-5 h-5" />
              </div>
              <h3 className="font-extrabold text-lg mb-2 text-slate-900">প্রেসক্রিপশন ভল্ট</h3>
              <p className="text-slate-600 text-xs leading-relaxed font-normal">
                মোবাইলে ছবি তুলে আপনার ও পরিবারের সব পুরনো প্রেসক্রিপশন ও টেস্ট রিপোর্ট বছরের পর বছর ক্লাউডে সুরক্ষিত রাখুন।
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ─── Interactive Budget Calculator Section ────────────── */}
      <section id="calculator" className="py-20 bg-white">
        <div className="max-w-4xl mx-auto px-4">
          <div className="bg-[#0B1A15] text-white p-8 md:p-12 rounded-3xl shadow-2xl relative overflow-hidden">
            <div className="max-w-xl space-y-2 mb-8">
              <div className="inline-flex items-center gap-2 bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-3 py-1 rounded-full text-xs font-bold">
                <Calculator className="w-3.5 h-3.5 text-emerald-400" />
                <span>মেডিসিন বাজেট ক্যালকুলেটর</span>
              </div>
              <h2 className="text-3xl font-black tracking-tight">মাসিক ওষুধ খরচ ও সাশ্রয় হিসাব করুন</h2>
              <p className="text-slate-300 text-xs leading-relaxed">
                প্রতিদিনের ওষুধ সংখ্যা ও গড় দাম পরিবর্তন করে আপনার আনুমানিক মাসিক ব্যয় ও বিকল্পের সম্ভাব্য সাশ্রয় দেখুন:
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-8 items-center">
              <div className="space-y-6">
                <div>
                  <label className="block text-xs font-bold text-emerald-300 uppercase tracking-wider mb-2">
                    প্রতিদিন কয়টি ওষুধ খান? ({dailyMedsCount} টি)
                  </label>
                  <div className="flex gap-2">
                    {[1, 2, 3, 4, 5, 6].map((num) => (
                      <button
                        key={num}
                        onClick={() => setDailyMedsCount(num)}
                        className={`flex-1 py-2.5 rounded-xl font-bold text-xs transition ${
                          dailyMedsCount === num
                            ? 'bg-emerald-500 text-slate-950 shadow-md'
                            : 'bg-white/10 text-white hover:bg-white/20'
                        }`}
                      >
                        {num}টি
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-bold text-emerald-300 uppercase tracking-wider mb-2">
                    <span>প্রতিটি ওষুধের গড় দাম:</span>
                    <span className="text-emerald-400 font-extrabold text-sm">৳{avgPrice}</span>
                  </div>
                  <input
                    type="range"
                    min="2"
                    max="50"
                    value={avgPrice}
                    onChange={(e) => setAvgPrice(Number(e.target.value))}
                    className="w-full accent-emerald-400 h-2 bg-white/20 rounded-lg cursor-pointer"
                  />
                </div>
              </div>

              {/* Result Badge */}
              <div className="bg-white/10 backdrop-blur-md p-6 rounded-2xl text-center space-y-1">
                <span className="text-xs text-slate-300 block uppercase">আনুমানিক মাসিক খরচ</span>
                <p className="text-4xl font-black text-white">৳{monthlyEstimate}</p>
                <span className="text-[11px] text-slate-400 block pb-3">প্রতি মাসে (৩০ দিন)</span>

                <div className="bg-emerald-500/20 p-3 rounded-xl text-emerald-200 text-xs flex items-center justify-between font-medium">
                  <span>বিকল্পে সম্ভাব্য সাশ্রয়:</span>
                  <span className="font-black text-emerald-300 text-sm">৳{potentialSavings}+ / মাস</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ─── FAQ Accordion Section ───────────────────────────── */}
      <section id="faq" className="max-w-4xl mx-auto px-4 py-20">
        <div className="text-center mb-12 space-y-2">
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">সাধারণ প্রশ্ন ও উত্তর (FAQ)</h2>
          <p className="text-slate-600 text-xs">ওষুধসাথী অ্যাপ ব্যবহার সংক্রান্ত প্রয়োজনীয় তথ্য</p>
        </div>

        <div className="space-y-3">
          {faqs.map((faq, idx) => {
            const isOpen = openFaq === idx;
            return (
              <div
                key={idx}
                className="bg-white rounded-2xl border-0 shadow-xs overflow-hidden transition"
              >
                <button
                  onClick={() => setOpenFaq(isOpen ? null : idx)}
                  className="w-full p-5 text-left font-bold text-slate-900 flex justify-between items-center gap-4 hover:bg-slate-50 transition text-sm"
                >
                  <span>{faq.question}</span>
                  {isOpen ? (
                    <ChevronUp className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-slate-400 flex-shrink-0" />
                  )}
                </button>
                {isOpen && (
                  <div className="px-5 pb-5 text-slate-600 text-xs leading-relaxed border-t border-slate-100 pt-3">
                    {faq.answer}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </section>

      {/* ─── Medical Disclaimer Banner ───────────────────────── */}
      <div className="max-w-4xl mx-auto px-4 mb-20">
        <div className="bg-amber-50/80 p-4 rounded-2xl flex items-start gap-3 text-amber-900 text-xs leading-relaxed">
          <ShieldAlert className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
          <div>
            <strong>জরুরি ডাক্তারি সতর্কবার্তা:</strong> ওষুধসাথী (OshudhSathi) একটি ডিজিটাল সেবন অনুস্মারক ও তথ্য নির্দেশিকা মাত্র। এটি কোনো চিকিৎসকের বিকল্প নয়। নতুন যেকোনো ওষুধ সেবন বা মাত্রা পরিবর্তনের পূর্বে অবশ্যই রেজিস্টার্ড ডাক্তারের পরামর্শ নিন।
          </div>
        </div>
      </div>

      {/* ─── Sleek Footer ────────────────────────────────────── */}
      <footer className="bg-[#042F24] text-emerald-200/80 py-12">
        <div className="max-w-6xl mx-auto px-4">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6 pb-8 border-b border-emerald-900/60">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 bg-emerald-600 text-white rounded-xl flex items-center justify-center font-bold">
                <Pill className="w-5 h-5" />
              </div>
              <div>
                <span className="text-xl font-black text-white tracking-tight leading-none block">ওষুধসাথী</span>
                <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest">OshudhSathi</span>
              </div>
            </div>

            <div className="flex items-center gap-6 text-xs text-emerald-300 font-semibold">
              <a href="#features" className="hover:text-white transition-colors">সুবিধাসমূহ</a>
              <a href="#search" className="hover:text-white transition-colors">ওষুধ সার্চ</a>
              <a href="#calculator" className="hover:text-white transition-colors">ক্যালকুলেটর</a>
              <a href="#faq" className="hover:text-white transition-colors">প্রশ্নোত্তর</a>
            </div>
          </div>

          <div className="pt-6 text-center md:flex md:justify-between md:items-center text-xs text-emerald-400/60">
            <p>© 2026 OshudhSathi (ওষুধসাথী)। সর্বস্বত্ব সংরক্ষিত।</p>
            <p className="mt-2 md:mt-0">DGDA নিবন্ধিত ওষুধ ডিরেক্টরি দ্বারা চালিত</p>
          </div>
        </div>
      </footer>
    </div>
  );
};
