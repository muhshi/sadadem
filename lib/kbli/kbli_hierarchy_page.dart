import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/kbli_detail_page.dart';
import 'package:Dalem/utils/page_transitions.dart';

class HierarchyBreadcrumb {
  final String label;
  final String? parentCode;

  HierarchyBreadcrumb({required this.label, this.parentCode});
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

  String? _currentParent;
  List<KbliHierarchyItem> _items = [];
  bool _isLoading = true;
  String _filterQuery = '';
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentParent = widget.initialParent;
    _fetchHierarchy();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

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

  void _onItemTap(KbliHierarchyItem item) {
    if (item.isLeaf || item.kode.length >= 5) {
      // Leaf node: open detail view
      Navigator.push(
        context,
        SmoothPageRoute(
          child: KbliDetailPage(
            item: KbliItem(
              type: 'KBLI 2025',
              kode: item.kode,
              judul: item.judul,
              deskripsi: item.deskripsi,
              contohLapangan: [],
              score: 100,
              matchType: 'hierarchy_drilldown',
            ),
          ),
        ),
      );
    } else {
      // Non-leaf: drill down
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
  }

  void _navigateToBreadcrumb(int index) {
    if (index == _breadcrumbs.length - 1) return;

    setState(() {
      final selected = _breadcrumbs[index];
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
      _currentParent = selected.parentCode;
      _filterController.clear();
      _filterQuery = '';
    });
    _fetchHierarchy();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterQuery.isEmpty
        ? _items
        : _items.where((i) {
            final query = _filterQuery.toLowerCase();
            return i.kode.toLowerCase().contains(query) ||
                i.judul.toLowerCase().contains(query) ||
                i.deskripsi.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          'Eksplorasi Hierarki KBLI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (_breadcrumbs.length > 1) {
              _navigateToBreadcrumb(_breadcrumbs.length - 2);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Breadcrumbs Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
                          child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ),
                      InkWell(
                        onTap: () => _navigateToBreadcrumb(idx),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLast
                                ? const Color(0xFFEFF6FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            b.label.length > 25 ? '${b.label.substring(0, 23)}...' : b.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                              color: isLast
                                  ? AppColors.primaryNavy
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Filter Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _filterController,
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Cari di level ini...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _filterQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _filterController.clear();
                          setState(() => _filterQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
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
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isLeaf = item.isLeaf || item.kode.length >= 5;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
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
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => _onItemTap(item),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Code Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isLeaf
                                              ? const Color(0xFFF0FDF4)
                                              : const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isLeaf
                                                ? const Color(0xFFBBF7D0)
                                                : const Color(0xFFBFDBFE),
                                          ),
                                        ),
                                        child: Text(
                                          item.kode,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isLeaf
                                                ? const Color(0xFF15803D)
                                                : AppColors.primaryNavy,
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
                                                color: const Color(0xFF0F172A),
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
                                                  color: const Color(0xFF64748B),
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
                                            : const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
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
      ),
    );
  }

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
            height: 75,
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
                color: const Color(0xFF475569),
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
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              onPressed: _fetchHierarchy,
            ),
          ],
        ),
      ),
    );
  }
}
