import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/kbli_detail_page.dart';
import 'package:Dalem/kbli/kbli_hierarchy_page.dart';
import 'package:Dalem/kbli/kbli_sync_page.dart';
import 'package:Dalem/kbli/kbli_submission_page.dart';
import 'package:Dalem/utils/page_transitions.dart';

class KbliSuggestionItem {
  final String title;
  final IconData icon;
  final String type;

  const KbliSuggestionItem({
    required this.title,
    required this.icon,
    required this.type,
  });
}

class KbliMainPage extends StatefulWidget {
  final bool showBottomNav;

  const KbliMainPage({super.key, this.showBottomNav = false});

  @override
  State<KbliMainPage> createState() => _KbliMainPageState();
}

class _KbliMainPageState extends State<KbliMainPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final KbliRepository _repository = KbliRepository();

  Timer? _debounce;
  List<KbliItem> _searchResults = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _statusMessage;
  String _selectedFilter = 'ALL'; // 'ALL', 'KBLI', 'KBJI'
  bool _isSearchFocused = false;

  static const List<KbliSuggestionItem> _popularSuggestions = [
    KbliSuggestionItem(title: 'bengkel motor', icon: Icons.build_circle_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'tambal ban', icon: Icons.tire_repair_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'padi hibrida', icon: Icons.grass_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'warung soto', icon: Icons.restaurant_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'toko kelontong', icon: Icons.storefront_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'montir motor', icon: Icons.engineering_rounded, type: 'KBJI'),
    KbliSuggestionItem(title: 'buruh panen', icon: Icons.agriculture_rounded, type: 'KBJI'),
    KbliSuggestionItem(title: 'ojek online', icon: Icons.two_wheeler_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'penjahit', icon: Icons.content_cut_rounded, type: 'KBLI'),
    KbliSuggestionItem(title: 'budidaya lele', icon: Icons.water_drop_rounded, type: 'KBLI'),
  ];

  static final List<KbliItem> _sampleKbliItems = [
    KbliItem(
      type: 'KBLI 2025',
      kode: '01121',
      judul: 'PERTANIAN PADI HIBRIDA',
      deskripsi: 'Kelompok ini mencakup kegiatan pertanian padi hibrida, termasuk di dalamnya pengolahan lahan, penanaman benih hibrida, pemupukan, hingga pemanenan.',
      contohLapangan: [
        'Petani yang menanam benih padi hibrida di sawah irigasi',
        'Pemanenan padi hibrida menggunakan mesin combine harvester',
      ],
      score: 98,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '45407',
      judul: 'REPARASI DAN PERAWATAN SEPEDA MOTOR',
      deskripsi: 'Kelompok ini mencakup usaha reparasi dan servis berkala sepeda motor, tune-up mesin, ganti oli, servis karburator/injeksi, dan kelistrikan.',
      contohLapangan: [
        'Bengkel servis sepeda motor matic dan bebek rumahan',
        'Jasa ganti oli dan tune-up sepeda motor',
      ],
      score: 99,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '45408',
      judul: 'JASA TAMBAL BAN DAN PENCUCIAN SEPEDA MOTOR',
      deskripsi: 'Kelompok ini mencakup usaha jasa tambal ban motor (tubeless maupun ban dalam), pengisian angin nitrogen, dan steam cuci motor.',
      contohLapangan: [
        'Tukang tambal ban motor di pinggir jalan',
        'Jasa cuci motor steam salju',
      ],
      score: 98,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '56102',
      judul: 'WARUNG MAKAN / WARUNG SOTO / KEDAI MAKANAN',
      deskripsi: 'Kelompok ini mencakup usaha penyediaan makanan siap santap di tempat usaha sederhana, seperti warung soto, warteg, dan kedai nasi rames.',
      contohLapangan: [
        'Warung soto ayam dan soto kerbau khas Demak',
        'Kedai nasi rames dan lauk pauk siap saji',
      ],
      score: 96,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '47111',
      judul: 'PERDAGANGAN ECERAN BARANG KEBUTUHAN POKOK / TOKO KELONTONG',
      deskripsi: 'Kelompok ini mencakup usaha perdagangan eceran berbagai macam barang kebutuhan sehari-hari (sembako, beras, minyak, gula, sabun).',
      contohLapangan: [
        'Warung kelontong sembako di teras rumah',
        'Toko kelontong tradisional di desa',
      ],
      score: 95,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBLI 2025',
      kode: '03211',
      judul: 'BUDIDAYA IKAN AIR TAWAR DI KOLAM (LELE, NILA, GURAME)',
      deskripsi: 'Kelompok ini mencakup usaha pembenihan, pembesaran, dan pemeliharaan ikan air tawar di kolam terpal/tanah/bioflok.',
      contohLapangan: [
        'Peternak budidaya ikan lele bioflok di pekarangan',
        'Pembesaran ikan nila dan gurame di kolam air tawar',
      ],
      score: 94,
      matchType: 'featured',
    ),
  ];

  static final List<KbliItem> _sampleKbjiItems = [
    KbliItem(
      type: 'KBJI 2014',
      kode: '6111',
      judul: 'PETANI TANAMAN PANGAN DAN SAYURAN',
      deskripsi: 'Profesi yang merencanakan, mengelola, dan melakukan kegiatan pertanian tanaman pangan (padi, jagung, palawija) dan sayuran.',
      contohLapangan: [
        'Petani pemilik dan penggarap sawah padi di desa',
        'Petani kebun cabai dan bawang merah',
      ],
      score: 97,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '7231',
      judul: 'MEKANIK DAN MONTIR KENDARAAN BERMOTOR',
      deskripsi: 'Tenaga kerja terampil yang memasang, merawat, dan memperbaiki mesin serta bagian mekanik pada sepeda motor dan mobil.',
      contohLapangan: [
        'Montir bengkel sepeda motor yang melakukan overhaul mesin',
        'Mekanik servis tune-up dan kelistrikan motor',
      ],
      score: 96,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '9211',
      judul: 'BURUH TANI DAN PEKERJA KASAR PERTANIAN',
      deskripsi: 'Pekerja yang melakukan tugas-tugas operasional sederhana dalam pertanian, seperti mencangkul, menanam bibit, menyiangi, dan memotong hasil panen.',
      contohLapangan: [
        'Buruh derep (buruh potong padi saat panen raya)',
        'Buruh tanam bibit padi (tandur)',
      ],
      score: 96,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '5221',
      judul: 'PEDAGANG DAN PELAYAN TOKO KELONTONG',
      deskripsi: 'Tenaga kerja yang melayani pembeli, mencatat stok barang, dan mengelola transaksi di toko eceran kecil.',
      contohLapangan: [
        'Penjaga warung kelontong sembako',
        'Kasir dan pelayan toko kelontong',
      ],
      score: 94,
      matchType: 'featured',
    ),
    KbliItem(
      type: 'KBJI 2014',
      kode: '8322',
      judul: 'PENGEMUDI SEPEDA MOTOR DAN OJEK',
      deskripsi: 'Pengemudi yang mengendarai sepeda motor roda dua untuk mengangkut penumpang atau mengantarkan pesanan makanan dan barang.',
      contohLapangan: [
        'Mitra driver ojek online penumpang dan makanan',
        'Kurir motor pengantar paket belanja online',
      ],
      score: 95,
      matchType: 'featured',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final online = await _repository.isNetworkConnected();
    if (mounted) {
      setState(() => _isOnline = online);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _statusMessage = null;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final result = await _repository.search(
      query,
      type: _selectedFilter == 'ALL' ? null : _selectedFilter,
      limit: 25,
    );

    if (mounted) {
      setState(() {
        _searchResults = result.items;
        _isOnline = result.isOnline;
        _statusMessage = result.message;
        _isLoading = false;
      });
    }
  }

  void _applySuggestion(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _performSearch(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Hero Banner with Curved Bottom
          SliverToBoxAdapter(
            child: _buildHeroHeader(),
          ),

          // Search & Filter Card with comfortable top spacing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  // Filter Chips (Retained Horizontal Scrollable Chips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'Semua Master'),
                        const SizedBox(width: 8),
                        _buildFilterChip('KBLI', 'KBLI 2025 (Usaha)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('KBJI', 'KBJI 2014 (Jabatan)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionHub(),
                  const SizedBox(height: 16),
                  if (_statusMessage != null) _buildStatusAlert(),
                ],
              ),
            ),
          ),

          // Search Results / Master Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: _buildContentSliver(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            AppColors.primaryNavy,
            const Color(0xFF1E3A8A),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF60A5FA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PINTAR KBLI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SE2026',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Klasifikasi Cerdas • BPS Kabupaten Demak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Network Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? const Color(0xFF059669).withValues(alpha: 0.2)
                      : const Color(0xFFD97706).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOnline
                        ? const Color(0xFF34D399).withValues(alpha: 0.5)
                        : const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFBBF24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isOnline
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFBBF24))
                                .withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline ? 'Online AI' : 'Offline FTS5',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Temukan kode KBLI 2025 & KBJI 2014 dengan pencarian semantik cerdas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? const Color(0xFF2563EB)
              : const Color(0xFFE2E8F0),
          width: _isSearchFocused ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSearchFocused
                ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: _isSearchFocused ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: _selectedFilter == 'KBLI'
              ? 'Cari bidang usaha (misal: bengkel, padi, soto)...'
              : (_selectedFilter == 'KBJI'
                  ? 'Cari profesi / jabatan (misal: montir, buruh tani)...'
                  : 'Cari usaha, bengkel, soto, padi, jabatan...'),
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              color: _isSearchFocused
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE2E8F0),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () {
        if (_selectedFilter != key) {
          setState(() => _selectedFilter = key);
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : const Color(0xFFCBD5E1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionHub() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Hierarki KBLI',
            subtitle: 'Kategori A - U',
            icon: Icons.account_tree_rounded,
            badge: '21 Sektor',
            accentColor: const Color(0xFF1D4ED8),
            bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(child: const KbliHierarchyPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            title: 'Sinkronisasi',
            subtitle: 'Database Offline',
            icon: Icons.cloud_sync_rounded,
            badge: 'FTS5',
            accentColor: const Color(0xFF0D9488),
            bgGradient: const [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(child: const KbliSyncPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            title: 'Catatan Lapangan',
            subtitle: 'Crowdsourcing',
            icon: Icons.edit_note_rounded,
            badge: 'Baru',
            accentColor: const Color(0xFFEA580C),
            bgGradient: const [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(child: const KbliSubmissionPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color accentColor,
    required List<Color> bgGradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: bgGradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF1E40AF),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSliver() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildShimmerCard(),
          childCount: 4,
        ),
      );
    }

    // Active Search Results
    if (_searchController.text.isNotEmpty) {
      if (_searchResults.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyState(),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Text(
                      'Ditemukan ${_searchResults.length} Hasil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _isOnline
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isOnline ? Icons.bolt_rounded : Icons.storage_rounded,
                            size: 12,
                            color: _isOnline
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isOnline ? 'Live AI Search' : 'Offline FTS5',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _isOnline
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildResultCard(_searchResults[index - 1]);
          },
          childCount: _searchResults.length + 1,
        ),
      );
    }

    // Default / Filter-specific Content
    return SliverToBoxAdapter(
      child: _buildMasterOverviewSection(),
    );
  }

  Widget _buildMasterOverviewSection() {
    if (_selectedFilter == 'KBLI') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KBLI Explanatory Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Master KBLI 2025 (Klasifikasi Usaha)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'KBLI (Klasifikasi Baku Lapangan Usaha Indonesia) mencakup 1.569 kode kelompok usaha 5-digit untuk mengidentifikasi aktivitas ekonomi unit usaha pada Sensus Ekonomi 2026.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF1E40AF),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Suggested chips for KBLI
          _buildSuggestionChips(filterType: 'KBLI'),
          const SizedBox(height: 16),

          // Featured KBLI List Header
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                'Contoh Bidang Usaha KBLI Populer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of sample KBLI Cards
          ..._sampleKbliItems.map((item) => _buildResultCard(item)),
        ],
      );
    }

    if (_selectedFilter == 'KBJI') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KBJI Explanatory Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.badge_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Master KBJI 2014 (Klasifikasi Jabatan)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'KBJI (Klasifikasi Baku Jabatan Indonesia) mencakup 2.735 kode standar untuk mengklasifikasikan tugas, profesi, pekerjaan, dan jabatan tenaga kerja di Indonesia.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF047857),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Suggested chips for KBJI
          _buildSuggestionChips(filterType: 'KBJI'),
          const SizedBox(height: 16),

          // Featured KBJI List Header
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Text(
                'Contoh Jabatan / Pekerjaan KBJI Populer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of sample KBJI Cards
          ..._sampleKbjiItems.map((item) => _buildResultCard(item)),
        ],
      );
    }

    // Default: 'ALL'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSuggestionChips(),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.explore_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 6),
            Text(
              'Klasifikasi Terpopuler Sensus Lapangan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResultCard(_sampleKbliItems[0]),
        _buildResultCard(_sampleKbliItems[1]),
        _buildResultCard(_sampleKbjiItems[0]),
        _buildResultCard(_sampleKbjiItems[1]),
      ],
    );
  }

  Widget _buildSuggestionChips({String? filterType}) {
    final list = filterType == null
        ? _popularSuggestions
        : _popularSuggestions.where((s) => s.type == filterType).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 6),
            Text(
              filterType == null
                  ? 'Paling Sering Dicari Petugas Sensus'
                  : 'Kata Kunci Populer $filterType',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((s) {
            final isKbli = s.type == 'KBLI';

            return InkWell(
              onTap: () => _applySuggestion(s.title),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 15, color: isKbli ? const Color(0xFF2563EB) : const Color(0xFF059669)),
                    const SizedBox(width: 6),
                    Text(
                      s.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard(KbliItem item) {
    final isKbli = item.type.toUpperCase().contains('KBLI');
    final isKbji = item.type.toUpperCase().contains('KBJI');
    final badgeColor = isKbli
        ? const Color(0xFF1D4ED8)
        : (isKbji ? const Color(0xFF047857) : const Color(0xFF7C3AED));
    final badgeBg = isKbli
        ? const Color(0xFFEFF6FF)
        : (isKbji ? const Color(0xFFECFDF5) : const Color(0xFFF5F3FF));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(child: KbliDetailPage(item: item)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.type,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.kode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 11,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${item.score}% Match',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: 'Salin Kode',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.kode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF0F172A),
                            content: Text('Kode ${item.kode} berhasil disalin!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  item.judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),

                // Description
                if (item.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                ],

                // Contoh Lapangan preview pill
                if (item.contohLapangan.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.contohLapangan.first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Lihat Detail & Contoh Lapangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.primaryNavy,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Klasifikasi Tidak Ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Coba gunakan sinonim kegiatan usaha nyata, atau telusuri struktur melalui Eksplorasi Hierarki KBLI.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                SmoothPageRoute(child: const KbliHierarchyPage()),
              );
            },
            icon: const Icon(Icons.account_tree_rounded, size: 16),
            label: const Text('Buka Hierarki KBLI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 220,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
