import '../models/medicine_model.dart';

class OfflineMedicineDataset {
  static final List<String> manufacturers = [
    'Square Pharmaceuticals Ltd.',
    'Beximco Pharmaceuticals Ltd.',
    'Incepta Pharmaceuticals Ltd.',
    'Renata Limited',
    'Acme Laboratories Ltd.',
    'Aristopharma Ltd.',
    'Opsonin Pharma Ltd.',
    'Popular Pharmaceuticals Ltd.',
    'ACI Limited',
    'Drug International Ltd.',
    'Eskayef Pharmaceuticals Ltd.',
    'Healthcare Pharmaceuticals Ltd.',
    'General Pharmaceuticals Ltd.',
    'Beacon Pharmaceuticals Ltd.',
    'Orion Pharma Ltd.',
    'Ibn Sina Pharmaceutical Industry Ltd.',
    'Delta Pharma Ltd.',
    'Radiant Pharmaceuticals Ltd.',
    'Nuvista Pharma Ltd.',
    'Ziska Pharmaceuticals Ltd.',
    'Silva Pharmaceuticals Ltd.',
    'Kumudini Pharma Ltd.',
    'Navana Pharmaceuticals Ltd.',
    'Shariff Pharmaceuticals Ltd.',
    'Jayson Pharmaceuticals Ltd.',
    'Globex Pharmaceuticals Ltd.',
    'Vitalac Pharma Ltd.',
    'Nipro JMI Pharma Ltd.',
    'Edruc Ltd.',
    'Albion Laboratories Ltd.',
    'Standard Laboratories Ltd.',
    'Medimet Pharmaceuticals Ltd.',
    'Zenith Pharmaceuticals Ltd.',
    'Apex Pharma Ltd.',
    'Techno Drugs Ltd.',
    'Unimed Unihealth Pharmaceuticals',
  ];

  static final List<Map<String, dynamic>> genericMolecules = [
    {
      'generic': 'Paracetamol',
      'generic_bn': 'প্যারাসিটামল',
      'category': 'analgesic',
      'forms': ['Tablet', 'Syrup', 'Suppository'],
      'strengths': ['500 mg', '665 mg', '120 mg/5ml'],
      'basePrice': 1.50,
      'indications': 'জ্বর, তীব্র মাথাব্যথা, শরীর ব্যথা ও মৌসুমী সর্দিকাশি উপশমে সেবনযোগ্য।',
      'composition': 'প্রতিটি মোডে রয়েছে পারাসিটামল বিপি উপাদান।',
      'brandPrefixes': {'Square': 'Ace', 'Beximco': 'Napa', 'Acme': 'Fast', 'Incepta': 'Pyrex', 'Renata': 'Renova', 'Aristopharma': 'Reset', 'Opsonin': 'Tamol', 'Popular': 'Fevex', 'Eskayef': 'Xpa', 'Healthcare': 'H-Para'}
    },
    {
      'generic': 'Omeprazole',
      'generic_bn': 'ওমিপ্রাজল',
      'category': 'antacid',
      'forms': ['Capsule', 'Injection'],
      'strengths': ['20 mg', '40 mg'],
      'basePrice': 5.50,
      'indications': 'গ্যাস্ট্রিক আলসার, বুক জ্বালাপোড়া, পেট ফাঁপা ও এসিডিটির স্থায়ী চিকিৎসা।',
      'composition': 'প্রতি ক্যাপসুলে রয়েছে ওমেপ্রাজল বিপি উপাদান।',
      'brandPrefixes': {'Square': 'Seclo', 'Eskayef': 'Losectil', 'Beximco': 'Omecon', 'Incepta': 'Proceptin', 'Renata': 'Lokit', 'Acme': 'Ometid', 'Aristopharma': 'Gastrodex', 'Healthcare': 'Omez'}
    },
    {
      'generic': 'Esomeprazole',
      'generic_bn': 'ইসোমিপ্রাজল',
      'category': 'antacid',
      'forms': ['Capsule', 'Tablet'],
      'strengths': ['20 mg', '40 mg'],
      'basePrice': 7.50,
      'indications': 'ক্রনিক গ্যাস্ট্রিক, খাদ্যনালীর ক্ষত ও তীব্র বুক জ্বালাপোড়ার সমাধান।',
      'composition': 'প্রতি ক্যাপসুলে রয়েছে ইসোমিপ্রাজল ম্যাগনেসিয়াম উপাদান।',
      'brandPrefixes': {'Healthcare': 'Sergel', 'Renata': 'Maxpro', 'Beximco': 'Nexum', 'Incepta': 'Esonix', 'Square': 'Opton', 'ACI': 'Esokit', 'Popular': 'Esomax'}
    },
    {
      'generic': 'Pantoprazole',
      'generic_bn': 'প্যান্টোপ্রাজল',
      'category': 'antacid',
      'forms': ['Tablet', 'Injection'],
      'strengths': ['20 mg', '40 mg'],
      'basePrice': 6.00,
      'indications': 'দীর্ঘমেয়াদী পেপটিক আলসার, গ্যাস্ট্রিক এসিডিটি ও পেট মোচড়ানো।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে প্যান্টোপ্রাজল উপাদান।',
      'brandPrefixes': {'Incepta': 'Pantonic', 'Square': 'Panto', 'Beximco': 'Pantocid', 'Renata': 'Pantobex'}
    },
    {
      'generic': 'Metformin HCl',
      'generic_bn': 'মেটফরমিন এইচসিএল',
      'category': 'antidiabetic',
      'forms': ['Tablet'],
      'strengths': ['500 mg', '850 mg', '1000 mg'],
      'basePrice': 4.00,
      'indications': 'টাইপ-২ ডায়াবেটিসে রক্তে শর্করা বা সুগারের মাত্রা স্বাভাবিক রাখতে প্রধান ওষুধ।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে মেটফরমিন হাইড্রোক্লোরাইড উপাদান।',
      'brandPrefixes': {'Square': 'Comet', 'Incepta': 'Gluconor', 'Healthcare': 'Diafor', 'Beximco': 'Metfo', 'Renata': 'Informet', 'ACI': 'Metform'}
    },
    {
      'generic': 'Amlodipine',
      'generic_bn': 'অ্যামলোডিপিন',
      'category': 'antihypertensive',
      'forms': ['Tablet'],
      'strengths': ['5 mg', '10 mg'],
      'basePrice': 4.50,
      'indications': 'উচ্চ রক্তচাপ (হাই প্রেশার) এবং বুকে ব্যথার (এনজিনা) চিকিৎসায় প্রদেয়।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে অ্যামলোডিপিন বেসিলেট উপাদান।',
      'brandPrefixes': {'Square': 'Amlodipine Square', 'Beximco': 'Camlodin', 'Acme': 'Lodipin', 'Incepta': 'Amlocal', 'Renata': 'Amlovas', 'Eskayef': 'Amlocard'}
    },
    {
      'generic': 'Montelukast',
      'generic_bn': 'মন্টেলুকাস্ট',
      'category': 'respiratory',
      'forms': ['Tablet', 'Chewable Tablet'],
      'strengths': ['10 mg', '5 mg', '4 mg'],
      'basePrice': 15.00,
      'indications': 'অ্যাজমা, হাঁপানি, শ্বাসকষ্ট ও অ্যালার্জিক সর্দির চিকিৎসায় অত্যন্ত কার্যকর।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে মন্টেলুকাস্ট সোডিয়াম উপাদান।',
      'brandPrefixes': {'Acme': 'Monas', 'Incepta': 'Odmon', 'Square': 'Montene', 'Unimed Unihealth': 'Provair', 'Beximco': 'Lumona', 'Healthcare': 'Monteflo'}
    },
    {
      'generic': 'Fexofenadine HCl',
      'generic_bn': 'ফেক্সোফেনাডিন এইচসিএল',
      'category': 'respiratory',
      'forms': ['Tablet', 'Syrup'],
      'strengths': ['120 mg', '180 mg', '60 mg'],
      'basePrice': 8.50,
      'indications': 'হাঁচি, অ্যালার্জিক সর্দি, চোখ দিয়ে পানি পড়া ও চর্ম অ্যালার্জির সমাধান।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে ফেক্সোফেনাডিন হাইড্রোক্লোরাইড উপাদান।',
      'brandPrefixes': {'Square': 'Fexo', 'Beximco': 'Fexodin', 'Sanofi': 'Telfast', 'Incepta': 'Fexofast', 'Renata': 'Fexoral'}
    },
    {
      'generic': 'Azithromycin',
      'generic_bn': 'অ্যাজিথ্রোমাইসিন',
      'category': 'antibiotic',
      'forms': ['Tablet', 'Capsule', 'Suspension'],
      'strengths': ['500 mg', '250 mg'],
      'basePrice': 33.00,
      'indications': 'শ্বাসনালীর সংক্রমণ, টনসিল, টাইফয়েড ও ব্যাকটেরিয়াল ইনফেকশন নিরসন।',
      'composition': 'প্রতি ডাউজে রয়েছে অ্যাজিথ্রোমাইসিন ডাইহাইড্রেট উপাদান।',
      'brandPrefixes': {'Square': 'Zimax', 'Beximco': 'Azithcin', 'Incepta': 'Trimycin', 'Renata': 'Azith', 'Opsonin': 'Azithro'}
    },
    {
      'generic': 'Cefuroxime Axetil',
      'generic_bn': 'সেফিউরোক্সিম এক্সটিল',
      'category': 'antibiotic',
      'forms': ['Tablet', 'Suspension'],
      'strengths': ['250 mg', '500 mg'],
      'basePrice': 45.00,
      'indications': 'মূত্রনালী সংক্রমণ, ফুসফুসের ইনফেকশন, টাইফয়েড ও ব্যাকটেরিয়াজনিত জ্বর।',
      'composition': 'প্রতিটি ট্যাবলেটে রয়েছে সেফিউরোক্সিম এক্সটিল উপাদান।',
      'brandPrefixes': {'Square': 'Kilbac', 'Beximco': 'Cefucon', 'Incepta': 'Ximecaf', 'Renata': 'Furocef'}
    },
    {
      'generic': 'Ciprofloxacin',
      'generic_bn': 'সিপ্রোফ্লক্সাসিন',
      'category': 'antibiotic',
      'forms': ['Tablet', 'Eye Drops'],
      'strengths': ['500 mg', '250 mg'],
      'basePrice': 12.00,
      'indications': 'পেটের ইনফেকশন, ডায়রিয়া, মূত্রনালীর ইনফেকশন ও ব্যাকটেরিয়াল ডায়রিয়া।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে সিপ্রোফ্লক্সাসিন ইউএসপি উপাদান।',
      'brandPrefixes': {'Square': 'Ciprocin', 'Beximco': 'Neocip', 'Incepta': 'Ciprox', 'Renata': 'Ciprolet'}
    },
    {
      'generic': 'Losartan Potassium',
      'generic_bn': 'লোসারটান পটাশিয়াম',
      'category': 'antihypertensive',
      'forms': ['Tablet'],
      'strengths': ['50 mg', '25 mg', '100 mg'],
      'basePrice': 8.00,
      'indications': 'উচ্চ রক্তচাপ নিয়ন্ত্রণ, কিডনি সুরক্ষা ও হার্ট সুস্থ রাখা।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে লোসারটান পটাশিয়াম ইউএসপি উপাদান।',
      'brandPrefixes': {'Square': 'Osartil', 'Beximco': 'Enasym', 'Incepta': 'Angilock', 'Renata': 'Losar'}
    },
    {
      'generic': 'Atorvastatin',
      'generic_bn': 'অ্যাটরভাস্ট্যাটিন',
      'category': 'cardiovascular',
      'forms': ['Tablet'],
      'strengths': ['10 mg', '20 mg'],
      'basePrice': 12.00,
      'indications': 'রক্তে বাজে কোলেস্টেরল (LDL) কমানো ও হার্ট অ্যাটাকের ঝুঁকি হ্রাস।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে অ্যাটরভাস্ট্যাটিন ক্যালসিয়াম উপাদান।',
      'brandPrefixes': {'Square': 'Atova', 'Beximco': 'Lipirex', 'Incepta': 'Tigovas', 'Renata': 'Atorstat'}
    },
    {
      'generic': 'Vitamin C (Ascorbic Acid)',
      'generic_bn': 'ভিটামিন সি',
      'category': 'vitamin',
      'forms': ['Chewable Tablet'],
      'strengths': ['250 mg', '500 mg'],
      'basePrice': 2.00,
      'indications': 'রোগ প্রতিরোধ ক্ষমতা বৃদ্ধি, মাড়ির ক্ষত ও স্কিন টোন উজ্জ্বল করা।',
      'composition': 'প্রতিটি চিবিয়ে খাওয়ার ট্যাবলেটে রয়েছে ভিটামিন সি উপাদান।',
      'brandPrefixes': {'Square': 'Ceevit', 'Beximco': 'Ascor C', 'Acme': 'Vitam C', 'Incepta': 'C-Vitan'}
    },
    {
      'generic': 'Calcium + Vitamin D3',
      'generic_bn': 'ক্যালসিয়াম + ভিটামিন ডি৩',
      'category': 'supplement',
      'forms': ['Tablet'],
      'strengths': ['500 mg + 200 IU'],
      'basePrice': 7.00,
      'indications': 'হাড়ের ক্ষয় রোধ, ক্যালসিয়াম ঘাটতি পূরণ ও হাড় মজবুত করতে।',
      'composition': 'প্রতি ট্যাবলেটে আছে ক্যালসিয়াম কার্বনেট ও ভিটামিন ডি৩।',
      'brandPrefixes': {'Square': 'Calbo D', 'Beximco': 'Calcin D', 'Incepta': 'Cal D', 'Healthcare': 'Ostocal D'}
    },
    {
      'generic': 'Vitamin B1 + B6 + B12',
      'generic_bn': 'ভিটামিন বি১ + বি৬ + বি১২',
      'category': 'vitamin',
      'forms': ['Tablet'],
      'strengths': ['100mg + 200mg + 200mcg'],
      'basePrice': 7.50,
      'indications': 'হাত-পা ঝিমঝিম করা, নার্ভের ব্যথা ও অবশ ভাব দূরীকরণে প্রদেয়।',
      'composition': 'প্রতিটি ট্যাবলেটে রয়েছে বি-ভিটামিন নিউরোট্রপিক উপাদান।',
      'brandPrefixes': {'Square': 'Neuro-B', 'Beximco': 'Neobion', 'Incepta': 'B-Complex', 'Renata': 'Neuromet'}
    },
    {
      'generic': 'Domperidone',
      'generic_bn': 'ডম্পেরিডন',
      'category': 'gastrointestinal',
      'forms': ['Tablet', 'Suspension'],
      'strengths': ['10 mg'],
      'basePrice': 3.00,
      'indications': 'বমি বমি ভাব, পেট ফাঁপা, বধহজম ও খাবারের পর অস্বস্তি।',
      'composition': 'প্রতি ট্যাবলেটে রয়েছে ডম্পেরিডন মেলিয়েট উপাদান।',
      'brandPrefixes': {'Square': 'Omidon', 'Beximco': 'Motigut', 'Incepta': 'Deflux', 'Renata': 'Domin'}
    },
  ];

  static List<MedicineModel>? _cacheAll;

  static List<MedicineModel> _generateMasterCatalog() {
    if (_cacheAll != null) return _cacheAll!;

    final List<MedicineModel> masterList = [];
    int idCounter = 1000;

    for (final molecule in genericMolecules) {
      final genericName = molecule['generic'] as String;
      final genericBn = molecule['generic_bn'] as String;
      final category = molecule['category'] as String;
      final forms = molecule['forms'] as List<String>;
      final strengths = molecule['strengths'] as List<String>;
      final basePrice = molecule['basePrice'] as double;
      final indications = molecule['indications'] as String;
      final composition = molecule['composition'] as String;
      final brandPrefixes = molecule['brandPrefixes'] as Map<String, String>;

      for (final mfg in manufacturers) {
        String companyKey = mfg.split(' ')[0];
        String brandBaseName = brandPrefixes[companyKey] ?? '${companyKey}-$genericName';
        String brandBnName = '$brandBaseName (${genericBn})';

        for (final form in forms) {
          for (final str in strengths) {
            idCounter++;
            masterList.add(
              MedicineModel(
                id: idCounter,
                brandName: '$brandBaseName $str'.trim(),
                brandNameBn: brandBnName,
                genericName: genericName,
                genericNameBn: genericBn,
                manufacturer: mfg,
                dosageForm: form,
                strength: str,
                unitPrice: double.parse((basePrice + (idCounter % 5) * 0.25).toStringAsFixed(2)),
                category: category,
                indicationsBn: indications,
                compositionBn: composition,
              ),
            );
          }
        }
      }
    }

    _cacheAll = masterList;
    return masterList;
  }

  static List<MedicineModel> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();
    final master = _generateMasterCatalog();

    return master.where((m) {
      final brand = m.brandName.toLowerCase();
      final brandBn = (m.brandNameBn ?? '').toLowerCase();
      final generic = m.genericName.toLowerCase();
      final genericBn = (m.genericNameBn ?? '').toLowerCase();
      final manufacturer = (m.manufacturer ?? '').toLowerCase();
      return brand.contains(q) || brandBn.contains(q) || generic.contains(q) || genericBn.contains(q) || manufacturer.contains(q);
    }).take(40).toList();
  }

  static List<MedicineModel> getAlternatives(int medicineId) {
    final master = _generateMasterCatalog();
    final target = master.firstWhere((m) => m.id == medicineId, orElse: () => master.first);
    final targetGeneric = target.genericName.toLowerCase().split('+')[0].trim();

    return master.where((m) {
      final gen = m.genericName.toLowerCase();
      return gen.contains(targetGeneric) && m.id != target.id;
    }).take(20).toList();
  }
}