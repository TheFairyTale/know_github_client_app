import 'package:json_annotation/json_annotation.dart';
import "user.dart";
import "cacheConfig.dart";
part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User? user;
  String? token;
  late num theme = 0;
  CacheConfig? cache;
  String? lastLogin;
  String? locale;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() {
    User? user = this.user;
    Map<String, dynamic>? jsonedUserObj = user?.toJson();

    // is ok?
    this.user = jsonedUserObj as User?;

    return _$ProfileToJson(this);
  }
}
