import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API configuration loaded from `.env` file.
class ApiConfig {
  /// BPS Web API key.
  static String get apiKey => dotenv.env['BPS_API_KEY'] ?? '';

  /// BPS domain code (Kabupaten Demak = 3321).
  static String get domain => dotenv.env['BPS_DOMAIN'] ?? '3321';

  /// Base URL for BPS Web API v1.
  static const String baseUrl = 'https://webapi.bps.go.id/v1/api';

  /// Builds the full URL for a BPS API list endpoint.
  static String listUrl({
    required String model,
    String lang = 'ind',
    String? keyword,
    int? page,
    int perpage = 10,
  }) {
    var url = '$baseUrl/list/model/$model/lang/$lang/domain/$domain';
    if (keyword != null && keyword.isNotEmpty) {
      url += '/keyword/$keyword';
    }
    if (page != null) {
      url += '/page/$page/perpage/$perpage';
    }
    url += '/key/$apiKey/';
    return url;
  }

  /// Builds the full URL for a BPS API view (detail) endpoint.
  static String viewUrl({
    required String model,
    required String id,
    String lang = 'ind',
  }) {
    return '$baseUrl/view/domain/$domain/model/$model/lang/$lang/id/$id/key/$apiKey/';
  }

  /// Builds the full URL for a BPS API data endpoint.
  static String dataUrl({
    required String varId,
    String th = '024',
  }) {
    return '$baseUrl/list?domain=$domain&model=data&lang=ind&var=$varId&th=$th&key=$apiKey';
  }
}
