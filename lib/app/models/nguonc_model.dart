class NguoncMovieResponse {
  final String status;
  final NguoncMovie movie;

  NguoncMovieResponse({
    required this.status,
    required this.movie,
  });

  factory NguoncMovieResponse.fromJson(Map<String, dynamic> json) {
    return NguoncMovieResponse(
      status: json['status'] ?? '',
      movie: NguoncMovie.fromJson(json['movie'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'movie': movie.toJson(),
    };
  }
}

class NguoncMovie {
  final String id;
  final String name;
  final String slug;
  final String originalName;
  final String thumbUrl;
  final String posterUrl;
  final String created;
  final String modified;
  final String description;
  final int totalEpisodes;
  final String currentEpisode;
  final String time;
  final String quality;
  final String language;
  final String director;
  final String? casts;
  final List<NguoncEpisodeServer> episodes;

  NguoncMovie({
    required this.id,
    required this.name,
    required this.slug,
    required this.originalName,
    required this.thumbUrl,
    required this.posterUrl,
    required this.created,
    required this.modified,
    required this.description,
    required this.totalEpisodes,
    required this.currentEpisode,
    required this.time,
    required this.quality,
    required this.language,
    required this.director,
    this.casts,
    required this.episodes,
  });

  factory NguoncMovie.fromJson(Map<String, dynamic> json) {
    return NguoncMovie(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      originalName: json['original_name'] ?? '',
      thumbUrl: json['thumb_url'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      created: json['created'] ?? '',
      modified: json['modified'] ?? '',
      description: json['description'] ?? '',
      totalEpisodes: json['total_episodes'] ?? 0,
      currentEpisode: json['current_episode'] ?? '',
      time: json['time'] ?? '',
      quality: json['quality'] ?? '',
      language: json['language'] ?? '',
      director: json['director'] ?? '',
      casts: json['casts'],
      episodes: (json['episodes'] as List?)
          ?.map((e) => NguoncEpisodeServer.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'original_name': originalName,
      'thumb_url': thumbUrl,
      'poster_url': posterUrl,
      'created': created,
      'modified': modified,
      'description': description,
      'total_episodes': totalEpisodes,
      'current_episode': currentEpisode,
      'time': time,
      'quality': quality,
      'language': language,
      'director': director,
      'casts': casts,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}

class NguoncEpisodeServer {
  final String serverName;
  final List<NguoncEpisode> items;

  NguoncEpisodeServer({
    required this.serverName,
    required this.items,
  });

  factory NguoncEpisodeServer.fromJson(Map<String, dynamic> json) {
    return NguoncEpisodeServer(
      serverName: json['server_name'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => NguoncEpisode.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_name': serverName,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class NguoncEpisode {
  final String name;
  final String slug;
  final String embed;
  final String m3u8;

  NguoncEpisode({
    required this.name,
    required this.slug,
    required this.embed,
    required this.m3u8,
  });

  factory NguoncEpisode.fromJson(Map<String, dynamic> json) {
    return NguoncEpisode(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      embed: json['embed'] ?? '',
      m3u8: json['m3u8'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'embed': embed,
      'm3u8': m3u8,
    };
  }
}
