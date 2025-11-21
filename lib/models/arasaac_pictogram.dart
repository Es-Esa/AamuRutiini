/// Model for ARASAAC pictogram data from the API
class ArasaacPictogram {
  final int id;
  final List<ArasaacKeyword> keywords;
  final bool schematic;
  final bool sex;
  final bool violence;
  final DateTime? created;
  final DateTime? lastUpdated;
  final int downloads;
  final List<String> categories;
  final List<String> tags;
  final String? desc;

  ArasaacPictogram({
    required this.id,
    required this.keywords,
    this.schematic = false,
    this.sex = false,
    this.violence = false,
    this.created,
    this.lastUpdated,
    this.downloads = 0,
    this.categories = const [],
    this.tags = const [],
    this.desc,
  });

  /// Generate URL for the pictogram image
  String getImageUrl({
    int resolution = 500,
    bool color = true,
    bool plural = false,
    String? action,
    String? skin,
    String? hair,
    String? backgroundColor,
  }) {
    final buffer = StringBuffer('https://static.arasaac.org/pictograms/$id/$id');

    // Add modifiers
    final modifiers = <String>[];
    
    if (action != null) {
      modifiers.add('action-$action');
    }
    
    if (hair != null) {
      modifiers.add('hair-$hair');
    }
    
    if (skin != null) {
      modifiers.add('skin-$skin');
    }
    
    if (plural) {
      modifiers.add('plural');
    }
    
    if (!color) {
      modifiers.add('nocolor');
    }

    if (modifiers.isNotEmpty) {
      buffer.write('_${modifiers.join('_')}');
    }

    buffer.write('_$resolution.png');

    if (backgroundColor != null && backgroundColor != 'none') {
      buffer.write('?backgroundColor=$backgroundColor');
    }

    return buffer.toString();
  }

  /// Get the primary keyword (first keyword)
  String get primaryKeyword {
    if (keywords.isEmpty) return 'ID: $id';
    return keywords.first.keyword;
  }

  factory ArasaacPictogram.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'];
    final id = idValue is int
        ? idValue
        : (idValue != null ? int.parse(idValue.toString()) : 0);
    
    return ArasaacPictogram(
      id: id,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => ArasaacKeyword.fromJson(k as Map<String, dynamic>))
              .toList() ??
          [],
      schematic: json['schematic'] as bool? ?? false,
      sex: json['sex'] as bool? ?? false,
      violence: json['violence'] as bool? ?? false,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      downloads: json['downloads'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [],
      desc: json['desc'] as String?,
    );
  }
}

/// Model for pictogram keywords
class ArasaacKeyword {
  final int idKeyword;
  final String keyword;
  final String? plural;
  final String? meaning;
  final int? type;

  ArasaacKeyword({
    required this.idKeyword,
    required this.keyword,
    this.plural,
    this.meaning,
    this.type,
  });

  factory ArasaacKeyword.fromJson(Map<String, dynamic> json) {
    final idKeywordValue = json['idKeyword'];
    final idKeyword = idKeywordValue is int
        ? idKeywordValue
        : (idKeywordValue != null ? int.parse(idKeywordValue.toString()) : 0);
    
    return ArasaacKeyword(
      idKeyword: idKeyword,
      keyword: json['keyword'] as String,
      plural: json['plural'] as String?,
      meaning: json['meaning'] as String?,
      type: json['type'] as int?,
    );
  }
}
