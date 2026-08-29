import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';

class KbliMockData {
  static final List<KbliItem> _masterDataset = [
    KbliItem(
      type: 'KBLI 2025',
      kode: '01121',
      judul: 'PERTANIAN PADI HIBRIDA',
      deskripsi:
          'Kelompok ini mencakup kegiatan pertanian padi hibrida, termasuk di dalamnya kegiatan pengolahan lahan, penanaman bibit, pemeliharaan, pemupukan, pengendalian hama terpadu, hingga pemanenan padi hibrida di lahan sawah irigasi maupun tadah hujan.',
      contohLapangan: [
        'Petani yang menanam benih padi hibrida bernas prima di sawah irigasi',
        'Kegiatan mencabut rumput liar dan pemupukan di sawah padi hibrida',
        'Pemanenan padi hibrida menggunakan mesin combine harvester oleh kelompok tani',
      ],
      score: 98,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '01122',
      judul: 'PERTANIAN PADI NON HIBRIDA',
      deskripsi:
          'Kelompok ini mencakup kegiatan pertanian padi lokal/inbrida/non-hibrida (seperti ciherang, inpari, pandan wangi, menthik wangi) dari persiapan lahan hingga pasca panen.',
      contohLapangan: [
        'Petani padi varietas Ciherang dan Inpari 32 di sawah tadah hujan',
        'Penanaman benih padi beras merah dan beras hitam organik',
      ],
      score: 92,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '01111',
      judul: 'PERTANIAN JAGUNG',
      deskripsi:
          'Kelompok ini mencakup usaha pertanian jagung pipil, jagung manis, jagung pakan ternak dari pengolahan tanah, penyemaian, penanaman, pemeliharaan, dan pemungutan hasil.',
      contohLapangan: [
        'Petani jagung manis pipil untuk konsumsi pasar lokal',
        'Budidaya tanaman jagung hibrida untuk pakan ternak di lahan tegalan',
      ],
      score: 95,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '45407',
      judul: 'REPARASI DAN PERAWATAN SEPEDA MOTOR',
      deskripsi:
          'Kelompok ini mencakup usaha reparasi dan perawatan sepeda motor dan sejenisnya, seperti tune-up mesin, servis berkala, ganti oli mesin, perbaikan sistem transmisi, perbaikan kelistrikan motor, dan servis karburator/injeksi.',
      contohLapangan: [
        'Bengkel servis sepeda motor matic dan bebek rumahan',
        'Mekanik bengkel motor yang melakukan tune-up dan ganti oli mesin',
        'Jasa perbaikan kelistrikan dan setting injeksi ECU motor',
      ],
      score: 99,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '45408',
      judul: 'JASA TAMBAL BAN DAN PENCUCIAN SEPEDA MOTOR',
      deskripsi:
          'Kelompok ini mencakup usaha jasa tambal ban motor (tubeless maupun ban dalam), pengisian angin/nitrogen ban, dan jasa pencucian/steam sepeda motor.',
      contohLapangan: [
        'Tukang tambal ban motor tubeless dan ban dalam di pinggir jalan',
        'Jasa isi angin nitrogen dan pres ban bocor keliling',
        'Usaha cuci motor steam salju di garasi rumah',
      ],
      score: 98,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '56102',
      judul: 'WARUNG MAKAN / WARUNG SOTO / KEDAI MAKANAN',
      deskripsi:
          'Kelompok ini mencakup usaha penyediaan makanan dan minuman untuk umum di tempat usahanya yang bersifat sederhana, seperti warung soto, warung makan tegal (warteg), warung gudeg, depot makan, dan kedai nasi rames.',
      contohLapangan: [
        'Warung soto ayam dan soto kerbau khas Demak/Kudus',
        'Usaha warung nasi rames dan lauk pauk siap saji di pinggir jalan',
        'Kedai makan pecel lele dan ayam goreng tenda malam hari',
      ],
      score: 96,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '47111',
      judul: 'PERDAGANGAN ECERAN BARANG KEBUTUHAN POKOK / TOKO KELONTONG',
      deskripsi:
          'Kelompok ini mencakup usaha perdagangan eceran berbagai macam barang kebutuhan sehari-hari yang utamanya makanan, minuman, tembakau, sabun, beras, gula, dan sembako dalam toko atau warung kelontong tradisional maupun minimarket.',
      contohLapangan: [
        'Warung kelontong sembako di teras rumah (jual beras, minyak, telur, mie)',
        'Toko kelontong modern yang menjual sembako eceran kepada warga sekitar',
      ],
      score: 94,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '03211',
      judul: 'BUDIDAYA IKAN AIR TAWAR DI KOLAM (LELE, NILA, GURAME)',
      deskripsi:
          'Kelompok ini mencakup usaha pembenihan, pembesaran, dan pemeliharaan ikan air tawar di kolam tanah, kolam terpal, atau kolam beton seperti lele, nila, gurame, dan patin.',
      contohLapangan: [
        'Peternak pembesaran ikan lele bioflok di pekarangan rumah',
        'Budidaya ikan nila dan gurame sistem kolam air deras di desa',
      ],
      score: 92,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '14111',
      judul: 'PENJAHITAN DAN PEMBUATAN PAKAIAN SESUAI PESANAN (MODISTE/TAILOR)',
      deskripsi:
          'Kelompok ini mencakup usaha pembuatan pakaian jadi sesuai pesanan perseorangan (custom), seperti penjahit pakaian pria/wanita, penjahit kebaya, permak levis, dan bordir rumahan.',
      contohLapangan: [
        'Penjahit baju rumahan untuk seragam sekolah, batik, dan gamis',
        'Jasa permak celana levis, potong sambung, dan ganti resleting baju',
      ],
      score: 93,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '49424',
      judul: 'ANGKUTAN OJEK SEPEDA MOTOR (OJEK ONLINE / PANGKALAN)',
      deskripsi:
          'Kelompok ini mencakup usaha pengangkutan penumpang dengan kendaraan bermotor roda dua (sepeda motor) berbasis aplikasi digital (ojol) maupun pangkalan.',
      contohLapangan: [
        'Driver ojek online pengangkut penumpang harian di wilayah perkotaan',
        'Pengemudi ojek pangkalan di pertigaan jalan desa',
      ],
      score: 95,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '6111',
      judul: 'PETANI TANAMAN PANGAN DAN SAYURAN',
      deskripsi:
          'Profesi yang merencanakan, mengelola, dan melakukan kegiatan pertanian tanaman pangan (padi, jagung, kedelai, palawija) dan sayuran untuk dijual atau dikonsumsi.',
      contohLapangan: [
        'Petani pemilik dan penggarap sawah padi di desa',
        'Petani kebun cabai, bawang merah, dan tomat',
      ],
      score: 95,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '7231',
      judul: 'MEKANIK DAN MONTIR KENDARAAN BERMOTOR',
      deskripsi:
          'Tenaga kerja yang memasang, menyetel, merawat, dan memperbaiki mesin serta bagian mekanik pada sepeda motor dan mobil.',
      contohLapangan: [
        'Montir bengkel sepeda motor yang melakukan overhaul dan servis mesin',
        'Mekanik panggilan perbaikan motor mogok di jalan',
      ],
      score: 96,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '9211',
      judul: 'BURUH TANI DAN PEKERJA KASAR PERTANIAN',
      deskripsi:
          'Pekerja yang melakukan tugas-tugas sederhana dalam pertanian, seperti mencangkul tanah, menanam bibit, menyiangi gulma, dan memotong tanaman saat panen.',
      contohLapangan: [
        'Buruh derep (buruh potong padi saat panen raya)',
        'Buruh tandur (buruh tanam bibit padi di sawah)',
        'Buruh pemotong tebu di perkebunan rakyat',
      ],
      score: 97,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '5221',
      judul: 'PEDAGANG DAN PELAYAN TOKO KELONTONG',
      deskripsi:
          'Tenaga kerja yang mengelola operasional toko eceran kecil, melayani pembeli, mencatat stok sembako, dan menerima pembayaran barang.',
      contohLapangan: [
        'Penjaga warung kelontong sembako harian',
        'Kasir dan pelayan toko kelontong di pasar tradisional',
      ],
      score: 93,
      matchType: 'keyword',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '8322',
      judul: 'PENGEMUDI SEPEDA MOTOR DAN OJEK',
      deskripsi:
          'Pengemudi yang mengendarai sepeda motor roda dua untuk mengangkut penumpang atau mengantarkan paket kiriman makanan dan barang.',
      contohLapangan: [
        'Mitra driver ojek online pengantar penumpang dan makanan',
        'Kurir ekspedisi pengantar paket belanja online menggunakan motor',
      ],
      score: 94,
      matchType: 'keyword',
    ),
  ];

  /// Simulates intelligent search across KBLI and KBJI masters.
  static Future<List<KbliItem>> search(String query, {String? type, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 250)); // Simulates network response
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return [];

    final terms = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final matched = _masterDataset.where((item) {
      // Filter by type if requested
      if (type != null && type.isNotEmpty && type != 'ALL') {
        if (!item.type.toUpperCase().contains(type.toUpperCase())) {
          return false;
        }
      }

      final textToSearch = '${item.kode} ${item.judul} ${item.deskripsi} ${item.contohLapangan.join(" ")}'.toLowerCase();
      return terms.any((term) => textToSearch.contains(term));
    }).toList();

    // If query didn't match specific predefined keywords, provide related fallbacks
    if (matched.isEmpty) {
      final sample = _masterDataset.where((item) {
        if (type != null && type.isNotEmpty && type != 'ALL') {
          return item.type.toUpperCase().contains(type.toUpperCase());
        }
        return true;
      }).take(3).toList();

      return sample.map((item) => KbliItem(
        type: item.type,
        kode: item.kode,
        judul: item.judul,
        deskripsi: item.deskripsi,
        contohLapangan: item.contohLapangan,
        score: 75,
        matchType: 'semantic_fallback',
      )).toList();
    }

    return matched.take(limit).toList();
  }

  /// Hierarchy Master Data (Categories A - U and child drill-down trees)
  static Future<List<KbliHierarchyItem>> getHierarchy({String? parent}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (parent == null || parent.isEmpty) {
      // Top Level: Categories A - U
      return [
        KbliHierarchyItem(
          kode: 'A',
          judul: 'Pertanian, Kehutanan Dan Perikanan',
          deskripsi: 'Kategori ini mencakup pemanfaatan sumber daya hayati nabati dan hewani melalui penanaman tanaman, budidaya ternak, pemanenan kayu, dan penangkapan/budidaya perikanan.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'B',
          judul: 'Pertambangan Dan Penggalian',
          deskripsi: 'Kategori ini mencakup ekstraksi mineral alam berbentuk padat, cair, atau gas seperti batu bara, minyak bumi, dan pasir galian.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'C',
          judul: 'Industri Pengolahan',
          deskripsi: 'Kategori ini mencakup kegiatan transformasi fisik atau kimia dari bahan, zat, atau komponen menjadi produk baru.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'D',
          judul: 'Pengadaan Listrik, Gas, Uap/Air Panas Dan Udara Dingin',
          deskripsi: 'Pembangkitan, transmisi, dan distribusi tenaga listrik, gas alam melalui pipa, uap dan pendingin.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'E',
          judul: 'Pengelolaan Air, Air Limbah, Pengolahan Sampah Dan Daur Ulang',
          deskripsi: 'Kegiatan pengumpulan, pemurnian, dan distribusi air bersih serta pengolahan limbah dan daur ulang sampah.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'F',
          judul: 'Konstruksi',
          deskripsi: 'Konstruksi umum dan konstruksi khusus untuk bangunan gedung dan bangunan sipil.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'G',
          judul: 'Perdagangan Besar Dan Eceran; Reparasi Mobil & Motor',
          deskripsi: 'Perdagangan grosir dan eceran segala jenis barang tanpa transformasi, serta reparasi mobil dan sepeda motor.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'H',
          judul: 'Pengangkutan Dan Pergudangan',
          deskripsi: 'Penyediaan angkutan penumpang atau barang (darat, air, udara) dan kegiatan pendukung pergudangan.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'I',
          judul: 'Penyediaan Akomodasi Dan Makan Minum',
          deskripsi: 'Penyediaan penginapan jangka pendek (hotel/losmen) dan penyediaan makanan minuman siap konsumsi (restoran, warung, kafe).',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'J',
          judul: 'Informasi Dan Komunikasi',
          deskripsi: 'Penerbitan, penyiaran, telekomunikasi, pemrograman komputer, dan portal web.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'K',
          judul: 'Aktivitas Keuangan Dan Asuransi',
          deskripsi: 'Layanan intermediasi keuangan, perbankan, koperasi simpan pinjam, dan asuransi.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'L',
          judul: 'Real Estat',
          deskripsi: 'Penyewaan dan pengoperasian properti milik sendiri atau sewa seperti perumahan dan ruko.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'M',
          judul: 'Aktivitas Profesional, Ilmiah Dan Teknis',
          deskripsi: 'Jasa hukum, akuntansi, arsitektur, teknik, penelitian, dan konsultasi manajemen.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'N',
          judul: 'Aktivitas Penyewaan, Ketenagakerjaan, Agen Perjalanan',
          deskripsi: 'Penyewaan mesin/peralatan tanpa operator, penyalur tenaga kerja, agen perjalanan wisata.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'P',
          judul: 'Pendidikan',
          deskripsi: 'Pendidikan formal dan nonformal pada semua tingkatan dan bidang profesi.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'Q',
          judul: 'Aktivitas Kesehatan Manusia Dan Sosial',
          deskripsi: 'Pelayanan rumah sakit, klinik, praktik dokter, bidan, dan panti sosial.',
          level: 'Kategori',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: 'S',
          judul: 'Aktivitas Jasa Lainnya',
          deskripsi: 'Jasa perorangan seperti pangkas rambut/salon, penjahit, binatu (laundry), dan reparasi barang elektronik rumah tangga.',
          level: 'Kategori',
          isLeaf: false,
        ),
      ];
    }

    // Drill down Level: Category A
    if (parent == 'A') {
      return [
        KbliHierarchyItem(
          kode: '01',
          judul: 'Pertanian Tanaman, Peternakan, Perburuan Dan Jasa Terkait',
          deskripsi: 'Penanaman tanaman semusim, tanaman tahunan, pembibitan, dan peternakan hewan.',
          level: 'Golongan Pokok',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '02',
          judul: 'Kehutanan Dan Penebangan Kayu',
          deskripsi: 'Penanaman hutan, pemungutan hasil hutan kayu dan bukan kayu.',
          level: 'Golongan Pokok',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '03',
          judul: 'Perikanan Dan Budidaya Perikanan',
          deskripsi: 'Penangkapan ikan di laut/perairan umum dan budidaya biota air tawar/payau/laut.',
          level: 'Golongan Pokok',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '01') {
      return [
        KbliHierarchyItem(
          kode: '011',
          judul: 'Pertanian Tanaman Semusim',
          deskripsi: 'Pertanian tanaman yang umumnya berumur kurang dari satu tahun.',
          level: 'Golongan',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '012',
          judul: 'Pertanian Tanaman Tahunan',
          deskripsi: 'Pertanian tanaman yang hidup lebih dari dua musim tanam.',
          level: 'Golongan',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '014',
          judul: 'Peternakan',
          deskripsi: 'Pemeliharaan dan pembudidayaan sapi, kambing, ayam, bebek, dan ternak lainnya.',
          level: 'Golongan',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '011') {
      return [
        KbliHierarchyItem(
          kode: '0111',
          judul: 'Pertanian Serealia (Bukan Padi), Aneka Kacang Dan Biji Minyak',
          deskripsi: 'Penanaman jagung, kedelai, kacang tanah, dan kacang hijau.',
          level: 'Subgolongan',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '0112',
          judul: 'Pertanian Padi',
          deskripsi: 'Penanaman padi sawah dan padi ladang baik hibrida maupun non-hibrida.',
          level: 'Subgolongan',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '0112') {
      return [
        KbliHierarchyItem(
          kode: '01121',
          judul: 'PERTANIAN PADI HIBRIDA',
          deskripsi: 'Kelompok ini mencakup kegiatan pertanian padi hibrida di lahan sawah irigasi maupun tadah hujan.',
          level: 'Kelompok (5 Digit)',
          isLeaf: true,
        ),
        KbliHierarchyItem(
          kode: '01122',
          judul: 'PERTANIAN PADI NON HIBRIDA',
          deskripsi: 'Kelompok ini mencakup kegiatan pertanian padi lokal/inbrida/varietas unggul non-hibrida.',
          level: 'Kelompok (5 Digit)',
          isLeaf: true,
        ),
      ];
    }

    // Drill down Level: Category G (Perdagangan & Bengkel)
    if (parent == 'G') {
      return [
        KbliHierarchyItem(
          kode: '45',
          judul: 'Perdagangan, Reparasi Dan Perawatan Mobil Dan Sepeda Motor',
          deskripsi: 'Penjualan grosir/eceran serta servis perawatan mobil dan sepeda motor.',
          level: 'Golongan Pokok',
          isLeaf: false,
        ),
        KbliHierarchyItem(
          kode: '47',
          judul: 'Perdagangan Eceran, Bukan Mobil Dan Sepeda Motor',
          deskripsi: 'Toko kelontong, minimarket, supermarket, dan pedagang eceran pasar.',
          level: 'Golongan Pokok',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '45') {
      return [
        KbliHierarchyItem(
          kode: '454',
          judul: 'Perdagangan, Reparasi Dan Perawatan Sepeda Motor Serta Suku Cadangnya',
          deskripsi: 'Bengkel motor, toko onderdil sepeda motor, dan jasa servis terkait.',
          level: 'Golongan',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '454') {
      return [
        KbliHierarchyItem(
          kode: '4540',
          judul: 'Perdagangan, Reparasi Dan Perawatan Sepeda Motor Dan Suku Cadangnya',
          deskripsi: 'Aktivitas servis tune-up, ganti oli, tambal ban, dan penjualan onderdil motor.',
          level: 'Subgolongan',
          isLeaf: false,
        ),
      ];
    }

    if (parent == '4540') {
      return [
        KbliHierarchyItem(
          kode: '45407',
          judul: 'REPARASI DAN PERAWATAN SEPEDA MOTOR',
          deskripsi: 'Bengkel servis mesin motor, tune-up, ganti oli, dan perbaikan kelistrikan.',
          level: 'Kelompok (5 Digit)',
          isLeaf: true,
        ),
        KbliHierarchyItem(
          kode: '45408',
          judul: 'JASA TAMBAL BAN DAN PENCUCIAN SEPEDA MOTOR',
          deskripsi: 'Jasa tambal ban tubeless/ban dalam, isi nitrogen, dan cuci motor steam.',
          level: 'Kelompok (5 Digit)',
          isLeaf: true,
        ),
      ];
    }

    // Default dynamic child generator for other categories
    return [
      KbliHierarchyItem(
        kode: '${parent}1',
        judul: 'Aktivitas Utama Sub-Sektor $parent (Bagian 1)',
        deskripsi: 'Kegiatan operasional dan pengelolaan pada kelompok bidang usaha ini.',
        level: 'Sub-Level',
        isLeaf: parent.length >= 4,
      ),
      KbliHierarchyItem(
        kode: '${parent}2',
        judul: 'Aktivitas Penunjang Sub-Sektor $parent (Bagian 2)',
        deskripsi: 'Kegiatan pendukung dan jasa terkait pada kelompok bidang usaha ini.',
        level: 'Sub-Level',
        isLeaf: parent.length >= 4,
      ),
    ];
  }

  /// Mock Sync Info
  static Map<String, dynamic> getSyncCheck() {
    return {
      'status': 'ready',
      'version': '2026.08.26',
      'generated_at': DateTime.now().toIso8601String(),
      'kbli_count': 1569,
      'kbji_count': 2735,
      'file_size_mb': 14.24,
      'raw_file_size_mb': 22.5,
      'download_url': 'http://127.0.0.1:8000/api/v1/sync/bundle',
    };
  }
}
