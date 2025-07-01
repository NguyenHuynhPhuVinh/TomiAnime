class AnimeModel {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String type;
  final String? source;
  final int? episodes;
  final String status;
  final String? aired;
  final String? duration;
  final String? rating;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? favorites;
  final String? synopsis;
  final String? background;
  final String? season;
  final int? year;
  final List<String> genres;
  final List<String> studios;
  final AnimeImages images;

  AnimeModel({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.type,
    this.source,
    this.episodes,
    required this.status,
    this.aired,
    this.duration,
    this.rating,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    this.synopsis,
    this.background,
    this.season,
    this.year,
    required this.genres,
    required this.studios,
    required this.images,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? '',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      type: json['type'] ?? '',
      source: json['source'],
      episodes: json['episodes'],
      status: json['status'] ?? '',
      aired: json['aired']?['string'],
      duration: json['duration'],
      rating: json['rating'],
      score: json['score']?.toDouble(),
      scoredBy: json['scored_by'],
      rank: json['rank'],
      popularity: json['popularity'],
      members: json['members'],
      favorites: json['favorites'],
      synopsis: json['synopsis'],
      background: json['background'],
      season: json['season'],
      year: json['year'],
      genres: (json['genres'] as List?)?.map((e) => e['name'].toString()).toList() ?? [],
      studios: (json['studios'] as List?)?.map((e) => e['name'].toString()).toList() ?? [],
      images: AnimeImages.fromJson(json['images'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'title_english': titleEnglish,
      'title_japanese': titleJapanese,
      'type': type,
      'source': source,
      'episodes': episodes,
      'status': status,
      'aired': aired,
      'duration': duration,
      'rating': rating,
      'score': score,
      'scored_by': scoredBy,
      'rank': rank,
      'popularity': popularity,
      'members': members,
      'favorites': favorites,
      'synopsis': synopsis,
      'background': background,
      'season': season,
      'year': year,
      'genres': genres,
      'studios': studios,
      'images': images.toJson(),
    };
  }
}

class AnimeImages {
  final String? jpg;
  final String? webp;

  AnimeImages({
    this.jpg,
    this.webp,
  });

  factory AnimeImages.fromJson(Map<String, dynamic> json) {
    return AnimeImages(
      jpg: json['jpg']?['image_url'],
      webp: json['webp']?['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jpg': jpg,
      'webp': webp,
    };
  }
}

class SeasonAnimeResponse {
  final List<AnimeModel> data;
  final Pagination pagination;

  SeasonAnimeResponse({
    required this.data,
    required this.pagination,
  });

  factory SeasonAnimeResponse.fromJson(Map<String, dynamic> json) {
    return SeasonAnimeResponse(
      data: (json['data'] as List?)?.map((e) => AnimeModel.fromJson(e)).toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Pagination {
  final int lastVisiblePage;
  final bool hasNextPage;
  final int currentPage;
  final int? items;

  Pagination({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    this.items,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      lastVisiblePage: json['last_visible_page'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      currentPage: json['current_page'] ?? 1,
      items: json['items']?['count'],
    );
  }
}
