import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/arasaac_pictogram.dart';

/// Service for interacting with ARASAAC API
/// https://api.arasaac.org
class ArasaacService {
  static const String _baseUrl = 'https://api.arasaac.org/v1';
  
  /// Search for pictograms by text
  /// 
  /// Parameters:
  /// - [searchText]: Keywords for search. Use quotes for exact phrase search.
  /// - [language]: Language code (e.g., 'fi', 'en', 'es')
  /// - [bestSearch]: If true, returns only best matches
  Future<List<ArasaacPictogram>> searchPictograms({
    required String searchText,
    String language = 'en',
    bool bestSearch = true,
  }) async {
    try {
      final endpoint = bestSearch ? 'bestsearch' : 'search';
      final url = Uri.parse('$_baseUrl/pictograms/$language/$endpoint/$searchText');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((json) => ArasaacPictogram.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search pictograms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching pictograms: $e');
    }
  }

  /// Get a specific pictogram by ID
  /// 
  /// Parameters:
  /// - [id]: Pictogram ID
  /// - [language]: Language code for keywords
  Future<ArasaacPictogram?> getPictogramById({
    required int id,
    String language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/pictograms/$language/$id');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return ArasaacPictogram.fromJson(data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get pictogram: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting pictogram: $e');
    }
  }

  /// Get new pictograms from the last N days
  /// 
  /// Parameters:
  /// - [days]: Number of days (default 30)
  /// - [language]: Language code
  Future<List<ArasaacPictogram>> getNewPictograms({
    int days = 30,
    String language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/pictograms/$language/days/$days');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((json) => ArasaacPictogram.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get new pictograms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting new pictograms: $e');
    }
  }

  /// Get last N modified or published pictograms
  /// 
  /// Parameters:
  /// - [numItems]: Number of items to return
  /// - [language]: Language code
  Future<List<ArasaacPictogram>> getLastPictograms({
    int numItems = 30,
    String language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/pictograms/$language/new/$numItems');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((json) => ArasaacPictogram.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get last pictograms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting last pictograms: $e');
    }
  }

  /// Download pictogram image as bytes
  /// 
  /// Parameters:
  /// - [id]: Pictogram ID
  /// - [resolution]: Image resolution (500 or 2500)
  /// - [color]: True for color, false for black and white
  /// - [plural]: Add plural symbol
  /// - [action]: 'past' or 'future' for verb tense
  /// - [skin]: Skin color (white, black, assian, mulatto, aztec)
  /// - [hair]: Hair color (blonde, brown, darkBrown, gray, darkGray, red, black)
  /// - [backgroundColor]: Hex color for background
  Future<List<int>> downloadPictogramImage({
    required int id,
    int resolution = 500,
    bool color = true,
    bool plural = false,
    String? action,
    String? skin,
    String? hair,
    String? backgroundColor,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      queryParams['resolution'] = resolution.toString();
      queryParams['color'] = color.toString();
      
      if (plural) queryParams['plural'] = 'true';
      if (action != null) queryParams['action'] = action;
      if (skin != null) queryParams['skin'] = skin;
      if (hair != null) queryParams['hair'] = hair;
      if (backgroundColor != null) queryParams['backgroundColor'] = backgroundColor;
      
      final url = Uri.parse('$_baseUrl/pictograms/$id').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download pictogram image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading pictogram image: $e');
    }
  }
}
