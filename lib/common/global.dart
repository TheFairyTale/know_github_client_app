import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/git.dart';
import 'package:know_github_client_app/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache_object.dart';

// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red
];

///
/// Global 类，主要管理app 全局变量
/// 此种会贯穿整个APP生命周期的变量，用于单纯的保存一些信息，或者封装一些全局工具和方法的对象
/// @author TheFairyTale
/// @since 2024-01-15
///
class Global {
  static late SharedPreferences _preferences;
  static Profile profile = Profile();
// 网络缓存对象
  static NetCache netCache = NetCache();

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release 版本
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  ///
  /// 初始化全局信息，会在App启动时执行
  /// 注意该方法不能报错，否则导致runApp() 也就是Flutter 主程序无法启动(根本执行不到runApp(MyApp()))
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();
    var _profile = _preferences.getString("profile");
    // try {

    // } catch (e) {
    //   print(e);
    // }
    if (_profile != null) {
      try {
        dynamic profileDecoded = jsonDecode(_profile);
        profile = Profile.fromJson(profileDecoded);
      } catch (e) {
        print(e);
      }
    } else {
      // 默认主题索引为0，也就是默认蓝色外观的
      // 注意其中的.. 级联符号是 .. 或者?.. , 用来在同一对象上进行序列操作，
      // 级联操作可以让我们少写很多代码，可以在创建一个对象的同时，给对象赋值
      profile = Profile()..theme = 0;
    }

    // 如果没有缓存策略，设置默认缓存策略
    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 初始化网络请求相关配置
    Git.init();
  }

  // 持久化Profile 信息
  static saveProfile() =>
      _preferences.setString("profile", jsonEncode(profile.toJson()));
}
