import 'package:json_annotation/json_annotation.dart';

part 'movie_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MovieModel {
  final int id;
  final String title;
  @JsonKey(name: 'title_english')
  final String? titleEnglish;
  final int year;
  final double rating;
  final int runtime;
  final List<String>? genres;
  final String? summary;
  @JsonKey(name: 'description_full')
  final String? descriptionFull;
  final String? synopsis;
  @JsonKey(name: 'yt_trailer_code')
  final String? ytTrailerCode;
  final String? language;
  @JsonKey(name: 'background_image')
  final String? backgroundImage;
  @JsonKey(name: 'medium_cover_image')
  final String? mediumCoverImage;
  @JsonKey(name: 'large_cover_image')
  final String? largeCoverImage;
  @JsonKey(name: 'medium_screenshot_image1')
  final String? screenshot1;
  @JsonKey(name: 'medium_screenshot_image2')
  final String? screenshot2;
  @JsonKey(name: 'medium_screenshot_image3')
  final String? screenshot3;
  final List<CastModel>? cast;
  @JsonKey(name: 'like_count')
  final int? likeCount;

  MovieModel({
    required this.id,
    required this.title,
    this.titleEnglish,
    required this.year,
    required this.rating,
    required this.runtime,
    this.genres,
    this.summary,
    this.descriptionFull,
    this.synopsis,
    this.ytTrailerCode,
    this.language,
    this.backgroundImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.screenshot1,
    this.screenshot2,
    this.screenshot3,
    this.cast,
    this.likeCount,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);
}

@JsonSerializable()
class CastModel {
  final String? name;
  @JsonKey(name: 'character_name')
  final String? characterName;
  @JsonKey(name: 'url_small_image')
  final String? urlSmallImage;

  CastModel({this.name, this.characterName, this.urlSmallImage});

  factory CastModel.fromJson(Map<String, dynamic> json) => _$CastModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastModelToJson(this);
}
