import 'package:json_annotation/json_annotation.dart';

part 'cacheConfig.g.dart';

@JsonSerializable()
class CacheConfig {
  CacheConfig();

  /// // 是否开启缓存
  late bool enable;

  ///  缓存最长保留时间，单位（秒）
  late num maxAge;

  /// 首页最大数量
  late num maxCount;

  factory CacheConfig.fromJson(Map<String, dynamic> json) =>
      _$CacheConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CacheConfigToJson(this);
}
