import 'dart:async';
import 'package:flutter/material.dart';
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

class KbliMainPage extends StatefulWidget {
  final bool showBottomNav;

  const KbliMainPage({super.key, this.showBottomNav = false});

  @override
  State<KbliMainPage> createState() => _KbliMainPageState();
}

class _KbliMainPageState extends State<KbliMainPage> {
  final TextEditingController _searchController = TextEditingController();
  final KbliRepository _repository = KbliRepository();

  Timer? _debounce;
  List<KbliItem> _searchResults = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _statusMessage;
  String _selectedFilter = 'ALL'; // 'ALL', 'KBLI', 'KBJI'

  final List<String> _popularSuggestions = [
    'padi',
    'bengkel motor',
    'warung soto',
    'petani jagung',
    'toko kelontong',
    'buruh panen',
    'penjahit pakaian',
    'ojek online',
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
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

    _debounce = Timer(const Duration(milliseconds: 320), () {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header with BPS Branding
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.category_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PINTAR KBLI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Sensus Ekonomi 2026 • BPS Kab. Demak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Connectivity Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? const Color(0xFF10B981).withValues(alpha: 0.25)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isOnline
                            ? const Color(0xFF10B981).withValues(alpha: 0.6)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isOnline
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryNavy,
                      AppColors.primaryDark,
                      const Color(0xFF0F172A),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan usaha, jabatan, atau kata kunci...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryNavy),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
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

                  // Quick Action Hub Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          title: 'Hierarki KBLI',
                          subtitle: 'Kategori A - U',
                          icon: Icons.account_tree_rounded,
                          color1: const Color(0xFF1E3A8A),
                          color2: const Color(0xFF3B82F6),
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
                        child: _buildQuickActionCard(
                          title: 'Sinkronisasi',
                          subtitle: 'Database Offline',
                          icon: Icons.cloud_sync_rounded,
                          color1: const Color(0xFF0F766E),
                          color2: const Color(0xFF14B8A6),
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
                        child: _buildQuickActionCard(
                          title: 'Catatan',
                          subtitle: 'Crowdsourcing',
                          icon: Icons.rate_review_rounded,
                          color1: const Color(0xFF7C2D12),
                          color2: const Color(0xFFF97316),
                          onTap: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(child: const KbliSubmissionPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status Message Banner (if any)
                  if (_statusMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Results Section Header
                  if (_searchController.text.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Hasil Pencarian (${_searchResults.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isOnline ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isOnline ? 'Sumber: AI REST API' : 'Sumber: SQLite FTS5',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _isOnline ? const Color(0xFF1D4ED8) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Dynamic Content: Loading / List / Empty Suggestions
                  if (_isLoading)
                    _buildShimmerList()
                  else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                    _buildEmptyResults()
                  else if (_searchController.text.isEmpty)
                    _buildPopularSuggestions()
                  else
                    ..._searchResults.map((item) => _buildResultCard(item)),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(KbliItem item) {
    final isKbli = item.type.toUpperCase().contains('KBLI');
    final badgeBg = isKbli ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5);
    final badgeColor = isKbli ? const Color(0xFF1D4ED8) : const Color(0xFF047857);

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.kode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          '${item.score}% Match',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),
                if (item.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                      height: 1.45,
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
                    Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryNavy),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFFD97706)),
            const SizedBox(width: 6),
            Text(
              'Rekomendasi Pencarian Cerdas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSuggestions.map((suggestion) {
            return InkWell(
              onTap: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 5),
                    Text(
                      suggestion,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
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

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'Klasifikasi Tidak Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba gunakan sinonim, aktivitas nyata, atau gunakan fitur Eksplorasi Hierarki.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }
}
