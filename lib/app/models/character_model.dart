class CharacterModel {
  final int malId;
  final String url;
  final String name;
  final String? nameKanji;
  final List<String> nicknames;
  final int favorites;
  final String? about;
  final CharacterImages images;

  CharacterModel({
    required this.malId,
    required this.url,
    required this.name,
    this.nameKanji,
    required this.nicknames,
    required this.favorites,
    this.about,
    required this.images,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      malId: json['mal_id'] ?? 0,
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      nameKanji: json['name_kanji'],
      nicknames: (json['nicknames'] as List?)?.map((e) => e.toString()).toList() ?? [],
      favorites: json['favorites'] ?? 0,
      about: json['about'],
      images: CharacterImages.fromJson(json['images'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'url': url,
      'name': name,
      'name_kanji': nameKanji,
      'nicknames': nicknames,
      'favorites': favorites,
      'about': about,
      'images': images.toJson(),
    };
  }
}

class CharacterImages {
  final String? jpg;
  final String? webp;

  CharacterImages({
    this.jpg,
    this.webp,
  });

  factory CharacterImages.fromJson(Map<String, dynamic> json) {
    return CharacterImages(
      jpg: json['jpg']?['image_url'],
      webp: json['webp']?['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jpg': {'image_url': jpg},
      'webp': {'image_url': webp},
    };
  }

  String get imageUrl => jpg ?? webp ?? '';
}

class CharacterSearchResponse {
  final List<CharacterModel> data;
  final CharacterPagination pagination;

  CharacterSearchResponse({
    required this.data,
    required this.pagination,
  });

  factory CharacterSearchResponse.fromJson(Map<String, dynamic> json) {
    return CharacterSearchResponse(
      data: (json['data'] as List?)
          ?.map((e) => CharacterModel.fromJson(e))
          .toList() ?? [],
      pagination: CharacterPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class CharacterPagination {
  final int lastVisiblePage;
  final bool hasNextPage;
  final int currentPage;
  final CharacterPaginationItems items;

  CharacterPagination({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    required this.items,
  });

  factory CharacterPagination.fromJson(Map<String, dynamic> json) {
    return CharacterPagination(
      lastVisiblePage: json['last_visible_page'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      currentPage: json['current_page'] ?? 1,
      items: CharacterPaginationItems.fromJson(json['items'] ?? {}),
    );
  }
}

class CharacterPaginationItems {
  final int count;
  final int total;
  final int perPage;

  CharacterPaginationItems({
    required this.count,
    required this.total,
    required this.perPage,
  });

  factory CharacterPaginationItems.fromJson(Map<String, dynamic> json) {
    return CharacterPaginationItems(
      count: json['count'] ?? 0,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
    );
  }
}
