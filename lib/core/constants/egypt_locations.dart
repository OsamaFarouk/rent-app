/// Structured reusable dataset of Egyptian Governorates and Districts.
class EgyptDistrict {
  final String id;
  final String nameEn;
  final String nameAr;

  const EgyptDistrict({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }
}

class EgyptGovernorate {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<EgyptDistrict> districts;

  const EgyptGovernorate({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.districts,
  });

  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }
}

abstract class EgyptLocations {
  static const List<EgyptGovernorate> governorates = [
    // 1. Cairo Governorate (القاهرة)
    EgyptGovernorate(
      id: 'cairo',
      nameEn: 'Cairo Governorate',
      nameAr: 'محافظة القاهرة',
      districts: [
        EgyptDistrict(id: 'heliopolis', nameEn: 'Masr El Gedida (Heliopolis)', nameAr: 'مصر الجديدة (هليوبوليس)'),
        EgyptDistrict(id: 'nasr_city', nameEn: 'Nasr City (East & West)', nameAr: 'مدينة نصر (شرق وغرب)'),
        EgyptDistrict(id: 'el_nozha', nameEn: 'El Nozha & Sheraton', nameAr: 'النزهة وشيراتون'),
        EgyptDistrict(id: 'downtown_cairo', nameEn: 'Downtown & Qasr El Nil', nameAr: 'وسط البلد وقصر النيل'),
        EgyptDistrict(id: 'zamalek_garden_city', nameEn: 'Zamalek & Garden City', nameAr: 'الزمالك وجاردن سيتي'),
        EgyptDistrict(id: 'old_cairo_manial', nameEn: 'Old Cairo & Manial', nameAr: 'مصر القديمة والمنيل والسيدة زينب'),
        EgyptDistrict(id: 'mokattam', nameEn: 'El Mokattam', nameAr: 'المقطم'),
        EgyptDistrict(id: 'maadi_basatin', nameEn: 'Maadi & Zahraa El Maadi', nameAr: 'المعادي ولهراء المعادي والبساتين'),
        EgyptDistrict(id: 'shubra_north', nameEn: 'Shubra & Hadayek El Qobba', nameAr: 'شبرا وحدائق القبة والزيتون'),
        EgyptDistrict(id: 'eastern_outskirts', nameEn: 'El Salam & El Marg', nameAr: 'السلام والمرج وعزبة النخل'),
        EgyptDistrict(id: 'helwan_may', nameEn: 'Helwan & 15th of May City', nameAr: 'حلوان و١٥ مايو والمعصرة'),
        EgyptDistrict(id: 'new_cairo_settlements', nameEn: 'New Cairo (1st & 5th Settlement)', nameAr: 'القاهرة الجديدة (التجمع الأول والخامس)'),
        EgyptDistrict(id: 'shorouk_city', nameEn: 'El Shorouk City', nameAr: 'مدينة الشروق'),
        EgyptDistrict(id: 'badr_city', nameEn: 'Badr City', nameAr: 'مدينة بدر'),
        EgyptDistrict(id: 'madinaty_mostakbal', nameEn: 'Madinaty & Mostakbal City', nameAr: 'مدينتي ومدينة المستقبل'),
        EgyptDistrict(id: 'new_admin_capital', nameEn: 'New Administrative Capital (NAC)', nameAr: 'العاصمة الإدارية الجديدة'),
      ],
    ),

    // 2. Giza Governorate (الجيزة)
    EgyptGovernorate(
      id: 'giza',
      nameEn: 'Giza Governorate',
      nameAr: 'محافظة الجيزة',
      districts: [
        EgyptDistrict(id: 'dokki', nameEn: 'Dokki & Shooting Club', nameAr: 'الدقي ونادي الصيد'),
        EgyptDistrict(id: 'agouza_mohandessin', nameEn: 'Agouza & Mohandessin', nameAr: 'العجوزة والمهندسين'),
        EgyptDistrict(id: 'el_haram', nameEn: 'El Haram & Remaya', nameAr: 'الهرم والرماية ومنصورية'),
        EgyptDistrict(id: 'omraniya_faisal', nameEn: 'El Omraniya & Faisal', nameAr: 'العمرانية وفيصل والطلبية'),
        EgyptDistrict(id: 'boulaq_dakrour', nameEn: 'Boulaq El Dakrour', nameAr: 'بولاق الدكرور'),
        EgyptDistrict(id: 'imbaba_warraq', nameEn: 'Imbaba & Warraq', nameAr: 'إمبابة والوراق'),
        EgyptDistrict(id: 'south_giza_moneeb', nameEn: 'South Giza & El Moneeb', nameAr: 'جنوب الجيزة والمنيب'),
        EgyptDistrict(id: 'october_6_city', nameEn: '6th of October City', nameAr: 'مدينة ٦ أكتوبر'),
        EgyptDistrict(id: 'sheikh_zayed', nameEn: 'Sheikh Zayed City', nameAr: 'مدينة الشيخ زايد'),
        EgyptDistrict(id: 'hadayek_october', nameEn: 'Hadayek October & New October', nameAr: 'حدائق أكتوبر وأكتوبر الجديدة'),
        EgyptDistrict(id: 'hawamdeyya', nameEn: 'Al Hawamdeyya City', nameAr: 'مدينة الحوامدية'),
        EgyptDistrict(id: 'badrashein_saqqara', nameEn: 'Al Badrashein & Saqqara', nameAr: 'البدرشين وسقارة وممفيس'),
        EgyptDistrict(id: 'ayat', nameEn: 'Al Ayat City', nameAr: 'مدينة العياط'),
        EgyptDistrict(id: 'saff', nameEn: 'Al Saff City', nameAr: 'مدينة الصف'),
        EgyptDistrict(id: 'atfih', nameEn: 'Atfih City', nameAr: 'مدينة أطفيح'),
        EgyptDistrict(id: 'oseem', nameEn: 'Oseem City', nameAr: 'مدينة أوسيم'),
        EgyptDistrict(id: 'kerdasa', nameEn: 'Kerdasa City', nameAr: 'مدينة كرداسة وأبو رواش'),
        EgyptDistrict(id: 'bawiti_bahariya', nameEn: 'Al Bawiti (Bahariya Oasis)', nameAr: 'البويطي (الواحات البحرية)'),
      ],
    ),

    // 3. Alexandria Governorate (الإسكندرية)
    EgyptGovernorate(
      id: 'alexandria',
      nameEn: 'Alexandria Governorate',
      nameAr: 'محافظة الإسكندرية',
      districts: [
        EgyptDistrict(id: 'montaza_first', nameEn: 'Montaza (Miami & Sidi Bishr)', nameAr: 'المنتزه (ميامي وسيدي بشر)'),
        EgyptDistrict(id: 'montaza_second', nameEn: 'Montaza (Asafra & Maamoura & Abu Qir)', nameAr: 'المنتزه (العصافرة والمعمورة وأبو قير)'),
        EgyptDistrict(id: 'sharq_alex', nameEn: 'Sharq (Smouha, Stanley, Gleem, Kafr Abdo)', nameAr: 'شرق (سموحة وستانلي وجليم وكفر عبده)'),
        EgyptDistrict(id: 'san_stefano_sidi_gaber', nameEn: 'San Stefano & Sidi Gaber & Roushdy', nameAr: 'سان ستيفانو وسيدي جابر ورشدي'),
        EgyptDistrict(id: 'wast_alex', nameEn: 'Wast (Moharam Bek, Shatby, Hadara)', nameAr: 'وسط (محرم بك والشاطبي والحضرة)'),
        EgyptDistrict(id: 'gharb_alex', nameEn: 'Gharb (Karmous, Wardian, Qabbari)', nameAr: 'غرب (كرموز والورديان والقباري)'),
        EgyptDistrict(id: 'gomrok', nameEn: 'Gomrok (Mansheya, Bahary, Anfoushi)', nameAr: 'الجمرك (المنشية وبحري والأنفوشي)'),
        EgyptDistrict(id: 'agami', nameEn: 'El Agami (Bitash & Hannoville)', nameAr: 'العجمي (البيطاش والهانوفيل)'),
        EgyptDistrict(id: 'amreya', nameEn: 'Amreya & King Mariout', nameAr: 'العامرية وكينج مريوط'),
        EgyptDistrict(id: 'borg_el_arab', nameEn: 'Borg El Arab City & Airport', nameAr: 'برج العرب والمطار'),
        EgyptDistrict(id: 'new_borg_el_arab', nameEn: 'New Borg El Arab City', nameAr: 'مدينة برج العرب الجديدة'),
      ],
    ),

    // 4. Qalyubia Governorate (القليوبية)
    EgyptGovernorate(
      id: 'qalyubia',
      nameEn: 'Qalyubia Governorate',
      nameAr: 'محافظة القليوبية',
      districts: [
        EgyptDistrict(id: 'banha', nameEn: 'Banha (Capital)', nameAr: 'بنها (العاصمة)'),
        EgyptDistrict(id: 'shubra_el_kheima', nameEn: 'Shubra El Kheima (West & East)', nameAr: 'شبرا الخيمة (شرق وغرب)'),
        EgyptDistrict(id: 'obour_city', nameEn: 'El Obour City & Golf City', nameAr: 'مدينة العبور وجولف سيتي'),
        EgyptDistrict(id: 'qalyub', nameEn: 'Qalyub City', nameAr: 'مدينة قليوب'),
        EgyptDistrict(id: 'khanka', nameEn: 'El Khanka & Abu Zaabal', nameAr: 'الخانكة وأبو زعبل'),
        EgyptDistrict(id: 'qanater', nameEn: 'Al Qanater Al Khayreya', nameAr: 'القناطر الخيرية'),
        EgyptDistrict(id: 'shibin_el_qanater', nameEn: 'Shibin El Qanater City', nameAr: 'شبين القناطر'),
        EgyptDistrict(id: 'tookh', nameEn: 'Tookh & Moshtohor', nameAr: 'طوخ ومشتهر'),
        EgyptDistrict(id: 'kafr_shukr', nameEn: 'Kafr Shukr City', nameAr: 'كفر شكر'),
        EgyptDistrict(id: 'qaha', nameEn: 'Qaha City', nameAr: 'مدينة قها'),
        EgyptDistrict(id: 'khosous', nameEn: 'El Khosous City', nameAr: 'مدينة الخصوص'),
      ],
    ),

    // 5. Dakahlia Governorate (الدقهلية)
    EgyptGovernorate(
      id: 'dakahlia',
      nameEn: 'Dakahlia Governorate',
      nameAr: 'محافظة الدقهلية',
      districts: [
        EgyptDistrict(id: 'mansoura', nameEn: 'Mansoura City (East & West)', nameAr: 'مدينة المنصورة (شرق وغرب)'),
        EgyptDistrict(id: 'talkha', nameEn: 'Talkha City', nameAr: 'مدينة طلخا'),
        EgyptDistrict(id: 'mit_ghamr', nameEn: 'Mit Ghamr City', nameAr: 'مدينة ميت غمر'),
        EgyptDistrict(id: 'dikirnis', nameEn: 'Dikirnis City', nameAr: 'مدينة دكرنس'),
        EgyptDistrict(id: 'bilqas', nameEn: 'Bilqas City', nameAr: 'مدينة بلقاس'),
        EgyptDistrict(id: 'senbellawein', nameEn: 'Senbellawein City', nameAr: 'مدينة السنبلاوين'),
        EgyptDistrict(id: 'sherbin', nameEn: 'Sherbin City', nameAr: 'مدينة شربين'),
        EgyptDistrict(id: 'manzala_matariya', nameEn: 'Manzala & Al Matariya', nameAr: 'المنزلة والمطرية'),
        EgyptDistrict(id: 'gamasa', nameEn: 'Gamasa Summer Resort', nameAr: 'مدينة جمصة السياحية'),
        EgyptDistrict(id: 'new_mansoura', nameEn: 'New Mansoura City', nameAr: 'مدينة المنصورة الجديدة'),
        EgyptDistrict(id: 'other_dakahlia', nameEn: 'Aga, Nabroh & Minyet El Nasr', nameAr: 'أجا ونبروه ومنية النصر'),
      ],
    ),

    // 6. Gharbia Governorate (الغربية)
    EgyptGovernorate(
      id: 'gharbia',
      nameEn: 'Gharbia Governorate',
      nameAr: 'محافظة الغربية',
      districts: [
        EgyptDistrict(id: 'tanta', nameEn: 'Tanta City (1st & 2nd Districts)', nameAr: 'مدينة طنطا (أول وثان)'),
        EgyptDistrict(id: 'mahalla', nameEn: 'El Mahalla El Kubra', nameAr: 'المحلة الكبرى'),
        EgyptDistrict(id: 'kafr_el_zayat', nameEn: 'Kafr El Zayat City', nameAr: 'كفر الزيات'),
        EgyptDistrict(id: 'zifta', nameEn: 'Zifta City', nameAr: 'مدينة زفتى'),
        EgyptDistrict(id: 'samannud', nameEn: 'Samannud City', nameAr: 'مدينة سمنود'),
        EgyptDistrict(id: 'basyoun', nameEn: 'Basyoun & Nagrig', nameAr: 'بسيون ونجريج'),
        EgyptDistrict(id: 'qutur', nameEn: 'Qutur City', nameAr: 'مدينة قطور'),
        EgyptDistrict(id: 'santa', nameEn: 'El Santa City', nameAr: 'مدينة السنطة'),
      ],
    ),

    // 7. Sharqia Governorate (الشرقية)
    EgyptGovernorate(
      id: 'sharqia',
      nameEn: 'Sharqia Governorate',
      nameAr: 'محافظة الشرقية',
      districts: [
        EgyptDistrict(id: 'zagazig', nameEn: 'Zagazig City (1st & 2nd Districts)', nameAr: 'مدينة الزقازيق (أول وثان)'),
        EgyptDistrict(id: 'ramadan_10', nameEn: '10th of Ramadan City', nameAr: 'مدينة ١٠ رمضان'),
        EgyptDistrict(id: 'bilbeis', nameEn: 'Bilbeis City', nameAr: 'مدينة بلبيس'),
        EgyptDistrict(id: 'faqous', nameEn: 'Faqous City', nameAr: 'مدينة فاقوس'),
        EgyptDistrict(id: 'minya_el_qamh', nameEn: 'Minya El Qamh City', nameAr: 'منيا القمح'),
        EgyptDistrict(id: 'abu_kabir', nameEn: 'Abu Kabir City', nameAr: 'أبو كبير'),
        EgyptDistrict(id: 'hihya', nameEn: 'Hihya City', nameAr: 'مدينة ههيا'),
        EgyptDistrict(id: 'diarb_negm', nameEn: 'Diarb Negm City', nameAr: 'ديرب نجم'),
        EgyptDistrict(id: 'kafr_saqr', nameEn: 'Kafr Saqr & Awlad Saqr', nameAr: 'كفر صقر وأولاد صقر'),
        EgyptDistrict(id: 'salheya', nameEn: 'Al Salheya El Gedida City', nameAr: 'الصالحية الجديدة'),
        EgyptDistrict(id: 'other_sharqia', nameEn: 'Abu Hammad & El Husseiniya', nameAr: 'أبو حماد والحسينية ومشتول السوق'),
      ],
    ),

    // 8. Monufia Governorate (المنوفية)
    EgyptGovernorate(
      id: 'monufia',
      nameEn: 'Monufia Governorate',
      nameAr: 'محافظة المنوفية',
      districts: [
        EgyptDistrict(id: 'shibin_el_kom', nameEn: 'Shibin El Kom City (East & West)', nameAr: 'شبين الكوم (شرق وغرب)'),
        EgyptDistrict(id: 'sadat_city', nameEn: 'Sadat City', nameAr: 'مدينة السادات'),
        EgyptDistrict(id: 'menouf', nameEn: 'Menouf City', nameAr: 'مدينة منوف'),
        EgyptDistrict(id: 'ashmoun', nameEn: 'Ashmoun City', nameAr: 'مدينة أشمون'),
        EgyptDistrict(id: 'quesna', nameEn: 'Quesna City & Industrial Zone', nameAr: 'قويسنا والمنطقة الصناعية'),
        EgyptDistrict(id: 'berket_el_sabaa', nameEn: 'Berket El Sabaa City', nameAr: 'بركة السبع'),
        EgyptDistrict(id: 'tala', nameEn: 'Tala City', nameAr: 'مدينة تلا'),
        EgyptDistrict(id: 'bagour', nameEn: 'El Bagour City', nameAr: 'الباجور'),
        EgyptDistrict(id: 'shohada', nameEn: 'El Shohada City', nameAr: 'الشهداء'),
        EgyptDistrict(id: 'sers_el_lyan', nameEn: 'Sers El Lyan City', nameAr: 'سرس الليان'),
      ],
    ),

    // 9. Beheira Governorate (البحيرة)
    EgyptGovernorate(
      id: 'beheira',
      nameEn: 'Beheira Governorate',
      nameAr: 'محافظة البحيرة',
      districts: [
        EgyptDistrict(id: 'damanhur', nameEn: 'Damanhur City', nameAr: 'مدينة دمنهور'),
        EgyptDistrict(id: 'kafr_el_dawwar', nameEn: 'Kafr El Dawwar City', nameAr: 'كفر الدوار'),
        EgyptDistrict(id: 'rashid', nameEn: 'Rashid (Rosetta) City', nameAr: 'مدينة رشيد'),
        EgyptDistrict(id: 'edku', nameEn: 'Edku City', nameAr: 'مدينة إدكو'),
        EgyptDistrict(id: 'abu_hummus', nameEn: 'Abu Hummus City', nameAr: 'أبو حمص'),
        EgyptDistrict(id: 'hosh_essa', nameEn: 'Hosh Essa City', nameAr: 'حوش عيسى'),
        EgyptDistrict(id: 'kom_hamada', nameEn: 'Kom Hamada City', nameAr: 'كوم حمادة'),
        EgyptDistrict(id: 'delengat', nameEn: 'Delengat City', nameAr: 'الدلنجات'),
        EgyptDistrict(id: 'wadi_el_natrun', nameEn: 'Wadi El Natrun City', nameAr: 'وادي النطرون'),
        EgyptDistrict(id: 'badr_beheira', nameEn: 'Badr City (Beheira)', nameAr: 'بدر (البحيرة)'),
        EgyptDistrict(id: 'other_beheira', nameEn: 'El Mahmoudiyah & Noubaria El Gedida', nameAr: 'المحمودية والنوبارية الجديدة وأبو المطامير'),
      ],
    ),

    // 10. Kafr El-Sheikh Governorate (كفر الشيخ)
    EgyptGovernorate(
      id: 'kafr_el_sheikh',
      nameEn: 'Kafr El-Sheikh Governorate',
      nameAr: 'محافظة كفر الشيخ',
      districts: [
        EgyptDistrict(id: 'kafr_el_sheikh_city', nameEn: 'Kafr El-Sheikh City (1st & 2nd)', nameAr: 'مدينة كفر الشيخ (أول وثان)'),
        EgyptDistrict(id: 'desouk', nameEn: 'Desouk City', nameAr: 'مدينة دسوق'),
        EgyptDistrict(id: 'baltim', nameEn: 'Baltim & Masyaf Baltim', nameAr: 'بلطيم ومصيف بلطيم'),
        EgyptDistrict(id: 'fuwah', nameEn: 'Fuwah City', nameAr: 'مدينة فوه'),
        EgyptDistrict(id: 'metoubes', nameEn: 'Metoubes City', nameAr: 'مدينة مطوبس'),
        EgyptDistrict(id: 'qallin', nameEn: 'Qallin City', nameAr: 'مدينة قلين'),
        EgyptDistrict(id: 'sidi_salem', nameEn: 'Sidi Salem City', nameAr: 'سيدي سالم'),
        EgyptDistrict(id: 'hamool', nameEn: 'El Hamool City', nameAr: 'الحامول'),
        EgyptDistrict(id: 'biyala', nameEn: 'Biyala City', nameAr: 'مدينة بيلا'),
      ],
    ),

    // 11. Damietta Governorate (دمياط)
    EgyptGovernorate(
      id: 'damietta',
      nameEn: 'Damietta Governorate',
      nameAr: 'محافظة دمياط',
      districts: [
        EgyptDistrict(id: 'damietta_city', nameEn: 'Damietta City (1st & 2nd)', nameAr: 'مدينة دمياط (أول وثان)'),
        EgyptDistrict(id: 'ras_el_bar', nameEn: 'Ras El Bar City & El Lisan', nameAr: 'مدينة رأس البر واللسان'),
        EgyptDistrict(id: 'new_damietta', nameEn: 'New Damietta City', nameAr: 'مدينة دمياط الجديدة'),
        EgyptDistrict(id: 'faraskur', nameEn: 'Faraskur City', nameAr: 'مدينة فارسكور'),
        EgyptDistrict(id: 'zarqa', nameEn: 'Zarqa City', nameAr: 'مدينة الزرقا'),
        EgyptDistrict(id: 'kafr_saad', nameEn: 'Kafr Saad City', nameAr: 'كفر سعد'),
        EgyptDistrict(id: 'ezbet_el_borg', nameEn: 'Ezbet El Borg Harbor', nameAr: 'عزبة البرج'),
      ],
    ),

    // 12. Port Said Governorate (بورسعيد)
    EgyptGovernorate(
      id: 'port_said',
      nameEn: 'Port Said Governorate',
      nameAr: 'محافظة بورسعيد',
      districts: [
        EgyptDistrict(id: 'sharq_port_said', nameEn: 'Sharq (Downtown & Port)', nameAr: 'حي شرق بورسعيد'),
        EgyptDistrict(id: 'al_arab', nameEn: 'Al Arab (Souq El Samak)', nameAr: 'حي العرب'),
        EgyptDistrict(id: 'al_manakh', nameEn: 'Al Manakh (23rd July St)', nameAr: 'حي المناخ'),
        EgyptDistrict(id: 'al_zohour', nameEn: 'Al Zohour (Mostafa Kamel)', nameAr: 'حي الزهور'),
        EgyptDistrict(id: 'al_dawahy', nameEn: 'Al Dawahy (Mubarak & Bus Station)', nameAr: 'حي الضواحي'),
        EgyptDistrict(id: 'janoub_gharb', nameEn: 'Al Janoub & Al Gharb', nameAr: 'حي الجنوب وحي الغرب'),
        EgyptDistrict(id: 'port_fouad', nameEn: 'Port Fouad City & Canal Sector', nameAr: 'مدينة بورفؤاد'),
      ],
    ),

    // 13. Ismailia Governorate (الإسماعيلية)
    EgyptGovernorate(
      id: 'ismailia',
      nameEn: 'Ismailia Governorate',
      nameAr: 'محافظة الإسماعيلية',
      districts: [
        EgyptDistrict(id: 'ismailia_city', nameEn: 'Ismailia City (1st, 2nd, 3rd)', nameAr: 'مدينة الإسماعيلية (أول وثان وثالث)'),
        EgyptDistrict(id: 'fayed', nameEn: 'Fayed City & Fanara', nameAr: 'فايد وفنارة وأبو سلطان'),
        EgyptDistrict(id: 'qantara_sharq', nameEn: 'El Qantara Sharq City', nameAr: 'القنطرة شرق والمنطقة الحرة'),
        EgyptDistrict(id: 'qantara_gharb', nameEn: 'El Qantara Gharb City', nameAr: 'القنطرة غرب'),
        EgyptDistrict(id: 'tal_el_kebir', nameEn: 'El Tal El Kebir City', nameAr: 'التل الكبير'),
        EgyptDistrict(id: 'abu_suwir_qassasin', nameEn: 'Abu Suwir & El Qassasin', nameAr: 'أبو صوير والقساسين'),
      ],
    ),

    // 14. Suez Governorate (السويس)
    EgyptGovernorate(
      id: 'suez',
      nameEn: 'Suez Governorate',
      nameAr: 'محافظة السويس',
      districts: [
        EgyptDistrict(id: 'suez_district', nameEn: 'El Suez District & Port Tewfik', nameAr: 'حي السويس وبورتوفيق'),
        EgyptDistrict(id: 'arbaeen_district', nameEn: 'El Arbaeen District', nameAr: 'حي الأربعين'),
        EgyptDistrict(id: 'faisal_district', nameEn: 'Faisal District (Al Sabah & Al Salam)', nameAr: 'حي فيصل (الصباح والسلام)'),
        EgyptDistrict(id: 'attaka_sokhna', nameEn: 'Attaka & Ain Sokhna Coastal Strip', nameAr: 'حي عتاقة والعين السخنة'),
        EgyptDistrict(id: 'ganayen_district', nameEn: 'El Ganayen District', nameAr: 'حي الجناين'),
      ],
    ),

    // 15. Matrouh Governorate (مطروح)
    EgyptGovernorate(
      id: 'matrouh',
      nameEn: 'Matrouh Governorate',
      nameAr: 'محافظة مطروح',
      districts: [
        EgyptDistrict(id: 'marsa_matrouh', nameEn: 'Marsa Matrouh City', nameAr: 'مدينة مرسى مطروح'),
        EgyptDistrict(id: 'alamein_marina', nameEn: 'El Alamein & Marina El Alamein', nameAr: 'العلمين ومارينا العلمين'),
        EgyptDistrict(id: 'new_alamein', nameEn: 'New Alamein City (Towers & Latin)', nameAr: 'مدينة العلمين الجديدة'),
        EgyptDistrict(id: 'sidi_abdel_rahman', nameEn: 'Sidi Abdel Rahman (North Coast)', nameAr: 'سيدي عبد الرحمن (الساحل الشمالي)'),
        EgyptDistrict(id: 'dabaa_hekma', nameEn: 'El Dabaa & Ras El Hekma', nameAr: 'الضبعة ورأس الحكمة'),
        EgyptDistrict(id: 'barrani_sallum', nameEn: 'Sidi Barrani & Sallum', nameAr: 'سيدي براني والسلوم'),
        EgyptDistrict(id: 'siwa_oasis', nameEn: 'Siwa Oasis', nameAr: 'واحة سيوة'),
      ],
    ),

    // 16. North Sinai Governorate (شمال سيناء)
    EgyptGovernorate(
      id: 'north_sinai',
      nameEn: 'North Sinai Governorate',
      nameAr: 'محافظة شمال سيناء',
      districts: [
        EgyptDistrict(id: 'arish', nameEn: 'Arish City (Capital)', nameAr: 'مدينة العريش'),
        EgyptDistrict(id: 'sheikh_zuweid', nameEn: 'Sheikh Zuweid City', nameAr: 'الشيخ زويد'),
        EgyptDistrict(id: 'new_rafah', nameEn: 'New Rafah City', nameAr: 'مدينة رفح الجديدة'),
        EgyptDistrict(id: 'bir_el_abd', nameEn: 'Bir El Abd City', nameAr: 'بئر العبد'),
        EgyptDistrict(id: 'nakhil_hasana', nameEn: 'Nakhil & Al Hasana', nameAr: 'نخل والحسنة'),
      ],
    ),

    // 17. South Sinai Governorate (جنوب سيناء)
    EgyptGovernorate(
      id: 'south_sinai',
      nameEn: 'South Sinai Governorate',
      nameAr: 'محافظة جنوب سيناء',
      districts: [
        EgyptDistrict(id: 'sharm_el_sheikh', nameEn: 'Sharm El Sheikh (Naama & Nabq & Hadaba)', nameAr: 'شرم الشيخ (نعمة ونبق والهضبة)'),
        EgyptDistrict(id: 'dahab', nameEn: 'Dahab (Mashraba & Blue Hole)', nameAr: 'دهب'),
        EgyptDistrict(id: 'nuweiba', nameEn: 'Nuweiba & Ras Shaitan', nameAr: 'نويبع ورأس شيطان'),
        EgyptDistrict(id: 'taba', nameEn: 'Taba & Taba Heights', nameAr: 'طابا ومرتفعات طابا'),
        EgyptDistrict(id: 'ras_sedr', nameEn: 'Ras Sedr City', nameAr: 'مدينة رأس سدر'),
        EgyptDistrict(id: 'saint_catherine', nameEn: 'Saint Catherine City', nameAr: 'سانت كاترين'),
        EgyptDistrict(id: 'el_tor', nameEn: 'El Tor City (Capital)', nameAr: 'مدينة الطور'),
        EgyptDistrict(id: 'rudeis_zenima', nameEn: 'Abu Rudeis & Abu Zenima', nameAr: 'أبو رديس وأبو زنيمة'),
      ],
    ),

    // 18. Faiyum Governorate (الفيوم)
    EgyptGovernorate(
      id: 'faiyum',
      nameEn: 'Faiyum Governorate',
      nameAr: 'محافظة الفيوم',
      districts: [
        EgyptDistrict(id: 'faiyum_city', nameEn: 'Faiyum City (1st & 2nd)', nameAr: 'مدينة الفيوم (أول وثان)'),
        EgyptDistrict(id: 'sinnuris', nameEn: 'Sinnuris City', nameAr: 'مدينة سنورس'),
        EgyptDistrict(id: 'ibshaway', nameEn: 'Ibshaway City', nameAr: 'مدينة إبشواي'),
        EgyptDistrict(id: 'itsa', nameEn: 'Itsa City', nameAr: 'مدينة إطسا'),
        EgyptDistrict(id: 'tamiya', nameEn: 'Tamiya & Kom Oshim', nameAr: 'طامية وكوم أوشيم'),
        EgyptDistrict(id: 'youssef_seddik', nameEn: 'Youssef El Seddik (Wadi El Rayan)', nameAr: 'يوسف الصديق ووادى الريان'),
        EgyptDistrict(id: 'new_faiyum', nameEn: 'New Faiyum City', nameAr: 'مدينة الفيوم الجديدة'),
      ],
    ),

    // 19. Beni Suef Governorate (بني سويف)
    EgyptGovernorate(
      id: 'beni_suef',
      nameEn: 'Beni Suef Governorate',
      nameAr: 'محافظة بني سويف',
      districts: [
        EgyptDistrict(id: 'beni_suef_city', nameEn: 'Beni Suef City', nameAr: 'مدينة بني سويف'),
        EgyptDistrict(id: 'new_beni_suef', nameEn: 'New Beni Suef City', nameAr: 'مدينة بني سويف الجديدة'),
        EgyptDistrict(id: 'wasta', nameEn: 'El Wasta & Meidum Pyramid', nameAr: 'الواسطى وهرم ميدوم'),
        EgyptDistrict(id: 'nasser_bush', nameEn: 'Nasser (Bush) City', nameAr: 'مدينة ناصر (بوش)'),
        EgyptDistrict(id: 'biba', nameEn: 'Biba City', nameAr: 'مدينة ببا'),
        EgyptDistrict(id: 'ihnasiya', nameEn: 'Ihnasiya City', nameAr: 'إهناسيا المدينة'),
        EgyptDistrict(id: 'samasta_fashn', nameEn: 'Samasta & El Fashn', nameAr: 'سمسطا والفشن'),
      ],
    ),

    // 20. Minya Governorate (المنيا)
    EgyptGovernorate(
      id: 'minya',
      nameEn: 'Minya Governorate',
      nameAr: 'محافظة المنيا',
      districts: [
        EgyptDistrict(id: 'minya_city', nameEn: 'Minya City (Kornish & Ard Sultan)', nameAr: 'مدينة المنيا'),
        EgyptDistrict(id: 'new_minya', nameEn: 'New Minya City', nameAr: 'مدينة المنيا الجديدة'),
        EgyptDistrict(id: 'mallawi', nameEn: 'Mallawi & Tuna El Gebel', nameAr: 'ملوي وتونة الجبل'),
        EgyptDistrict(id: 'samalut', nameEn: 'Samalut & Gabal El Teir', nameAr: 'سمالوط وجبل الطير'),
        EgyptDistrict(id: 'maghagha', nameEn: 'Maghagha City', nameAr: 'مدينة مغاغة'),
        EgyptDistrict(id: 'bani_mazaer', nameEn: 'Bani Mazar & Al Bahnasa', nameAr: 'بني مزار والبهنسا'),
        EgyptDistrict(id: 'abu_qurqas', nameEn: 'Abu Qurqas (Beni Hassan)', nameAr: 'أبو قرقاص وبني حسن'),
        EgyptDistrict(id: 'matay_deir_mawas', nameEn: 'Matay & Deir Mawas & El Idwa', nameAr: 'مطاي ودير مواس والعدوة'),
      ],
    ),

    // 21. Asyut Governorate (أسيوط)
    EgyptGovernorate(
      id: 'asyut',
      nameEn: 'Asyut Governorate',
      nameAr: 'محافظة أسيوط',
      districts: [
        EgyptDistrict(id: 'asyut_city', nameEn: 'Asyut City (1st & 2nd)', nameAr: 'مدينة أسيوط (شرق وغرب)'),
        EgyptDistrict(id: 'new_asyut', nameEn: 'New Asyut City', nameAr: 'مدينة أسيوط الجديدة'),
        EgyptDistrict(id: 'dairut', nameEn: 'Dairut City', nameAr: 'مدينة ديروط'),
        EgyptDistrict(id: 'qusiya', nameEn: 'El Qusiya City', nameAr: 'مدينة القوصية'),
        EgyptDistrict(id: 'manfalut', nameEn: 'Manfalut City', nameAr: 'مدينة منفلوط'),
        EgyptDistrict(id: 'abnoub_badari', nameEn: 'Abnoub & El Badari', nameAr: 'أبنوب والبداري'),
        EgyptDistrict(id: 'other_asyut', nameEn: 'Sahel Selim & Sedfa & El Ghanayem', nameAr: 'ساحل سليم وصدفا والغنايم'),
      ],
    ),

    // 22. Sohag Governorate (سوهاج)
    EgyptGovernorate(
      id: 'sohag',
      nameEn: 'Sohag Governorate',
      nameAr: 'محافظة سوهاج',
      districts: [
        EgyptDistrict(id: 'sohag_city', nameEn: 'Sohag City (East & West)', nameAr: 'مدينة سوهاج (شرق وغرب)'),
        EgyptDistrict(id: 'new_sohag', nameEn: 'New Sohag City (Kawamel)', nameAr: 'مدينة سوهاج الجديدة (الكوامل)'),
        EgyptDistrict(id: 'akhmim', nameEn: 'Akhmim City', nameAr: 'مدينة أخميم'),
        EgyptDistrict(id: 'girga', nameEn: 'Girga City', nameAr: 'مدينة جرجا'),
        EgyptDistrict(id: 'tahta', nameEn: 'Tahta City', nameAr: 'مدينة طهطا'),
        EgyptDistrict(id: 'balyana_abydos', nameEn: 'El Balyana & Abydos', nameAr: 'البلينا وأبيدوس'),
        EgyptDistrict(id: 'maragha_dar_salam', nameEn: 'El Maragha & Dar El Salam', nameAr: 'المراغة ودار السلام'),
        EgyptDistrict(id: 'juhayna_tema', nameEn: 'Juhayna & Saqultah & Tema', nameAr: 'جهينة وساقلتة وطما'),
      ],
    ),

    // 23. Qena Governorate (قنا)
    EgyptGovernorate(
      id: 'qena',
      nameEn: 'Qena Governorate',
      nameAr: 'محافظة قنا',
      districts: [
        EgyptDistrict(id: 'qena_city', nameEn: 'Qena City & Dandarah', nameAr: 'مدينة قنا ودندرة'),
        EgyptDistrict(id: 'new_qena', nameEn: 'New Qena City', nameAr: 'مدينة قنا الجديدة'),
        EgyptDistrict(id: 'nag_hammadi', nameEn: 'Nag Hammadi & Aluminum City', nameAr: 'نجع حمادي ومدينة الألومنيوم'),
        EgyptDistrict(id: 'deshna', nameEn: 'Deshna City', nameAr: 'مدينة دشنا'),
        EgyptDistrict(id: 'qus', nameEn: 'Qus City', nameAr: 'مدينة قوص'),
        EgyptDistrict(id: 'farshut_tesht', nameEn: 'Farshut & Abu Tesht', nameAr: 'فرشوط وأبو تشت'),
        EgyptDistrict(id: 'qift_naqada', nameEn: 'Qift & Naqada & El Waqf', nameAr: 'قفط ونقادة والوقف'),
      ],
    ),

    // 24. Luxor Governorate (الأقصر)
    EgyptGovernorate(
      id: 'luxor',
      nameEn: 'Luxor Governorate',
      nameAr: 'محافظة الأقصر',
      districts: [
        EgyptDistrict(id: 'luxor_east_bank', nameEn: 'Luxor East Bank (Karnak & Medina)', nameAr: 'الأقصر البر الشرقي (الكرنك والمدينة)'),
        EgyptDistrict(id: 'luxor_west_bank', nameEn: 'Luxor West Bank (Qarna & Habu)', nameAr: 'الأقصر البر الغربي (القرنة ومحطوة هابو)'),
        EgyptDistrict(id: 'esna', nameEn: 'Esna City', nameAr: 'مدينة إسنا'),
        EgyptDistrict(id: 'armant', nameEn: 'Armant City', nameAr: 'مدينة أرمنت'),
        EgyptDistrict(id: 'bayadiya_tod', nameEn: 'El Bayadiya & El Tod', nameAr: 'البياضية والطود'),
        EgyptDistrict(id: 'new_tiba', nameEn: 'New Tiba City', nameAr: 'مدينة طيبة الجديدة'),
      ],
    ),

    // 25. Aswan Governorate (أسوان)
    EgyptGovernorate(
      id: 'aswan',
      nameEn: 'Aswan Governorate',
      nameAr: 'محافظة أسوان',
      districts: [
        EgyptDistrict(id: 'aswan_city', nameEn: 'Aswan City & Elephantine Island', nameAr: 'مدينة أسوان وجزيرة النباتات'),
        EgyptDistrict(id: 'new_aswan', nameEn: 'New Aswan City', nameAr: 'مدينة أسوان الجديدة'),
        EgyptDistrict(id: 'kom_ombo', nameEn: 'Kom Ombo City', nameAr: 'كوم أمبو'),
        EgyptDistrict(id: 'edfu', nameEn: 'Edfu City', nameAr: 'مدينة إدفو'),
        EgyptDistrict(id: 'nasr_nuba', nameEn: 'Nasr El Nuba City', nameAr: 'نصر النوبة'),
        EgyptDistrict(id: 'daraw_banban', nameEn: 'Daraw & Banban Solar Sector', nameAr: 'دراو وبنبان'),
        EgyptDistrict(id: 'abu_simbel', nameEn: 'Abu Simbel Temples & Airport', nameAr: 'أبو سمبل'),
      ],
    ),

    // 26. Red Sea Governorate (البحر الأحمر)
    EgyptGovernorate(
      id: 'red_sea',
      nameEn: 'Red Sea Governorate',
      nameAr: 'محافظة البحر الأحمر',
      districts: [
        EgyptDistrict(id: 'hurghada_dahar', nameEn: 'Hurghada (El Dahar / Old Town)', nameAr: 'الغردقة (الدهار)'),
        EgyptDistrict(id: 'hurghada_sekalla', nameEn: 'Hurghada (Sekalla & New Marina)', nameAr: 'الغردقة (السقالة والمارينا)'),
        EgyptDistrict(id: 'hurghada_kawther', nameEn: 'Hurghada (El Kawther & El Mamsha)', nameAr: 'الغردقة (الكوثر والممشى)'),
        EgyptDistrict(id: 'el_gouna', nameEn: 'El Gouna Resort', nameAr: 'منتجع الجونة'),
        EgyptDistrict(id: 'sahl_hasheesh_makadi', nameEn: 'Sahl Hasheesh & Makadi Bay', nameAr: 'سهل حشيش ومكادي باي'),
        EgyptDistrict(id: 'safaga_soma_bay', nameEn: 'Safaga & Soma Bay', nameAr: 'سفاجا وسوما باي'),
        EgyptDistrict(id: 'quseir', nameEn: 'El Quseir City', nameAr: 'مدينة القصير'),
        EgyptDistrict(id: 'marsa_alam_ghalib', nameEn: 'Marsa Alam & Port Ghalib', nameAr: 'مرسى علم وبورت غالب'),
        EgyptDistrict(id: 'ras_gharib', nameEn: 'Ras Gharib City', nameAr: 'مدينة رأس غارب'),
        EgyptDistrict(id: 'shalateen_halayeb', nameEn: 'Shalateen & Halayeb', nameAr: 'شلاتين وحلايب'),
      ],
    ),

    // 27. New Valley Governorate (الوادي الجديد)
    EgyptGovernorate(
      id: 'new_valley',
      nameEn: 'New Valley Governorate',
      nameAr: 'محافظة الوادي الجديد',
      districts: [
        EgyptDistrict(id: 'kharga_oasis', nameEn: 'Kharga City (El Kharga Oasis)', nameAr: 'الخارجة (واحة الخارجة)'),
        EgyptDistrict(id: 'dakhla_oasis', nameEn: 'Dakhla City (El Dakhla Oasis / Mut)', nameAr: 'الداخلة (واحة الداخلة)'),
        EgyptDistrict(id: 'farafra_oasis', nameEn: 'Farafra City (El Farafra Oasis)', nameAr: 'الفرافرة (واحة الفرافرة)'),
        EgyptDistrict(id: 'paris_baris', nameEn: 'Paris City (Baris)', nameAr: 'مدينة باريس'),
        EgyptDistrict(id: 'balat_town', nameEn: 'Balat Historic Mudbrick Town', nameAr: 'مدينة بلاط التاريخية'),
      ],
    ),
  ];

  /// Finds governorate matching [query] (case-insensitive name check in EN/AR).
  static EgyptGovernorate findGovernorate(String query) {
    final lower = query.trim().toLowerCase();
    return governorates.firstWhere(
      (g) =>
          g.nameEn.toLowerCase() == lower ||
          g.nameAr.toLowerCase() == lower ||
          g.id == lower ||
          g.nameEn.toLowerCase().contains(lower) ||
          g.nameAr.toLowerCase().contains(lower),
      orElse: () => governorates.first, // Defaults to Cairo
    );
  }

  /// Finds district inside [governorate] matching [query] (case-insensitive check).
  static EgyptDistrict findDistrict(EgyptGovernorate governorate, String query) {
    final lower = query.trim().toLowerCase();
    return governorate.districts.firstWhere(
      (d) =>
          d.nameEn.toLowerCase() == lower ||
          d.nameAr.toLowerCase() == lower ||
          d.id == lower ||
          d.nameEn.toLowerCase().contains(lower) ||
          d.nameAr.toLowerCase().contains(lower),
      orElse: () => governorate.districts.first,
    );
  }
}
