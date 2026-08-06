import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Dalem/config/api_config.dart';

class NewsProvider extends ChangeNotifier {
  List<dynamic> _latestNews = [];
  List<dynamic> _latestInfographic = [];
  bool _isLoadingNews = false;
  bool _isLoadingInfographic = false;

  List<dynamic> get latestNews => List.unmodifiable(_latestNews);
  List<dynamic> get latestInfographic => List.unmodifiable(_latestInfographic);
  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingInfographic => _isLoadingInfographic;

  Future<void> fetchLatestNews({bool force = false}) async {
    if (_isLoadingNews) return;
    if (!force && _latestNews.isNotEmpty) return;

    _isLoadingNews = true;
    notifyListeners();

    try {
      final url = ApiConfig.listUrl(model: 'news');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final items = jsonResponse['data'][1] as List<dynamic>;
        if (items.isNotEmpty) {
          _latestNews = [items[0]];
        }
      }
    } catch (e) {
      debugPrint('Error fetching latest news: $e');
    } finally {
      _isLoadingNews = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestInfographic({bool force = false}) async {
    if (_isLoadingInfographic) return;
    if (!force && _latestInfographic.isNotEmpty) return;

    _isLoadingInfographic = true;
    notifyListeners();

    try {
      final url = ApiConfig.listUrl(model: 'infographic');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final items = jsonResponse['data'][1] as List<dynamic>;
        if (items.isNotEmpty) {
          _latestInfographic = [items[0]];
        }
      }
    } catch (e) {
      debugPrint('Error fetching latest infographic: $e');
    } finally {
      _isLoadingInfographic = false;
      notifyListeners();
    }
  }
}
