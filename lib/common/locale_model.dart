import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/profile_change_notifier.dart';

class LocaleModel extends ProfileChangeNotifier {
  // 获取当前用户的APP语言配置Locale 类，如果为null，则语言跟随系统
  Locale getLocale() {
    if (profile.locale == null) return const Locale('en');
    // 如果没有设置，默认为英文
    var t = profile.locale?.split("_");
    if (t != null) {
      return Locale(t[0], t[1]);
    }
    return const Locale('en');
  }

  /// Dart 中没有 public、protected 和 private 的概念
  /// 如果成员变量前面没有添加下划线 _，那么这个成员变量为公有成员变量
  /// 如果成员变量前面添加下划线 _，那么这个成员变量为私有成员变量
  ///
  // // 获取当前Locale 的字符串表示，由于可能为空，故类型不是String 而是String? (可能为空的String类型)
  // 已修改为当为空时默认为en 英文
  String get locale => profile.locale ?? "en";

  // 用户改变APP语言后，通知依赖项更新，新语言即可立即生效
  set setLocale(String locale) {
    if (locale != profile.locale) {
      profile.locale = locale;
      // 通知其他、所有依赖项进行更新
      notifyListeners();
    }
  }

  set locale(String? locale) {
    if (locale != profile.locale) {
      profile.locale = locale;
      // 通知其他、所有依赖项进行更新
      notifyListeners();
    }
  }
}
