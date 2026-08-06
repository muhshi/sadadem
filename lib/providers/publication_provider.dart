import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Dalem/config/api_config.dart';

class PublicationProvider extends ChangeNotifier {
  final List<dynamic> _publications = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasMoreData = true;
  bool _isError = false;

  List<dynamic> get publications => List.unmodifiable(_publications);
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  bool get hasMoreData => _hasMoreData;
  bool get isError => _isError;

  /// Fetches publication list with in-memory caching.
  /// If data already exists and not refreshing, does not refetch.
  Future<void> fetchPublications({bool isRefresh = false}) async {
    if (_isLoading) return;

    // If we already have cached data and it's not a refresh request, skip
    if (!isRefresh && _publications.isNotEmpty) {
      _isInitialLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    if (isRefresh || _publications.isEmpty) {
      _isInitialLoading = true;
    }
    _isError = false;
    notifyListeners();

    try {
      final pageToFetch = isRefresh ? 1 : _currentPage;
      final url = ApiConfig.listUrl(model: 'publication', page: pageToFetch);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final newItems = jsonResponse['data'][1] as List<dynamic>;

        if (isRefresh) {
          _publications.clear();
          _currentPage = 1;
        }

        _publications.addAll(newItems);
        _currentPage++;
        _hasMoreData = newItems.length == 10;
        _isError = false;
      } else {
        if (_publications.isEmpty) {
          _isError = true;
        }
      }
    } catch (e) {
      if (_publications.isEmpty) {
        _isError = true;
      }
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes dataset back to page 1.
  Future<void> refreshPublications() async {
    await fetchPublications(isRefresh: true);
  }
}
