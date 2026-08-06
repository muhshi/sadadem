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

class SearchPage extends StatefulWidget {
  final bool autofocus;
  final bool showBottomNav;
  const SearchPage({
    super.key,
    required this.autofocus,
    this.showBottomNav = true,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isSearchError = false;
  Timer? _debounce;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _isSearchError = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isSearchError = false;
    });

    final urls = [
      {
        'url': ApiConfig.listUrl(model: 'tablestatistic', keyword: query),
        'type': 'table'
      },
      {
        'url': ApiConfig.listUrl(model: 'publication', keyword: query),
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
                      .contains(query.toLowerCase())) {
                item['type'] = urlData['type'];
                results.add(item);
              }
            }
          }
        }
      }));

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _isSearchError = false;
      });

      _saveSearchQuery(query);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSearchError = true;
      });
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
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _deleteSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundScaffold,
        appBar: const AppBar2(
          title: 'Pencarian Data',
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Search Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: TextField(
                  autofocus: widget.autofocus,
                  controller: _searchController,
                  onChanged: (value) => _onSearchChanged(),
                  onSubmitted: (value) => _performSearch(value.trim()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ketik kata kunci pencarian...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Body Content
              Expanded(
                child: _isLoading
                    ? _buildShimmerLoading()
                    : _searchResults.isNotEmpty
                        ? _buildSearchResults()
                        : _searchController.text.isNotEmpty
                            ? _buildEmptyResults()
                            : _buildSearchHistory(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const BottomNav(currentIndex: 1)
            : null,
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var item = _searchResults[index];
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
              onTap: () {
                try {
                  if (isTable) {
                    var decodedId =
                        utf8.decode(base64.decode(item['id'].toString()));
                    var arrayId = decodedId.split('#');
                    var id = arrayId[0];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataTableScreen(
                          id: id,
                          title: item['title'],
                          tableType: 'table',
                        ),
                      ),
                    );
                  } else if (item['type'] == 'publication') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPublikasi(publication: item),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error decoding ID: $e');
                }
              },
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
                            .withOpacity(0.1),
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
                                  .withOpacity(0.12),
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
                              fontSize: 14,
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
      },
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textMuted.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Riwayat Pencarian',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketikkan kata kunci untuk mencari data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pencarian',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('searchHistory');
                setState(() {
                  _searchHistory = [];
                });
              },
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
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.history_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  title: Text(
                    query,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () => _deleteSearchQuery(query),
                  ),
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
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
