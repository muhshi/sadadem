import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  static const String _bookmarkKey = 'bookmarked_publications';
  List<Map<String, dynamic>> _bookmarkedPublications = [];

  List<Map<String, dynamic>> get bookmarkedPublications =>
      List.unmodifiable(_bookmarkedPublications);

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedString = prefs.getString(_bookmarkKey);
      if (savedString != null && savedString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(savedString);
        _bookmarkedPublications =
            decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  bool isBookmarked(String pubId) {
    return _bookmarkedPublications
        .any((item) => item['pub_id'].toString() == pubId.toString());
  }

  Future<void> toggleBookmark(Map<String, dynamic> publication) async {
    final pubId = publication['pub_id'].toString();
    final index = _bookmarkedPublications
        .indexWhere((item) => item['pub_id'].toString() == pubId);

    if (index >= 0) {
      _bookmarkedPublications.removeAt(index);
    } else {
      _bookmarkedPublications.add(publication);
    }

    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_bookmarkedPublications);
      await prefs.setString(_bookmarkKey, encoded);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }
}
