import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/kbli_detail_page.dart';
import 'package:Dalem/utils/page_transitions.dart';

class HierarchyBreadcrumb {
  final String label;
  final String? parentCode;
  final bool isLeafView;

  HierarchyBreadcrumb({
    required this.label,
    this.parentCode,
    this.isLeafView = false,
  });
}

class KbliHierarchyPage extends StatefulWidget {
  final String? initialParent;

  const KbliHierarchyPage({super.key, this.initialParent});

  @override
  State<KbliHierarchyPage> createState() => _KbliHierarchyPageState();
}

class _KbliHierarchyPageState extends State<KbliHierarchyPage> {
  final KbliRepository _repository = KbliRepository();
  final List<HierarchyBreadcrumb> _breadcrumbs = [
    HierarchyBreadcrumb(label: 'Kategori (A - U)', parentCode: null),
  ];

  // Hierarchy Navigation State
  String? _currentParent;
  List<KbliHierarchyItem> _items = [];
  bool _isLoading = true;
  String _filterQuery = '';
  final TextEditingController _filterController = TextEditingController();

  // Fast-Track 2-Step Leaf Explorer State
  bool _isFastTrackMode = true;
  bool _isViewingLeaves = false;
  String? _selectedParentCode;
  String _selectedParentTitle = '';
  List<KbliItem> _leafItems = [];
  List<KbliHierarchyItem> _subgroups = [];
  String? _selectedSubgroupCode;
  bool _isLeafLoading = false;
  String _leafFilterQuery = '';
  final TextEditingController _leafFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentParent = widget.initialParent;
    _fetchHierarchy();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _leafFilterController.dispose();
    super.dispose();
  }

  /// Fetch standard tree hierarchy items for the current parent
  Future<void> _fetchHierarchy() async {
    setState(() => _isLoading = true);
    try {
      final results = await _repository.getHierarchy(parent: _currentParent);
      if (mounted) {
        setState(() {
          _items = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Fast-Track 2-Step: Open 5-digit leaf catalog directly under Golongan Pokok
  Future<void> _openFastTrackLeaves(KbliHierarchyItem item) async {
    setState(() {
      _isViewingLeaves = true;
      _selectedParentCode = item.kode;
      _selectedParentTitle = item.judul;
      _selectedSubgroupCode = null;
      _leafFilterController.clear();
      _leafFilterQuery = '';
      _isLeafLoading = true;
      _breadcrumbs.add(HierarchyBreadcrumb(
        label: '${item.kode} - Katalog KBLI',
        parentCode: item.kode,
        isLeafView: true,
      ));
    });

    try {
      final results = await Future.wait([
        _repository.getKbliLeavesByParent(item.kode),
        _repository.getHierarchy(parent: item.kode),
      ]);

      if (mounted) {
        setState(() {
          _leafItems = results[0] as List<KbliItem>;
          _subgroups = results[1] as List<KbliHierarchyItem>;
          _isLeafLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _leafItems = [];
          _subgroups = [];
          _isLeafLoading = false;
        });
      }
    }
  }

  /// Exit the leaf catalog view and return to the parent level
  void _exitLeafView() {
    setState(() {
      _isViewingLeaves = false;
      _selectedParentCode = null;
      _selectedParentTitle = '';
      _selectedSubgroupCode = null;
      _leafFilterController.clear();
      _leafFilterQuery = '';
      if (_breadcrumbs.isNotEmpty && _breadcrumbs.last.isLeafView) {
        _breadcrumbs.removeLast();
      }
    });
  }

  void _onItemTap(KbliHierarchyItem item) {
    if (item.isLeaf || item.kode.length >= 5) {
      // Leaf node: open detail view
      _openDetailPage(
        KbliItem(
          type: 'KBLI 2025',
          kode: item.kode,
          judul: item.judul,
          deskripsi: item.deskripsi,
          contohLapangan: [],
          score: 100,
          matchType: 'hierarchy_drilldown',
        ),
      );
    } else if (_isFastTrackMode && _currentParent != null && _currentParent!.length == 1) {
      // In Golongan Pokok level (parent is Category letter like 'A', item is 2 digits like '01'):
      // Fast-Track triggers! Cut out levels 3 and 4!
      _openFastTrackLeaves(item);
    } else {
      // Standard drill down
      _drillDown(item);
    }
  }

  void _drillDown(KbliHierarchyItem item) {
    setState(() {
      _currentParent = item.kode;
      _breadcrumbs.add(HierarchyBreadcrumb(
        label: '${item.kode} - ${item.judul}',
        parentCode: item.kode,
      ));
      _filterController.clear();
      _filterQuery = '';
    });
    _fetchHierarchy();
  }

  void _openDetailPage(KbliItem item) {
    Navigator.push(
      context,
      SmoothPageRoute(
        child: KbliDetailPage(item: item),
      ),
    );
  }

  void _navigateToBreadcrumb(int index) {
    if (index == _breadcrumbs.length - 1) return;

    setState(() {
      final selected = _breadcrumbs[index];
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);

      if (selected.isLeafView) {
        _isViewingLeaves = true;
      } else {
        _isViewingLeaves = false;
        _currentParent = selected.parentCode;
        _filterController.clear();
        _filterQuery = '';
      }
    });

    if (!_isViewingLeaves) {
      _fetchHierarchy();
    }
  }

  void _handleBack() {
    if (_isViewingLeaves) {
      _exitLeafView();
    } else if (_breadcrumbs.length > 1) {
      _navigateToBreadcrumb(_breadcrumbs.length - 2);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showModeSelectorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppColors.kbliPrimary, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Mode Eksplorasi Hierarki',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih cara penelusuran klasifikasi KBLI yang paling nyaman untuk survei Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Option 1: Fast-Track
                    InkWell(
                      onTap: () {
                        setState(() => _isFastTrackMode = true);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isFastTrackMode
                              ? AppColors.kbliSurface
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isFastTrackMode
                                ? AppColors.kbliPrimary
                                : AppColors.borderDefault,
                            width: _isFastTrackMode ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isFastTrackMode
                                    ? AppColors.kbliPrimary
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                color: _isFastTrackMode ? Colors.white : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Mode Cepat (2 Langkah)',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Disarankan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pangkas jenjang! Pilih Kategori ➔ Golongan Pokok ➔ Langsung lihat seluruh KBLI 5-digit dengan filter subgolongan.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _isFastTrackMode
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: _isFastTrackMode
                                  ? AppColors.kbliPrimary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 2: Standard 5-Level Tree
                    InkWell(
                      onTap: () {
                        setState(() => _isFastTrackMode = false);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: !_isFastTrackMode
                              ? AppColors.kbliSurface
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !_isFastTrackMode
                                ? AppColors.kbliPrimary
                                : AppColors.borderDefault,
                            width: !_isFastTrackMode ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: !_isFastTrackMode
                                    ? AppColors.kbliPrimary
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_tree_rounded,
                                color: !_isFastTrackMode ? Colors.white : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mode Struktur Rinci (5 Level)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Telusuri hierarki resmi BPS tingkat demi tingkat: Kategori ➔ Gol Pokok ➔ Golongan ➔ Subgolongan ➔ Kelompok.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              !_isFastTrackMode
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: !_isFastTrackMode
                                  ? AppColors.kbliPrimary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isViewingLeaves && _breadcrumbs.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundScaffold,
        appBar: AppBar2(
          title: 'Eksplorasi Hierarki KBLI',
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: _showModeSelectorSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFastTrackMode ? Icons.bolt_rounded : Icons.account_tree_rounded,
                        color: _isFastTrackMode ? const Color(0xFFFDE047) : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isFastTrackMode ? 'Mode Cepat' : 'Mode Rinci',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          onBackPressed: _handleBack,
        ),
        body: Column(
          children: [
            // Breadcrumbs Bar
            _buildBreadcrumbsBar(),

            // Body Switcher: Leaf View vs Hierarchy Level View
            Expanded(
              child: _isViewingLeaves
                  ? _buildLeafCatalogView()
                  : _buildHierarchyLevelView(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BREADCRUMBS BAR
  // ==========================================
  Widget _buildBreadcrumbsBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.borderDefault)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _breadcrumbs.asMap().entries.map((entry) {
            final idx = entry.key;
            final b = entry.value;
            final isLast = idx == _breadcrumbs.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (idx > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                  ),
                InkWell(
                  onTap: () => _navigateToBreadcrumb(idx),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.kbliSurface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.label.length > 25 ? '${b.label.substring(0, 23)}...' : b.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                        color: isLast
                            ? AppColors.kbliPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: STANDARD / DIVISION HIERARCHY LEVEL
  // ==========================================
  Widget _buildHierarchyLevelView() {
    final filteredItems = _filterQuery.isEmpty
        ? _items
        : _items.where((i) {
            final query = _filterQuery.toLowerCase();
            return i.kode.toLowerCase().contains(query) ||
                i.judul.toLowerCase().contains(query) ||
                i.deskripsi.toLowerCase().contains(query);
          }).toList();

    final isCategoryLevel = _currentParent == null;
    final isDivisionLevel = _currentParent != null && _currentParent!.length == 1;

    return Column(
      children: [
        // Level Hint & Filter Input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCategoryLevel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.category_rounded, size: 16, color: AppColors.kbliPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Pilih Kategori KBLI (A - U)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isDivisionLevel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.dashboard_customize_rounded, size: 16, color: AppColors.kbliPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Pilih Golongan Pokok (2 Digit)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_isFastTrackMode)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⚡ 2-Step Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              TextField(
                controller: _filterController,
                onChanged: (val) => setState(() => _filterQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: isCategoryLevel
                      ? 'Cari nama kategori (misal: Pertanian, Industri)...'
                      : 'Cari di level ini...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _filterQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _filterController.clear();
                            setState(() => _filterQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),

        // List Items
        Expanded(
          child: _isLoading
              ? _buildShimmerLoading()
              : filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isLeaf = item.isLeaf || item.kode.length >= 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderDefault),
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
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => _onItemTap(item),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Code Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isLeaf
                                                ? const Color(0xFFF0FDF4)
                                                : AppColors.kbliSurface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isLeaf
                                                  ? const Color(0xFFBBF7D0)
                                                  : AppColors.kbliBorder,
                                            ),
                                          ),
                                          child: Text(
                                            item.kode,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isLeaf
                                                  ? const Color(0xFF15803D)
                                                  : AppColors.kbliPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Title & Description
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.judul,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                  height: 1.3,
                                                ),
                                              ),
                                              if (item.deskripsi.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.deskripsi,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Trailing Icon
                                        Icon(
                                          isLeaf
                                              ? Icons.visibility_rounded
                                              : Icons.chevron_right_rounded,
                                          color: isLeaf
                                              ? const Color(0xFF16A34A)
                                              : AppColors.textMuted,
                                          size: 20,
                                        ),
                                      ],
                                    ),

                                    // Special Action Buttons for Division Level (2-Digit)
                                    if (isDivisionLevel) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, color: AppColors.borderDefault),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => _openFastTrackLeaves(item),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.kbliPrimary.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: AppColors.kbliPrimary.withValues(alpha: 0.2)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.bolt_rounded, size: 15, color: AppColors.kbliPrimary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Buka Katalog KBLI (5 Digit)',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.kbliPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_isFastTrackMode)
                                            InkWell(
                                              onTap: () => _drillDown(item),
                                              borderRadius: BorderRadius.circular(6),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Pohon Rinci',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                    const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textMuted),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: FAST-TRACK 5-DIGIT LEAF CATALOG
  // ==========================================
  Widget _buildLeafCatalogView() {
    final visibleLeaves = _leafItems.where((leaf) {
      if (_selectedSubgroupCode != null && !leaf.kode.startsWith(_selectedSubgroupCode!)) {
        return false;
      }
      if (_leafFilterQuery.isNotEmpty) {
        final q = _leafFilterQuery.toLowerCase();
        return leaf.kode.toLowerCase().contains(q) ||
            leaf.judul.toLowerCase().contains(q) ||
            leaf.deskripsi.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Parent Header Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.kbliBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.kbliPrimary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.kbliSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.kbliBorder),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.kbliPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.kbliPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Golongan Pokok $_selectedParentCode',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '2-Step Fast Track',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedParentTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Menampilkan ${visibleLeaves.length} dari ${_leafItems.length} kode KBLI 5-digit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Subgroup (3-Digit) Filter Chips
        if (_subgroups.isNotEmpty)
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _subgroups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedSubgroupCode == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text('Semua (${_leafItems.length})'),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.kbliPrimary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.kbliPrimary : AppColors.borderDefault,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() => _selectedSubgroupCode = null);
                      },
                    ),
                  );
                }

                final subgroup = _subgroups[index - 1];
                final isSelected = _selectedSubgroupCode == subgroup.kode;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      '${subgroup.kode} - ${subgroup.judul.length > 20 ? '${subgroup.judul.substring(0, 18)}...' : subgroup.judul}',
                    ),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.kbliPrimary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.kbliPrimary : AppColors.borderDefault,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedSubgroupCode = isSelected ? null : subgroup.kode;
                      });
                    },
                  ),
                );
              },
            ),
          ),

        // Search Bar within Leaves
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _leafFilterController,
            onChanged: (val) => setState(() => _leafFilterQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Cari komoditas/kegiatan di $_selectedParentCode (padi, sapi, dsb)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
              suffixIcon: _leafFilterQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        _leafFilterController.clear();
                        setState(() => _leafFilterQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),

        // List of 5-Digit Leaves
        Expanded(
          child: _isLeafLoading
              ? _buildShimmerLoading()
              : visibleLeaves.isEmpty
                  ? _buildEmptyLeafState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: visibleLeaves.length,
                      itemBuilder: (context, index) {
                        final leaf = visibleLeaves[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderDefault),
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
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => _openDetailPage(leaf),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Official 5-Digit Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFBBF7D0)),
                                          ),
                                          child: Text(
                                            leaf.kode,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF15803D),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Title
                                        Expanded(
                                          child: Text(
                                            leaf.judul,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Detail Pill Button
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFBBF7D0)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Detail',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF15803D),
                                                ),
                                              ),
                                              const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF15803D)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Description
                                    if (leaf.deskripsi.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        leaf.deskripsi,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],

                                    // Field Examples Pill
                                    if (leaf.contohLapangan.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFD97706)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                leaf.contohLapangan.take(2).join(' • '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // LOADING SHIMMER & EMPTY STATES
  // ==========================================
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'Tidak Ada Klasifikasi Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _filterQuery.isNotEmpty
                  ? 'Tidak ada item yang cocok dengan kata kunci "$_filterQuery".'
                  : 'Gagal memuat struktur hierarki. Periksa koneksi API Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateDark,
                foregroundColor: Colors.white,
              ),
              onPressed: _fetchHierarchy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLeafState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'KBLI Tidak Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _leafFilterQuery.isNotEmpty
                  ? 'Tidak ada kode KBLI 5-digit yang cocok dengan "$_leafFilterQuery" di golongan ini.'
                  : 'Belum ada data KBLI 5-digit untuk kelompok yang dipilih.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            if (_leafFilterQuery.isNotEmpty || _selectedSubgroupCode != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Reset Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kbliPrimary,
                  side: const BorderSide(color: AppColors.kbliPrimary),
                ),
                onPressed: () {
                  setState(() {
                    _selectedSubgroupCode = null;
                    _leafFilterController.clear();
                    _leafFilterQuery = '';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
