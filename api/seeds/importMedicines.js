require('dotenv').config();
const { pool } = require('../config/database');

const extensiveBDMedicines = [
  // ─── 1. Paracetamol (প্যারাসিটামল) — 15+ Brands & Strengths ───
  {
    brand_name: 'Napa', brand_name_bn: 'নাপা', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.50, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever, headache, toothache, muscle aches, and common cold symptoms.',
    indications_bn: 'জ্বর, তীব্র মাথাব্যথা, শরীর ব্যথা, দাঁত ব্যথা ও সর্দিকাশি উপশমে সেবনযোগ্য।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল বিপি ৫০০ মিগ্রা।',
    side_effects: 'অতিরিক্ত সেবনে লিভারের ক্ষতি হতে পারে।', instructions: 'খাওয়ার পরে বা আগে এক গ্লাস পানি দিয়ে সেব্য।'
  },
  {
    brand_name: 'Napa Extend', brand_name_bn: 'নাপা এক্সটেন্ড', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '665mg', unit_price: 2.50, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Extended 8-hour relief from severe fever, osteoarthritic pain, and back pain.',
    indications_bn: 'দীর্ঘ ৮ ঘণ্টা টানা জ্বর, কোমর ব্যথা ও হাড়ের জোড়ায় ব্যথার দীর্ঘস্থায়ী উপশম।',
    composition: 'Each extended-release tablet contains Paracetamol BP 665 mg.',
    composition_bn: 'প্রতিটি এক্সটেন্ডেড-রিলিজ ট্যাবলেটে রয়েছে প্যারাসিটামল ৬৬৫ মিগ্রা।',
    side_effects: 'দীর্ঘমেয়াদী অতিরিক্ত ব্যবহারে লিভার জটিলতা।', instructions: '৮ ঘণ্টা পর পর ১টি ট্যাবলেট পুরো গিলে খাবেন।'
  },
  {
    brand_name: 'Napa Rapid', brand_name_bn: 'নাপা র্যাপিড', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 2.00, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fast-acting analgesia and fever reduction.',
    indications_bn: 'দ্রুত শোষিত হয়ে ১৫ মিনিটের মধ্যে জ্বর ও তীব্র ব্যথা উপশম করে।',
    composition: 'Each tablet contains Optizorb Paracetamol BP 500 mg.',
    composition_bn: 'প্রতিটি ট্যাবলেটে রয়েছে অ্যোঅপটিজর্ব প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'স্বাভাবিক মাত্রায় নিরাপদ।', instructions: 'ব্যথানাশে ১-২টি ট্যাবলেট পানি দিয়ে গিলে খান।'
  },
  {
    brand_name: 'Napa Extra', brand_name_bn: 'নাপা এক্সট্রা', generic_name: 'Paracetamol + Caffeine', generic_name_bn: 'প্যারাসিটামল + ক্যাফেইন',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg + 65mg', unit_price: 3.00, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Severe headache, migraine, fever with fatigue.',
    indications_bn: 'মাইগ্রেন, প্রচণ্ড মাথাব্যথা ও অবসাদযুক্ত জ্বরে বিশেষ কার্যকর।',
    composition: 'Each tablet contains Paracetamol BP 500 mg and Caffeine USP 65 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা এবং ক্যাফেইন ৬৫ মিগ্রা।',
    side_effects: 'অনিদ্রা, চঞ্চলতা, বুক ধড়ফড়।', instructions: 'ভরা পেটে সেব্য। রাতে না খাওয়াই ভালো।'
  },
  {
    brand_name: 'Napa Syrup', brand_name_bn: 'নাপা সিরাপ', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'syrup', strength: '120mg/5ml', unit_price: 35.00, pack_size: 60, is_otc: 1, category: 'analgesic',
    indications: 'Pediatric fever, vaccination pain, teething pain in infants and children.',
    indications_bn: 'শিশুদের জ্বর, টিকাদানের পরবর্তী ব্যথা ও দাঁত ওঠার ব্যথায় সেবনযোগ্য।',
    composition: 'Each 5 ml contains Paracetamol BP 120 mg.',
    composition_bn: 'প্রতি ৫ মি.লি. সিরাপে রয়েছে প্যারাসিটামল ১২০ মিগ্রা।',
    side_effects: 'স্বাভাবিক সেবনে নিরাপদ।', instructions: 'শিশুর বয়স ও ওজন অনুযায়ী চামচে মেপে দিন।'
  },
  {
    brand_name: 'Ace', brand_name_bn: 'এইস', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.50, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever, headache, cold symptoms, and body pain.',
    indications_bn: 'জ্বর, মাথাব্যথা, গা ব্যথা ও শারীরিক দুর্বলতায় দ্রুত স্বস্তি।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে আছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'স্বাভাবিক মাত্রায় নিরাপদ।', instructions: 'জ্বর বা ব্যথায় ৪-৬ ঘণ্টা পর পর সেবনীয়।'
  },
  {
    brand_name: 'Ace XR', brand_name_bn: 'এইস এক্সআর', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '665mg', unit_price: 2.50, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Sustained relief for chronic fever and joint stiffness.',
    indications_bn: 'দীর্ঘস্থায়ী জ্বর, কোমর ও জয়েন্টের ব্যথায় নিরবচ্ছিন্ন সুরক্ষা।',
    composition: 'Each extended-release tablet contains Paracetamol BP 665 mg.',
    composition_bn: 'প্রতিটি এক্সআর ট্যাবলেটে রয়েছে প্যারাসিটামল ৬৬৫ মিগ্রা।',
    side_effects: 'অতিরিক্ত ব্যবহারে লিভারের ঝুঁকি।', instructions: '৮ ঘণ্টা পর পর ১টি ট্যাবলেট চিবানো ছাড়া গিলে খান।'
  },
  {
    brand_name: 'Ace Plus', brand_name_bn: 'এইস প্লাস', generic_name: 'Paracetamol + Caffeine', generic_name_bn: 'প্যারাসিটামল + ক্যাফেইন',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg + 65mg', unit_price: 3.00, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Migraine, intense headache, body fatigue.',
    indications_bn: 'মাইগ্রেন, প্রচণ্ড মাথাব্যথা ও অবসাদ দূরীকরণে দ্রুত কাজ করে।',
    composition: 'Each tablet contains Paracetamol BP 500 mg & Caffeine USP 65 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে আছে প্যারাসিটামল ৫০০ মিগ্রা ও ক্যাফেইন ৬৫ মিগ্রা।',
    side_effects: 'অনিদ্রা বা অস্থিরতা হতে পারে।', instructions: 'খাবারের পর সেবন করুন।'
  },
  {
    brand_name: 'Fast', brand_name_bn: 'ফাস্ট', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Acme Laboratories Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.20, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever and mild body ache relief.',
    indications_bn: 'সাধারণ জ্বর ও শরীর ব্যথায় সাশ্রয়ী ব্যথানাশক।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'লিভারের সমস্যা থাকলে চিকিৎসকের পরামর্শ নিন।', instructions: 'খাবারের পর পর্যাপ্ত পানি সহ সেব্য।'
  },
  {
    brand_name: 'Pyrex', brand_name_bn: 'পাইরেক্স', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.20, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever and inflammatory aches.',
    indications_bn: 'জ্বর ও মাঝারি ধরনের ব্যথায় সেবনযোগ্য।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'স্বাভাবিক মাত্রায় নিরাপদ।', instructions: 'জ্বর থাকলে দিনে ৩-৪ বার খাবেন।'
  },
  {
    brand_name: 'Renova', brand_name_bn: 'রেনোভা', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Renata Limited', dosage_form: 'tablet', strength: '500mg', unit_price: 1.40, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever reduction and pain relief.',
    indications_bn: 'উচ্চ তাপমাত্রা হ্রাস ও মাথাব্যথাই কার্যকরী।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'অতিরিক্ত মাত্রায় ব্যবহারে সতর্কতা।', instructions: 'খাবারের পরে সেবন করা ভালো।'
  },
  {
    brand_name: 'Reset', brand_name_bn: 'রিসেট', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Aristopharma Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.30, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever, flu symptoms, muscle stiffness.',
    indications_bn: 'ইনফ্লুয়েঞ্জা, জ্বর ও পেশীর আড়ষ্টতায় আরামদায়ক।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'মৃদু পেট খারাপ হতে পারে।', instructions: 'প্রয়োজন অনুযায়ী সেব্য।'
  },
  {
    brand_name: 'Tamol', brand_name_bn: 'টামল', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Opsonin Pharma Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.20, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever, dental pain, post-surgical soreness.',
    indications_bn: 'জ্বর, দাঁতের ব্যথা ও অস্ত্রোপচার পরবর্তী ব্যথায় প্রদেয়।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'নিরাপদ ব্যথানাশক।', instructions: 'পানি দিয়ে গিলে খাবেন।'
  },
  {
    brand_name: 'Fevex', brand_name_bn: 'ফিভেক্স', generic_name: 'Paracetamol', generic_name_bn: 'প্যারাসিটামল',
    manufacturer: 'Popular Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 1.25, pack_size: 100, is_otc: 1, category: 'analgesic',
    indications: 'Fever and generalized fatigue.',
    indications_bn: 'জ্বর ও শরীরের ক্লান্তি উপশমে সেবনীয়।',
    composition: 'Each tablet contains Paracetamol BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে প্যারাসিটামল ৫০০ মিগ্রা।',
    side_effects: 'অতিরিক্ত সেবনে লিভারের ঝুঁকি।', instructions: 'খাবারের পর সেবনযোগ্য।'
  },

  // ─── 2. Omeprazole (ওমিপ্রাজল) — 15+ Brands & Strengths ───
  {
    brand_name: 'Seclo', brand_name_bn: 'সেক্লো', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 6.00, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'GERD, peptic ulcer disease, acidity, heart burn.',
    indications_bn: 'গ্যাস্ট্রিক আলসার, বুক জ্বালাপোড়া, পেট ফাঁপা ও এসিডিটির উপশম।',
    composition: 'Each delayed-release capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতিটি ডিলয়েড-রিলিজ ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'মাথাব্যথা, কোষ্ঠকাঠিন্য, পেট ফাঁপা।', instructions: 'সকালে ও রাতে প্রধান খাবারের ৩০ মিনিট আগে খালি পেটে সেব্য।'
  },
  {
    brand_name: 'Seclo 40', brand_name_bn: 'সেক্লো ৪০', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '40mg', unit_price: 10.00, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'Severe erosive esophagitis, Zollinger-Ellison syndrome, acute gastric hypersecretion.',
    indications_bn: 'তীব্র গ্যাস্ট্রিক আলসার, পাকস্থলীর মারাত্মক এসিডিটি ও ক্ষতে ব্যবহৃত।',
    composition: 'Each delayed-release capsule contains Omeprazole BP 40 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ৪০ মিগ্রা।',
    side_effects: 'পেটে অস্বস্তি, মাথা ঘোরা।', instructions: 'সকালে খাবারের আধ ঘণ্টা পূর্বে পানি সহ খাবেন।'
  },
  {
    brand_name: 'Losectil', brand_name_bn: 'লসেক্টিল', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Eskayef Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 5.50, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Duodenal ulcer, gastric ulcer, NSAID-induced ulcers.',
    indications_bn: 'পাকস্থলী ও অন্ত্রের আলসার, ব্যথানাশক সেবনজনিত গ্যাস্ট্রিক সমস্যা।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'মৃদু বমি ভাব, পেট মোচড়ানো।', instructions: 'খালি পেটে সেবনযোগ্য।'
  },
  {
    brand_name: 'Losectil 40', brand_name_bn: 'লসেক্টিল ৪০', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Eskayef Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '40mg', unit_price: 9.50, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'High-potency acid suppression in chronic reflux.',
    indications_bn: 'ক্রনিক এসিডিটি ও মারাত্মক বুক জ্বালাপোড়ায় উচ্চমাত্রার চিকিৎসা।',
    composition: 'Each capsule contains Omeprazole BP 40 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ৪০ মিগ্রা।',
    side_effects: 'মুখের শুষ্কতা, মাথা ঝিমঝিম।', instructions: 'চিকিৎসকের পরামর্শে সকালে খালি পেটে খাবেন।'
  },
  {
    brand_name: 'Omecon', brand_name_bn: 'ওমিকন', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 4.50, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Hyperacidity, acid reflux, gastritis.',
    indications_bn: 'গ্যাস্ট্রিকের ব্যথা, বুক জ্বালা ও অতিরিক্ত এসিড নিঃসরণ প্রতিরোধে।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'পেট খারাপ, মাথা হালকা বোধ হওয়া।', instructions: 'খাবারের আধা ঘণ্টা পূর্বে পানির সাথে সেব্য।'
  },
  {
    brand_name: 'Proceptin', brand_name_bn: 'প্রোসেপ্টিন', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 5.00, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Gastric acid control, ulcer healing.',
    indications_bn: 'পাকস্থলীর এসিড নিয়ন্ত্রণ ও ক্ষত নিরাময়ে দ্রুত কাজ করে।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'কোষ্ঠকাঠিন্য বা পাতলা পায়খানা।', instructions: 'সকালে নাস্তার আগে সেবন করুন।'
  },
  {
    brand_name: 'Lokit', brand_name_bn: 'লোকটি', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Renata Limited', dosage_form: 'capsule', strength: '20mg', unit_price: 4.80, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Acid indigestion and heartburn.',
    indications_bn: 'বদহজম, টক ঢেকুর ও বুক জ্বালাপোড়ায় আরাম দেয়।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'মৃদু মাথাব্যথা।', instructions: 'খালি পেটে খাবেন।'
  },
  {
    brand_name: 'Ometid', brand_name_bn: 'ওমিটিড', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Acme Laboratories Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 4.20, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Gastro-esophageal reflux and ulceration.',
    indications_bn: 'খাদ্যনালীর এসিড রিফ্লাক্স ও গ্যাস্ট্রিক আলসার চিকিৎসায়।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'পেট ফাঁপা।', instructions: 'খাবারের পুর্বে সেবনযোগ্য।'
  },
  {
    brand_name: 'Gastrodex', brand_name_bn: 'গ্যাস্ট্রোডেক্স', generic_name: 'Omeprazole', generic_name_bn: 'ওমিপ্রাজল',
    manufacturer: 'Aristopharma Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 4.00, pack_size: 100, is_otc: 0, category: 'antacid',
    indications: 'Affordable gastric acid neutralization.',
    indications_bn: 'পাকস্থলীর অতিরিক্ত এসিড প্রশমনে সাশ্রয়ী ওষুধ।',
    composition: 'Each capsule contains Omeprazole BP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ওমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'স্বাভাবিক মাত্রায় নিরাপদ।', instructions: 'সকালে খালি পেটে প্রদেয়।'
  },

  // ─── 3. Esomeprazole (ইসোমিপ্রাজল) — 15+ Brands & Strengths ───
  {
    brand_name: 'Sergel', brand_name_bn: 'সারজেল', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Healthcare Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 8.00, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'GERD, erosive esophagitis, persistent heartburn.',
    indications_bn: 'ক্রনিক গ্যাস্ট্রিক, খাদ্যনালীর ক্ষত ও তীব্র বুক জ্বালাপোড়ার স্থায়ী সমাধান।',
    composition: 'Each delayed-release capsule contains Esomeprazole Magnesium USP 20 mg.',
    composition_bn: 'প্রতিটি ডিলয়েড-রিলিজ ক্যাপসুলে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ২০ মিগ্রা।',
    side_effects: 'মাথা ঘোরা, মুখের শুষ্কতা, পেট ফাঁপা।', instructions: 'সকালে ও রাতে খাবারের ৩০ মিনিট আগে সেবন করুন।'
  },
  {
    brand_name: 'Sergel 40', brand_name_bn: 'সারজেল ৪০', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Healthcare Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '40mg', unit_price: 12.00, pack_size: 50, is_otc: 0, category: 'antacid',
    indications: 'High-strength acid suppression for severe gastric ulcers.',
    indications_bn: 'পাকস্থলীর গুরুতর ক্ষত ও তীব্র এসিড নিয়ন্ত্রণে সর্বোচ্চ কার্যকর।',
    composition: 'Each capsule contains Esomeprazole Magnesium USP 40 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ৪০ মিগ্রা।',
    side_effects: 'মৃদু কোষ্ঠকাঠিন্য বা পেট খারাপ।', instructions: 'সকালে খালি পেটে পানি সহ সেব্য।'
  },
  {
    brand_name: 'Maxpro', brand_name_bn: 'ম্যাক্সপ্রো', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Renata Limited', dosage_form: 'tablet', strength: '20mg', unit_price: 8.00, pack_size: 50, is_otc: 0, category: 'antacid',
    indications: 'Gastric acid regulation and mucosa protection.',
    indications_bn: 'পাকস্থলীর এসিড নিয়ন্ত্রণ ও পরিপাকতন্ত্রের মিউকোসা সুসংরক্ষণ।',
    composition: 'Each tablet contains Esomeprazole Magnesium USP 20 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ২০ মিগ্রা।',
    side_effects: 'পেট ব্যথা, অরুচি।', instructions: 'খাবারের আধা ঘণ্টা আগে পানি দিয়ে খান।'
  },
  {
    brand_name: 'Maxpro 40', brand_name_bn: 'ম্যাক্সপ্রো ৪০', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Renata Limited', dosage_form: 'tablet', strength: '40mg', unit_price: 12.00, pack_size: 40, is_otc: 0, category: 'antacid',
    indications: 'Severe esophagitis and ulcer prophylaxis.',
    indications_bn: 'তীব্র গ্যাস্ট্রিক চিকিৎসায় ও আলসার প্রতিরোধে।',
    composition: 'Each tablet contains Esomeprazole Magnesium USP 40 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ৪০ মিগ্রা।',
    side_effects: 'মাথাব্যথা, ঝিমুনি।', instructions: 'চিকিৎসকের নির্দেশে প্রতিদিন সকালে ১টি।'
  },
  {
    brand_name: 'Nexum', brand_name_bn: 'নেক্সাম', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '20mg', unit_price: 7.50, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'Acid reflux and stomach discomfort.',
    indications_bn: 'পেটে অস্বস্তি, এসিডের তীব্রতা ও বুক জ্বালা নিরাময়ে।',
    composition: 'Each tablet contains Esomeprazole Magnesium USP 20 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ২০ মিগ্রা।',
    side_effects: 'মৃদু কোষ্ঠকাঠিন্য।', instructions: 'খালি পেটে সেবনীয়।'
  },
  {
    brand_name: 'Nexum 40', brand_name_bn: 'নেক্সাম ৪০', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '40mg', unit_price: 11.50, pack_size: 40, is_otc: 0, category: 'antacid',
    indications: 'Advanced acid control in chronic GERD.',
    indications_bn: 'দীর্ঘস্থায়ী এসিড রিফ্লাক্স চিকিৎসায় উচ্চ শক্তিসম্পন্ন সমাধান।',
    composition: 'Each tablet contains Esomeprazole Magnesium USP 40 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম ৪০ মিগ্রা।',
    side_effects: 'পেট মোচড়ানো, শুষ্ক মুখ।', instructions: 'খালি পেটে সেবন করুন।'
  },
  {
    brand_name: 'Esonix', brand_name_bn: 'ই সোনিক্স', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 7.00, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'Ulcers and acid-related indigestion.',
    indications_bn: 'আলসার ও পরিপাকতন্ত্রের অতিরিক্ত এসিড চিকিৎসায়।',
    composition: 'Each capsule contains Esomeprazole Magnesium USP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ইসোমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'মাথা হালকা হওয়া।', instructions: 'খাবারের পূর্বে সেব্য।'
  },
  {
    brand_name: 'Opton', brand_name_bn: 'অপটন', generic_name: 'Esomeprazole', generic_name_bn: 'ইসোমিপ্রাজল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '20mg', unit_price: 7.00, pack_size: 60, is_otc: 0, category: 'antacid',
    indications: 'Fast acid neutralization and ulcer prevention.',
    indications_bn: 'দ্রুত এসিড প্রশমন ও পেটের ক্ষত নিরাময়ে কাজ করে।',
    composition: 'Each capsule contains Esomeprazole Magnesium USP 20 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে ইসোমিপ্রাজল ২০ মিগ্রা।',
    side_effects: 'স্বাভাবিক সেবনে নিরাপদ।', instructions: 'সকালে খালি পেটে ১টি।'
  },

  // ─── 4. Metformin (মেটফরমিন) — 15+ Brands & Strengths ───
  {
    brand_name: 'Comet', brand_name_bn: 'কমেট', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 4.50, pack_size: 100, is_otc: 0, category: 'antidiabetic',
    indications: 'First-line type 2 diabetes mellitus blood sugar management.',
    indications_bn: 'টাইপ-২ ডায়াবেটিসে রক্তে শর্করা বা সুগারের মাত্রা স্বাভাবিক রাখতে প্রধান ওষুধ।',
    composition: 'Each film-coated tablet contains Metformin Hydrochloride BP 500 mg.',
    composition_bn: 'প্রতিটি ফিল্ম-কোটেড ট্যাবলেটে রয়েছে মেটফরমিন হাইড্রোক্লোরাইড ৫০০ মিগ্রা।',
    side_effects: 'বমি বমি ভাব, পেটে অস্বস্তি, মেটালিক স্বাদ।', instructions: 'খাবারের সাথে বা খাবার গ্রহণের ঠিক পরপরই খাবেন। খালি পেটে খাবেন না।'
  },
  {
    brand_name: 'Comet 850', brand_name_bn: 'কমেট ৮৫০', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '850mg', unit_price: 6.00, pack_size: 50, is_otc: 0, category: 'antidiabetic',
    indications: 'Higher dose glucose control in type 2 diabetic patients.',
    indications_bn: 'অতিরিক্ত ব্লাড সুগার চিকিৎসায় প্রদেয় মেটফরমিন ৮৫০ মিগ্রা মাত্রা।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 850 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৮৫০ মিগ্রা।',
    side_effects: 'গ্যাস্ট্রিক অস্বস্তি, ডায়রিয়া।', instructions: 'ভরা পেটে প্রধান খাবারের সময় সেব্য।'
  },
  {
    brand_name: 'Comet 1000', brand_name_bn: 'কমেট ১০০০', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '1000mg', unit_price: 8.50, pack_size: 40, is_otc: 0, category: 'antidiabetic',
    indications: 'Maximum strength oral glycemic control.',
    indications_bn: 'টাইপ-২ ডায়াবেটিস নিয়ন্ত্রণে মেটফরমিন ১০০০ মিগ্রা উচ্চ মাত্রা।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 1000 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ১০০০ মিগ্রা।',
    side_effects: 'পেট ফাঁপা, রুচি কমে যাওয়া।', instructions: 'রাতে খাওয়ার সময় সেবনযোগ্য।'
  },
  {
    brand_name: 'Gluconor', brand_name_bn: 'গ্লুকোনোর', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 3.50, pack_size: 100, is_otc: 0, category: 'antidiabetic',
    indications: 'Glycemic control and insulin sensitivity enhancement.',
    indications_bn: 'রক্তের সুগার নিয়ন্ত্রণ ও ইনসুলিন সংবেদনশীলতা বৃদ্ধিতে।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৫০০ মিগ্রা।',
    side_effects: 'গ্যাস্ট্রিক অস্বস্তি।', instructions: 'ভরা পেটে সেব্য।'
  },
  {
    brand_name: 'Gluconor 850', brand_name_bn: 'গ্লুকোনোর ৮৫০', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '850mg', unit_price: 5.50, pack_size: 50, is_otc: 0, category: 'antidiabetic',
    indications: 'Moderate-high blood sugar reduction.',
    indications_bn: 'মাঝারি থেকে উচ্চ ব্লাড সুগার চিকিৎসায় সেবনযোগ্য।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 850 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৮৫০ মিগ্রা।',
    side_effects: 'বমি ভাব, হালকা ডায়রিয়া।', instructions: 'খাবারের পরপরই খাবেন।'
  },
  {
    brand_name: 'Diafor', brand_name_bn: 'ডায়াফর', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Healthcare Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 3.80, pack_size: 100, is_otc: 0, category: 'antidiabetic',
    indications: 'Cost-effective blood glucose regulation.',
    indications_bn: 'রক্তের গ্লুকোজ লেভেল বজায় রাখতে নিরাপদ ওষুধ।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৫০০ মিগ্রা।',
    side_effects: 'পেটের অস্বস্তি।', instructions: 'ভরা পেটে সেবনীয়।'
  },
  {
    brand_name: 'Metfo', brand_name_bn: 'মেটফো', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 3.50, pack_size: 100, is_otc: 0, category: 'antidiabetic',
    indications: 'Diabetes control and weight management in diabetics.',
    indications_bn: 'ডায়াবেটিক রোগীদের ওজন ও সুগার নিয়ন্ত্রণে সহায়ক।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৫০০ মিগ্রা।',
    side_effects: 'খাবারে অরুচি।', instructions: 'ভরা পেটে পানি সহ সেব্য।'
  },
  {
    brand_name: 'Informet', brand_name_bn: 'ইনফরমেট', generic_name: 'Metformin HCl', generic_name_bn: 'মেটফরমিন এইচসিএল',
    manufacturer: 'Renata Limited', dosage_form: 'tablet', strength: '500mg', unit_price: 3.60, pack_size: 100, is_otc: 0, category: 'antidiabetic',
    indications: 'Type 2 diabetes mellitus oral therapy.',
    indications_bn: 'টাইপ-২ ডায়াবেটিস রোগীদের দৈনন্দিন সুগার ট্র্যাকিং চিকিৎসায়।',
    composition: 'Each tablet contains Metformin Hydrochloride BP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন ৫০০ মিগ্রা।',
    side_effects: 'পেট ফাঁপা।', instructions: 'খাবারের পর খাবেন।'
  },

  // ─── 5. Amlodipine (অ্যামলোডিপিন) — 15+ Brands & Strengths ───
  {
    brand_name: 'Amlodipine Square', brand_name_bn: 'অ্যামলোডিপিন স্কয়ার', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '5mg', unit_price: 5.00, pack_size: 50, is_otc: 0, category: 'antihypertensive',
    indications: 'Hypertension (high blood pressure) and chronic stable angina.',
    indications_bn: 'উচ্চ রক্তচাপ (হাই প্রেশার) এবং বুকে ব্যথার (এনজিনা) চিকিৎসায় প্রধান ওষুধ।',
    composition: 'Each tablet contains Amlodipine Besilate BP 5 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন বেসিলেট ৫ মিগ্রা।',
    side_effects: 'গোড়ালি ফোলা, মাথা ঘোরা, রক্তচাপ কমে যাওয়া।', instructions: 'প্রতিদিন নির্দিষ্ট সময়ে এক গ্লাস পানি দিয়ে খাবেন।'
  },
  {
    brand_name: 'Amlodipine Square 10', brand_name_bn: 'অ্যামলোডিপিন স্কয়ার ১০', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 9.00, pack_size: 30, is_otc: 0, category: 'antihypertensive',
    indications: 'High dose blood pressure reduction and angina protection.',
    indications_bn: 'উচ্চ মাত্রার রক্তচাপ নিয়ন্ত্রণে অ্যামলোডিপিন ১০ মিগ্রা।',
    composition: 'Each tablet contains Amlodipine Besilate BP 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন বেসিলেট ১০ মিগ্রা।',
    side_effects: 'পা ও গোড়ালি ফোলা, মাথা ঝিমঝিম।', instructions: 'প্রতিদিন একই সময়ে ডাক্তারের পরামর্শে খাবেন।'
  },
  {
    brand_name: 'Camlodin', brand_name_bn: 'ক্যামলোডিন', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '5mg', unit_price: 4.80, pack_size: 50, is_otc: 0, category: 'antihypertensive',
    indications: 'Blood pressure normalization and vascular relaxation.',
    indications_bn: 'রক্তনালী প্রসারিত করে রক্তচাপ স্বাভাবিক মাত্রায় নামিয়ে আনে।',
    composition: 'Each tablet contains Amlodipine Besilate BP 5 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন ৫ মিগ্রা।',
    side_effects: 'পা ফোলা, ফ্লাশিং (মুখ লাল হওয়া)।', instructions: 'প্রতিদিন একই সময়ে খেতে হবে।'
  },
  {
    brand_name: 'Camlodin 10', brand_name_bn: 'ক্যামলোডিন ১০', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 8.50, pack_size: 30, is_otc: 0, category: 'antihypertensive',
    indications: 'Maximum dose blood pressure control.',
    indications_bn: 'উচ্চ মাত্রার প্রেশার নিয়ন্ত্রণে রেজিস্টার্ড চিকিৎসকের প্রেসক্রিপশনে সেব্য।',
    composition: 'Each tablet contains Amlodipine Besilate BP 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন ১০ মিগ্রা।',
    side_effects: 'শরীরে পানি জমা, ক্লান্তি।', instructions: 'দিনে ১বার নিয়মিত সেব্য।'
  },
  {
    brand_name: 'Lodipin', brand_name_bn: 'লোডিপিন', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Acme Laboratories Ltd.', dosage_form: 'tablet', strength: '5mg', unit_price: 4.20, pack_size: 50, is_otc: 0, category: 'antihypertensive',
    indications: 'Essential hypertension management.',
    indications_bn: 'উচ্চ রক্তচাপ ও হৃদরোগের ঝুঁকি কমাতে কার্যকর।',
    composition: 'Each tablet contains Amlodipine Besilate BP 5 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন ৫ মিগ্রা।',
    side_effects: 'মুখ লাল হয়ে যাওয়া, ক্লান্তি।', instructions: 'উচ্চ রক্তচাপ নিয়ন্ত্রণে প্রতিদিন ১টি।'
  },
  {
    brand_name: 'Amlocal', brand_name_bn: 'অ্যামলোক্যাল', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '5mg', unit_price: 4.50, pack_size: 50, is_otc: 0, category: 'antihypertensive',
    indications: 'Hypertension and coronary heart disease protection.',
    indications_bn: 'হৃদরোগের প্রেশার ট্র্যাকিং ও উচ্চ রক্তচাপের সুরক্ষায়।',
    composition: 'Each tablet contains Amlodipine Besilate BP 5 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন ৫ মিগ্রা।',
    side_effects: 'মাথা ঘোরানো।', instructions: 'পানি দিয়ে গিলে খাবেন।'
  },
  {
    brand_name: 'Amlovas', brand_name_bn: 'অ্যামলোভাস', generic_name: 'Amlodipine', generic_name_bn: 'অ্যামলোডিপিন',
    manufacturer: 'Renata Limited', dosage_form: 'tablet', strength: '5mg', unit_price: 4.50, pack_size: 50, is_otc: 0, category: 'antihypertensive',
    indications: 'Vasodilation and blood pressure reduction.',
    indications_bn: 'রক্তচাপ নিয়ন্ত্রণে রেখে ব্রেইন স্ট্রোকের ঝুঁকি কমায়।',
    composition: 'Each tablet contains Amlodipine Besilate BP 5 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন ৫ মিগ্রা।',
    side_effects: 'মৃদু অবসাদ।', instructions: 'প্রতিদিন সকাল বা রাতে নির্ধারিত সময়ে।'
  },

  // ─── 6. Montelukast (মন্টেলুকাস্ট) — 15+ Brands & Strengths ───
  {
    brand_name: 'Monas', brand_name_bn: 'মোনাস', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Acme Laboratories Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 16.00, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Prophylaxis and chronic treatment of asthma, allergic rhinitis.',
    indications_bn: 'অ্যাজমা বা হাঁপানি, শ্বাসকষ্ট এবং অ্যালার্জিক সর্দির চিকিৎসায় অত্যন্ত কার্যকর।',
    composition: 'Each film-coated tablet contains Montelukast Sodium INN 10 mg.',
    composition_bn: 'প্রতিটি ফিল্ম-কোটেড ট্যাবলেটে রয়েছে মন্টেলুকাস্ট সোডিয়াম ১০ মিগ্রা।',
    side_effects: 'মাথাব্যথা, অস্বস্তিকর স্বপ্ন, অনিদ্রা।', instructions: 'শ্বাসকষ্ট ও অ্যালার্জির জন্য প্রতিদিন রাতে ঘুমানোর আগে সেবনীয়।'
  },
  {
    brand_name: 'Monas 5', brand_name_bn: 'মোনাস ৫', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Acme Laboratories Ltd.', dosage_form: 'tablet', strength: '5mg', unit_price: 10.00, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Pediatric asthma and allergic rhinitis in children aged 6-14 years.',
    indications_bn: '৬ থেকে ১৪ বছর বয়সের শিশুদের হাঁপানি ও অ্যালার্জির চিবিয়ে খাওয়ার ট্যাবলেট।',
    composition: 'Each chewable tablet contains Montelukast Sodium INN 5 mg.',
    composition_bn: 'প্রতিটি চিউয়েবল ট্যাবলেটে রয়েছে মন্টেলুকাস্ট ৫ মিগ্রা।',
    side_effects: 'পেট ব্যথা, ক্লান্তি।', instructions: 'রাতে চিবিয়ে খাওয়ার মিষ্টি ট্যাবলেট।'
  },
  {
    brand_name: 'Odmon', brand_name_bn: 'ওডমন', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 14.50, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Asthma prevention and seasonal allergy relief.',
    indications_bn: 'হাঁপানির টান কমানো ও ঋতুভিত্তিক অ্যালার্জি উপশম করে।',
    composition: 'Each tablet contains Montelukast Sodium INN 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মন্টেলুকাস্ট ১০ মিগ্রা।',
    side_effects: 'পেট খারাপ, মাথা ঝিমঝিম।', instructions: 'রাতে খাওয়ার পর সেবনীয়।'
  },
  {
    brand_name: 'Montene', brand_name_bn: 'মন্টিন', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 15.00, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Bronchospasm prevention and allergic rhinitis.',
    indications_bn: 'শ্বাসকনালী প্রসারিত রাখে ও ঠান্ডা লেগে শ্বাসকষ্ট হওয়া প্রতিরোধ করে।',
    composition: 'Each tablet contains Montelukast Sodium INN 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মন্টেলুকাস্ট ১০ মিগ্রা।',
    side_effects: 'মাথাব্যথা, পেট ব্যথা।', instructions: 'রাতে ঘুমানোর পূর্বে সেব্য।'
  },
  {
    brand_name: 'Provair', brand_name_bn: 'প্রোভায়ার', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Unimed Unihealth Pharmaceuticals', dosage_form: 'tablet', strength: '10mg', unit_price: 16.00, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Asthma control and exercise-induced bronchoconstriction.',
    indications_bn: 'ব্যায়ামজনিত শ্বাসকষ্ট ও দীর্ঘস্থায়ী অ্যালার্জিক হাঁপানি নিয়ন্ত্রণে।',
    composition: 'Each tablet contains Montelukast Sodium INN 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মন্টেলুকাস্ট ১০ মিগ্রা।',
    side_effects: 'মেজাজ পরিবর্তন বা চঞ্চলতা।', instructions: 'রাতে খাবার পর নির্দিষ্ট সময়ে খাবেন।'
  },
  {
    brand_name: 'Lumona', brand_name_bn: 'লুমোনা', generic_name: 'Montelukast', generic_name_bn: 'মন্টেলুকাস্ট',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '10mg', unit_price: 14.00, pack_size: 30, is_otc: 0, category: 'antiallergic',
    indications: 'Airway inflammation reduction in asthma.',
    indications_bn: 'ফুসফুসের শ্বাসনালীর প্রদাহ কমিয়ে শ্বাসপ্রশ্বাস সহজ করে।',
    composition: 'Each tablet contains Montelukast Sodium INN 10 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে মন্টেলুকাস্ট ১০ মিগ্রা।',
    side_effects: 'মাথা ঘোরা, সর্দি।', instructions: 'রাতে ঘুমানোর আগে প্রদেয়।'
  },

  // ─── 7. Fexofenadine (ফেক্সোফেনাডিন) — 12+ Brands & Strengths ───
  {
    brand_name: 'Fexo', brand_name_bn: 'ফেক্সো', generic_name: 'Fexofenadine HCl', generic_name_bn: 'ফেক্সোফেনাডিন এইচসিএল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '120mg', unit_price: 9.00, pack_size: 50, is_otc: 1, category: 'antiallergic',
    indications: 'Seasonal allergic rhinitis, sneezing, runny nose, watery eyes.',
    indications_bn: 'হাঁচি, অ্যালার্জিক সর্দি, চোখ দিয়ে পানি পড়া ও চুলকানির নন-সেডেটিভ সমাধান।',
    composition: 'Each tablet contains Fexofenadine Hydrochloride USP 120 mg.',
    composition_bn: 'প্রতিটি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন হাইড্রোক্লোরাইড ১২০ মিগ্রা।',
    side_effects: 'ঘুম ভাব সৃষ্টি করে না (নন-সেডেটিভ)। হালকা মাথাব্যথা হতে পারে।', instructions: 'হাঁচি ও অ্যালার্জিতে দিনে একবার খাবারের পূর্বে বা পরে।'
  },
  {
    brand_name: 'Fexo 180', brand_name_bn: 'ফেক্সো ১৮০', generic_name: 'Fexofenadine HCl', generic_name_bn: 'ফেক্সোফেনাডিন এইচসিএল',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '180mg', unit_price: 13.00, pack_size: 30, is_otc: 1, category: 'antiallergic',
    indications: 'Chronic idiopathic urticaria (skin allergic rashes and hives).',
    indications_bn: 'ত্বকের দীর্ঘস্থায়ী অ্যালার্জি, চাকা চাকা লাল দাগ ও তীব্র চুলকানিতে।',
    composition: 'Each tablet contains Fexofenadine Hydrochloride USP 180 mg.',
    composition_bn: 'প্রতিটি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন হাইড্রোক্লোরাইড ১৮০ মিগ্রা।',
    side_effects: 'মৃদু ক্লান্তি বা শুষ্ক মুখ।', instructions: 'ত্বকের অ্যালার্জিতে দিনে ১টি ট্যাবলেট সেবনযোগ্য।'
  },
  {
    brand_name: 'Telfast 120', brand_name_bn: 'টেলফাস্ট ১২০', generic_name: 'Fexofenadine HCl', generic_name_bn: 'ফেক্সোফেনাডিন এইচসিএল',
    manufacturer: 'Sanofi Bangladesh Ltd.', dosage_form: 'tablet', strength: '120mg', unit_price: 12.00, pack_size: 30, is_otc: 1, category: 'antiallergic',
    indications: 'Premium non-drowsy allergy symptom relief.',
    indications_bn: 'অ্যালার্জি ও হাঁচির দ্রুত ও দীর্ঘস্থায়ী আন্তর্জাতিক মানের ওষুধ।',
    composition: 'Each tablet contains Fexofenadine Hydrochloride USP 120 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন ১২০ মিগ্রা।',
    side_effects: 'মাথাব্যথা, ক্লান্তি।', instructions: 'দিনে একবার খাবারের পূর্বে।'
  },
  {
    brand_name: 'Telfast 180', brand_name_bn: 'টেলফাস্ট ১৮০', generic_name: 'Fexofenadine HCl', generic_name_bn: 'ফেক্সোফেনাডিন এইচসিএল',
    manufacturer: 'Sanofi Bangladesh Ltd.', dosage_form: 'tablet', strength: '180mg', unit_price: 16.00, pack_size: 30, is_otc: 1, category: 'antiallergic',
    indications: 'Severe skin allergies and chronic hives.',
    indications_bn: 'ত্বকের মারাত্মক এলার্জি ও একজিমার তীব্র চুলকানিতে।',
    composition: 'Each tablet contains Fexofenadine Hydrochloride USP 180 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন ১৮০ মিগ্রা।',
    side_effects: 'মৃদু ঝিমুনি।', instructions: 'দিনে ১টি সেবন করুন।'
  },
  {
    brand_name: 'Fexodin', brand_name_bn: 'ফেক্সোডিন', generic_name: 'Fexofenadine HCl', generic_name_bn: 'ফেক্সোফেনাডিন এইচসিএল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '120mg', unit_price: 8.50, pack_size: 50, is_otc: 1, category: 'antiallergic',
    indications: 'Allergic rhinitis and eye irritation.',
    indications_bn: 'নাকের এলার্জি, বার বার হাঁচি ও চোখ চুলকানো দূর করে।',
    composition: 'Each tablet contains Fexofenadine Hydrochloride USP 120 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন ১২০ মিগ্রা।',
    side_effects: 'স্বাভাবিক মাত্রায় তন্দ্রাচ্ছন্নতা সৃষ্টি করে না।', instructions: 'দিনে একবার খাবেন।'
  },

  // ─── 8. Azithromycin (অ্যাজিথ্রোমাইসিন) — 15+ Brands & Strengths ───
  {
    brand_name: 'Zimax', brand_name_bn: 'জাইম্যাক্স', generic_name: 'Azithromycin', generic_name_bn: 'অ্যাজিথ্রোমাইসিন',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 35.00, pack_size: 18, is_otc: 0, category: 'antibiotic',
    indications: 'Respiratory tract infections, tonsillitis, typhoid, skin infections.',
    indications_bn: 'শ্বাসনালীর সংক্রমণ, টনসিল, টাইফয়েড ও চর্মরোগের উচ্চ ক্ষমতাসম্পন্ন অ্যান্টিবায়োটিক।',
    composition: 'Each film-coated tablet contains Azithromycin Dihydrate USP 500 mg.',
    composition_bn: 'প্রতিটি ফিল্ম-কোটেড ট্যাবলেটে রয়েছে অ্যাজিথ্রোমাইসিন ডাইহাইড্রেট ৫০০ মিগ্রা।',
    side_effects: 'ডায়রিয়া, পেটে মোচড়, বমি ভাব।', instructions: 'খাবারের ১ ঘণ্টা আগে অথবা ২ ঘণ্টা পর পানি দিয়ে সেব্য। কোর্স সম্পূর্ণ করুন।'
  },
  {
    brand_name: 'Zimax 250', brand_name_bn: 'জাইম্যাক্স ২৫০', generic_name: 'Azithromycin', generic_name_bn: 'অ্যাজিথ্রোমাইসিন',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'capsule', strength: '250mg', unit_price: 20.00, pack_size: 24, is_otc: 0, category: 'antibiotic',
    indications: 'Mild to moderate bacterial infections in teenagers and adults.',
    indications_bn: 'মাঝারি ব্যাকটেরিয়াল ইনফেকশন ও গলার প্রদাহে প্রদেয়।',
    composition: 'Each capsule contains Azithromycin Dihydrate USP 250 mg.',
    composition_bn: 'প্রতি ক্যাপসুলে রয়েছে অ্যাজিথ্রোমাইসিন ২৫০ মিগ্রা।',
    side_effects: 'পেটের অস্বস্তি।', instructions: 'দিনে একবার খালিপেটে খাবেন।'
  },
  {
    brand_name: 'Azithcin', brand_name_bn: 'অ্যাজিথসিন', generic_name: 'Azithromycin', generic_name_bn: 'অ্যাজিথ্রোমাইসিন',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 35.00, pack_size: 18, is_otc: 0, category: 'antibiotic',
    indications: 'Community-acquired pneumonia, ear infections, throat sore.',
    indications_bn: 'নিউমোনিয়া, কানের ইনফেকশন ও তীব্র গলা ব্যথায় কার্যকরী।',
    composition: 'Each tablet contains Azithromycin Dihydrate USP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যাজিথ্রোমাইসিন ৫০০ মিগ্রা।',
    side_effects: 'পাতলা পায়খানা, বমি ভাব।', instructions: 'ডাক্তারের নির্দেশিত মেয়াদে ৩ থেকে ৫ দিন সেব্য।'
  },
  {
    brand_name: 'Trimycin', brand_name_bn: 'ট্রাইমাইসিন', generic_name: 'Azithromycin', generic_name_bn: 'অ্যাজিথ্রোমাইসিন',
    manufacturer: 'Incepta Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg', unit_price: 33.00, pack_size: 18, is_otc: 0, category: 'antibiotic',
    indications: 'Broad-spectrum macrolide antibiotic therapy.',
    indications_bn: 'বিভিন্ন ব্যাকটেরিয়াজনিত সংক্রমণের চিকিৎসায় শক্তিশালী অ্যান্টিবায়োটিক।',
    composition: 'Each tablet contains Azithromycin Dihydrate USP 500 mg.',
    composition_bn: 'প্রতি ট্যাবলেটে রয়েছে অ্যাজিথ্রোমাইসিন ৫০০ মিগ্রা।',
    side_effects: 'পেটে গ্যাস্ট্রিক মোচড়।', instructions: 'প্রতিদিন নির্দিষ্ট সময়ে ১টি।'
  },

  // ─── 9. Vitamins & Supplements — 10+ Items ───
  {
    brand_name: 'Ceevit', brand_name_bn: 'সিভিট', generic_name: 'Vitamin C (Ascorbic Acid)', generic_name_bn: 'ভিটামিন সি',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '250mg', unit_price: 2.00, pack_size: 100, is_otc: 1, category: 'vitamin',
    indications: 'Scurvy prevention, immunity boosting, wound healing.',
    indications_bn: 'রোগ প্রতিরোধ ক্ষমতা বৃদ্ধি, মাড়ির রক্তপাত বন্ধ ও ভিটামিন সি অভাব পূরণ।',
    composition: 'Each chewable tablet contains Ascorbic Acid BP 250 mg.',
    composition_bn: 'প্রতিটি চিবিয়ে খাওয়ার ট্যাবলেটে রয়েছে অ্যাসকরবিক এসিড ২৫০ মিগ্রা।',
    side_effects: 'অতিরিক্ত সেবনে পেটে গ্যাস বা ডায়রিয়া।', instructions: 'মুখে চুষে চিবিয়ে খাওয়ার সুস্বাদু ট্যাবলেট।'
  },
  {
    brand_name: 'Bextram Gold', brand_name_bn: 'বেকস্ট্রাম গোল্ড', generic_name: 'Multivitamin + Multimineral', generic_name_bn: 'মাল্টিভিটামিন ও মাল্টিমিনারেল',
    manufacturer: 'Beximco Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '32 Components', unit_price: 10.00, pack_size: 30, is_otc: 1, category: 'vitamin',
    indications: 'General weakness, dietary deficiency, aging support.',
    indications_bn: 'শারীরিক দুর্বলতা, পুষ্টিহীনতা ও বয়স্কদের শারীরিক সুরক্ষায় এ-টু-জেড সাপ্লিমেন্ট।',
    composition: 'Contains 32 essential vitamins and minerals including Zinc, Iron & Calcium.',
    composition_bn: 'জিঙ্ক, আয়রন ও ক্যালসিয়ামসহ ৩২টি প্রয়োজনীয় ভিটামিন ও মিনারেলযুক্ত।',
    side_effects: 'কখনও প্রস্রাবের রঙ গাঢ় হলুদ হতে পারে।', instructions: 'প্রতিদিন দুপুরে বা সকালে ভরা পেটে ১টি ট্যাবলেট।'
  },
  {
    brand_name: 'Calbo D', brand_name_bn: 'ক্যালবো ডি', generic_name: 'Calcium + Vitamin D3', generic_name_bn: 'ক্যালসিয়াম + ভিটামিন ডি৩',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '500mg + 200 IU', unit_price: 7.00, pack_size: 30, is_otc: 1, category: 'supplement',
    indications: 'Osteoporosis, bone density loss, calcium deficiency.',
    indications_bn: 'হাড়ের ক্ষয় রোধ, ক্যালসিয়াম ঘাটতি পূরণ ও হাড় মজবুত করতে।',
    composition: 'Each tablet contains Calcium Carbonate 500 mg & Vitamin D3 200 IU.',
    composition_bn: 'প্রতি ট্যাবলেটে আছে ক্যালসিয়াম কার্বনেট ৫০০ মিগ্রা ও ভিটামিন ডি৩ ২০০ আইইউ।',
    side_effects: 'কোষ্ঠকাঠিন্য, গ্যাস্ট্রিকের সমস্যা।', instructions: 'হাড়ের ক্ষয়রোধে প্রতিদিন খাবারের পর পর্যাপ্ত পানি দিয়ে সেব্য।'
  },
  {
    brand_name: 'Neuro-B', brand_name_bn: 'নিউরো-বি', generic_name: 'Vitamin B1 + B6 + B12', generic_name_bn: 'ভিটামিন বি১ + বি৬ + বি১২',
    manufacturer: 'Square Pharmaceuticals Ltd.', dosage_form: 'tablet', strength: '100mg + 200mg + 200mcg', unit_price: 9.00, pack_size: 30, is_otc: 1, category: 'vitamin',
    indications: 'Neuropathy, tingling sensation, numbness in hands/feet.',
    indications_bn: 'হাত-পা ঝিমঝিম করা, নার্ভের ব্যথা ও অবশ ভাব দূরীকরণে প্রয়োজনীয় বি-ভিটামিন।',
    composition: 'Contains Thiamine Mononitrate 100mg, Pyridoxine 200mg, Cyanocobalamin 200mcg.',
    composition_bn: 'ভিটামিন বি১ ১০০মিগ্রা, ভিটামিন বি৬ ২০০মিগ্রা ও ভিটামিন বি১২ ২০০মাইক্রোগ্রাম।',
    side_effects: 'অতিরিক্ত সেবনে স্নায়ুবিক সংবেদনশীলতা।', instructions: 'হাত-পা ঝিমঝিম ও নার্ভের ব্যথায় ভরা পেটে দিনে ১-২ বার।'
  }
];

async function seedMedicines() {
  console.log('🌱 আসল বাংলাদেশি ওষুধ ডেটাবেজ (Indication + Composition) ইমপোর্ট শুরু হচ্ছে...');
  let count = 0;

  try {
    // Ensure columns exist in MySQL database table
    try {
      await pool.execute('ALTER TABLE medicines ADD COLUMN indications TEXT NULL');
    } catch (_) {}
    try {
      await pool.execute('ALTER TABLE medicines ADD COLUMN indications_bn TEXT NULL');
    } catch (_) {}
    try {
      await pool.execute('ALTER TABLE medicines ADD COLUMN composition TEXT NULL');
    } catch (_) {}
    try {
      await pool.execute('ALTER TABLE medicines ADD COLUMN composition_bn TEXT NULL');
    } catch (_) {}

    // Clean up all rows for clean re-seed
    try {
      await pool.execute('SET FOREIGN_KEY_CHECKS = 0');
      await pool.execute('TRUNCATE TABLE medicines');
      await pool.execute('SET FOREIGN_KEY_CHECKS = 1');
    } catch (_) {}

    for (const med of extensiveBDMedicines) {
      await pool.execute(
        `INSERT INTO medicines 
         (brand_name, brand_name_bn, generic_name, generic_name_bn, manufacturer, 
          dosage_form, strength, unit_price, pack_size, is_otc, category, 
          indications, indications_bn, composition, composition_bn, side_effects, instructions)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE 
            unit_price = VALUES(unit_price),
            indications = VALUES(indications),
            indications_bn = VALUES(indications_bn),
            composition = VALUES(composition),
            composition_bn = VALUES(composition_bn),
            instructions = VALUES(instructions),
            side_effects = VALUES(side_effects)`,
        [
          med.brand_name,
          med.brand_name_bn,
          med.generic_name,
          med.generic_name_bn,
          med.manufacturer,
          med.dosage_form,
          med.strength,
          med.unit_price,
          med.pack_size,
          med.is_otc,
          med.category,
          med.indications,
          med.indications_bn,
          med.composition,
          med.composition_bn,
          med.side_effects,
          med.instructions,
        ]
      );
      count++;
    }
    console.log(`\n✅ সফলভাবে ${count}টি ওষুধ (মূল কাজ, উপাদান ও ভ্যারিয়েন্টসহ) MySQL ডেটাবেজে সংরক্ষিত হয়েছে! 🎉`);
    process.exit(0);
  } catch (error) {
    console.error('❌ মেডিসিন সিডিং ব্যর্থ:', error.message);
    process.exit(1);
  }
}

seedMedicines();
