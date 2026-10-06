enum ProductMediaType { image, video, interactive360, unsupported }

class ProductMedia {
  const ProductMedia({
    required this.id,
    required this.path,
    required this.sourceType,
    required this.sourceId,
    required this.type,
    required this.isMain,
    required this.isVisible,
    required this.sortOrder,
    required this.metadata,
    this.posterPath,
    this.mimeType,
    this.altTranslations = const <String, String>{},
  });

  final int id;
  final String path;
  final String sourceType;
  final int? sourceId;
  final ProductMediaType type;
  final bool isMain;
  final bool isVisible;
  final int sortOrder;
  final Map<String, dynamic> metadata;
  final String? posterPath;
  final String? mimeType;
  final Map<String, String> altTranslations;

  bool get isImage => type == ProductMediaType.image;
  bool get isVideo => type == ProductMediaType.video;
  bool get isInteractive360 => type == ProductMediaType.interactive360;
  bool get isSupported => type != ProductMediaType.unsupported;

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final path = json['path'];
    final sourceType = json['source_type'];
    final sourceId = json['source_id'];
    final isMain = json['is_main'];
    final isVisible = json['is_visible'] ?? true;
    final sortOrder = json['sort_order'];
    final rawMetadata = json['media_metadata'];

    if (id is! int || id <= 0) {
      throw const FormatException('media.id must be a positive integer');
    }
    if (path is! String || path.trim().isEmpty) {
      throw const FormatException('media.path must be a non-empty string');
    }
    if (sourceType is! String || sourceType.trim().isEmpty) {
      throw const FormatException(
        'media.source_type must be a non-empty string',
      );
    }
    if (sourceId != null && (sourceId is! int || sourceId <= 0)) {
      throw const FormatException('media.source_id must be a positive integer');
    }
    if (isMain is! bool) {
      throw const FormatException('media.is_main must be boolean');
    }
    if (isVisible is! bool) {
      throw const FormatException('media.is_visible must be boolean');
    }
    if (sortOrder is! int || sortOrder < 0) {
      throw const FormatException('media.sort_order must be non-negative');
    }
    if (rawMetadata != null && rawMetadata is! Map) {
      throw const FormatException('media.media_metadata must be an object');
    }

    final metadata =
        rawMetadata == null
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(rawMetadata as Map);
    final mimeType = _optionalString(metadata['mime_type']);
    final posterPath = _optionalString(metadata['poster_path']);
    final mediaType = _optionalString(metadata['media_type'])?.toLowerCase();
    final is360 = metadata['is_360'];
    if (is360 != null && is360 is! bool) {
      throw const FormatException('media.is_360 must be boolean');
    }

    final alt = <String, String>{};
    final rawAlt = metadata['alt_translations'];
    if (rawAlt != null) {
      if (rawAlt is! Map) {
        throw const FormatException('media.alt_translations must be an object');
      }
      for (final entry in rawAlt.entries) {
        if (entry.key is! String || entry.value is! String) {
          throw const FormatException(
            'media.alt_translations must contain strings',
          );
        }
        alt[entry.key as String] = entry.value as String;
      }
    }

    return ProductMedia(
      id: id,
      path: path.trim(),
      sourceType: sourceType.trim(),
      sourceId: sourceId as int?,
      type: _resolveType(mediaType, mimeType, is360 == true),
      isMain: isMain,
      isVisible: isVisible,
      sortOrder: sortOrder,
      metadata: Map<String, dynamic>.unmodifiable(metadata),
      posterPath: posterPath,
      mimeType: mimeType,
      altTranslations: Map<String, String>.unmodifiable(alt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'path': path,
    'source_type': sourceType,
    'source_id': sourceId,
    'media_metadata': metadata.isEmpty ? null : metadata,
    'is_main': isMain,
    'is_visible': isVisible,
    'sort_order': sortOrder,
  };

  static ProductMediaType _resolveType(
    String? mediaType,
    String? mimeType,
    bool explicitly360,
  ) {
    if (explicitly360 ||
        mediaType == 'interactive_360' ||
        mediaType == '360' ||
        mediaType == 'spin_360') {
      return ProductMediaType.interactive360;
    }
    if (mediaType == 'video' || mimeType?.startsWith('video/') == true) {
      return ProductMediaType.video;
    }
    if (mediaType == 'image' || mimeType?.startsWith('image/') == true) {
      return ProductMediaType.image;
    }
    return ProductMediaType.unsupported;
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('media metadata value must be a string');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
