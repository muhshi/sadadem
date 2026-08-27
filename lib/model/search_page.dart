import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/publikasi/detail_publikasi.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/components/state_widgets.dart';
import 'package:Dalem/main_screen.dart';

class SearchPage extends StatefulWidget {
  final bool autofocus;
  final bool showBottomNav;
  final String? initialQuery;

  const SearchPage({
    super.key,
    required this.autofocus,
    this.showBottomNav = true,
    this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recommendedData = [];
  bool _isLoading = false;
  bool _isLoadingRecommendations = true;
  bool _isSearchError = false;
  Timer? _debounce;
  List<String> _searchHistory = [];
  String _selectedFilter = 'Semua'; // 'Semua', 'Tabel', 'Publikasi'

  final List<Map<String, dynamic>> _popularTopics = [
    {'title': 'Inflasi', 'icon': Icons.trending_up_rounded},
    {'title': 'Kemiskinan', 'icon': Icons.family_restroom_rounded},
    {'title': 'Jumlah Penduduk', 'icon': Icons.people_rounded},
    {'title': 'PDRB', 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Ketenagakerjaan', 'icon': Icons.work_rounded},
    {'title': 'Pertanian', 'icon': Icons.agriculture_rounded},
    {'title': 'Pendidikan', 'icon': Icons.school_rounded},
    {'title': 'Kesehatan', 'icon': Icons.local_hospital_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchRecommendations();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      final query = widget.initialQuery!.trim();
      _searchController.text = query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(query, saveToHistory: true);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    List<Map<String, dynamic>> recommendations = [];

    try {
      final pubUrl =
          'https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/3321/page/1/perpage/3/key/b73ea5437eb23fb8309858b840029da2/';
      final tableUrl =
          'https://webapi.bps.go.id/v1/api/list/model/tablestatistic/lang/ind/domain/3321/page/1/perpage/3/key/b73ea5437eb23fb8309858b840029da2/';

      final responses = await Future.wait([
        http.get(Uri.parse(pubUrl)),
        http.get(Uri.parse(tableUrl)),
      ]);

      // Parse Publications
      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        if (data['data'] != null && data['data'].length > 1) {
          for (var item in data['data'][1]) {
            item['type'] = 'publication';
            recommendations.add(item);
          }
        }
      }

      // Parse Tables
      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body);
        if (data['data'] != null && data['data'].length > 1) {
          for (var item in data['data'][1]) {
            item['type'] = 'table';
            recommendations.add(item);
          }
        }
      }

      if (mounted) {
        setState(() {
          _recommendedData = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim(), saveToHistory: false);
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _isSearchError = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query, {bool saveToHistory = false}) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isSearchError = false;
    });

    final urls = [
      {
        'url': ApiConfig.listUrl(model: 'tablestatistic', keyword: trimmedQuery),
        'type': 'table'
      },
      {
        'url': ApiConfig.listUrl(model: 'publication', keyword: trimmedQuery),
        'type': 'publication'
      },
    ];

    List<Map<String, dynamic>> results = [];

    try {
      await Future.wait(urls.map((urlData) async {
        final response = await http.get(Uri.parse(urlData['url'].toString()));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['data'] != null && data['data'].length > 1) {
            for (var item in data['data'][1]) {
              if (item['title'] != null &&
                  item['title']
                      .toString()
                      .toLowerCase()
                      .contains(trimmedQuery.toLowerCase())) {
                item['type'] = urlData['type'];
                results.add(item);
              }
            }
          }
        }
      }));

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _isSearchError = false;
        });
      }

      if (saveToHistory) {
        _saveSearchQuery(trimmedQuery);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSearchError = true;
        });
      }
      debugPrint('Error fetching search results: $e');
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty || cleanQuery.length < 2) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.removeWhere(
          (item) => item.toLowerCase() == cleanQuery.toLowerCase());
      _searchHistory.insert(0, cleanQuery);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _deleteSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  void _onItemTapped(Map<String, dynamic> item) {
    if (_searchController.text.trim().isNotEmpty) {
      _saveSearchQuery(_searchController.text.trim());
    }
    bool isTable = item['type'] == 'table';
    try {
      if (isTable) {
        var decodedId = utf8.decode(base64.decode(item['id'].toString()));
        var arrayId = decodedId.split('#');
        var id = arrayId[0];
        var tableType = arrayId.length > 1 ? arrayId[1] : '1';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataTableScreen(
              id: id,
              title: item['title'] ?? '',
              tableType: tableType,
            ),
          ),
        );
      } else if (item['type'] == 'publication') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPublikasi(publication: item),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error decoding ID: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredResults() {
    if (_selectedFilter == 'Tabel') {
      return _searchResults.where((item) => item['type'] == 'table').toList();
    } else if (_selectedFilter == 'Publikasi') {
      return _searchResults
          .where((item) => item['type'] == 'publication')
          .toList();
    }
    return _searchResults;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(initialIndex: 0),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundScaffold,
        appBar: const AppBar2(
          title: 'Pencarian Data',
        ),
        body: Column(
          children: [
            // Premium Modern Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _searchController.text.isNotEmpty
                        ? AppColors.primaryNavy
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        autofocus: widget.autofocus,
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                          _onSearchChanged();
                        },
                        onSubmitted: (value) =>
                            _performSearch(value.trim(), saveToHistory: true),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ketik kata kunci pencarian data...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryNavy, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _performSearch(
                                _searchController.text.trim(),
                                saveToHistory: true),
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                'Cari',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),

            // Filter Chips (When search results exist)
            if (_searchResults.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', _searchResults.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Tabel',
                        _searchResults
                            .where((i) => i['type'] == 'table')
                            .length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Publikasi',
                        _searchResults
                            .where((i) => i['type'] == 'publication')
                            .length,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // Body Content
            Expanded(
              child: _isLoading
                  ? _buildShimmerLoading()
                  : _searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _searchController.text.isNotEmpty
                          ? _buildEmptyResults()
                          : _buildInitialSuggestions(),
            ),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const BottomNav(currentIndex: 1)
            : null,
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppColors.primaryNavy,
      backgroundColor: AppColors.surfaceCard,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryNavy : AppColors.borderDefault,
        ),
      ),
    );
  }

  Widget _buildInitialSuggestions() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 🔥 Topik Populer
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFF97316), size: 18),
              const SizedBox(width: 6),
              Text(
                'Topik Populer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTopics.map((topic) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _searchController.text = topic['title'];
                    _performSearch(topic['title'], saveToHistory: true);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderDefault),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(topic['icon'] as IconData,
                            size: 14, color: AppColors.primaryNavy),
                        const SizedBox(width: 6),
                        Text(
                          topic['title'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // 2. 🕒 Riwayat Pencarian (Jika Ada)
          if (_searchHistory.isNotEmpty) ...[
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: AppColors.primaryNavy, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Pencarian Terakhir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('searchHistory');
                    setState(() {
                      _searchHistory = [];
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                  ),
                  child: Text(
                    'Hapus Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.accentRose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((query) {
                return InputChip(
                  backgroundColor: AppColors.surfaceCard,
                  side: const BorderSide(color: AppColors.borderDefault),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  avatar: const Icon(
                    Icons.history_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  label: Text(
                    query,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    _searchController.text = query;
                    _performSearch(query, saveToHistory: true);
                  },
                  onDeleted: () => _deleteSearchQuery(query),
                );
              }).toList(),
            ),
          ],

          // 3. 💡 Rekomendasi Data Terbaru
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Color(0xFFEAB308), size: 18),
              const SizedBox(width: 6),
              Text(
                'Rekomendasi Data Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_isLoadingRecommendations)
            _buildShimmerLoading(itemCount: 4)
          else if (_recommendedData.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendedData.length,
              itemBuilder: (context, index) {
                final item = _recommendedData[index];
                return _buildResultCard(item);
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Center(
                child: Text(
                  'Gunakan kata kunci untuk menemukan data statistik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final filtered = _getFilteredResults();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data yang cocok dengan filter "$_selectedFilter"',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        var item = filtered[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    bool isTable = item['type'] == 'table';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _onItemTapped(item),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isTable
                            ? AppColors.primaryNavy
                            : AppColors.primaryLight)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isTable
                        ? Icons.table_chart_rounded
                        : Icons.menu_book_rounded,
                    color: isTable
                        ? AppColors.primaryNavy
                        : AppColors.primaryLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isTable
                                  ? AppColors.primaryNavy
                                  : AppColors.primaryLight)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isTable ? 'Tabel Statistik' : 'Publikasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isTable
                                ? AppColors.primaryNavy
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] ?? 'No Title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    if (_isSearchError) {
      return ErrorStateWidget(
        title: 'Gagal Melakukan Pencarian',
        message: 'Tidak dapat terhubung ke server saat melakukan pencarian.',
        onRetry: () {
          _performSearch(_searchController.text.trim());
        },
      );
    }

    return const EmptyStateWidget(
      title: 'Data Tidak Ditemukan',
      message: 'Coba gunakan kata kunci pencarian yang berbeda.',
      icon: Icons.search_off_rounded,
    );
  }

  Widget _buildShimmerLoading({int itemCount = 5}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );
      },
    );
  }
}
