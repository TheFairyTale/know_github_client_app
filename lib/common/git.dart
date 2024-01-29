import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/global.dart';
import 'package:know_github_client_app/models/index.dart';

/// 在本实例中，我们只用到了登录接口和获取用户项目的接口，
/// 所以在Git类中只定义了login(…)和getRepos(…)方法，
/// 如果读者要在本实例的基础上扩充功能，读者可以将其他的接口请求方法添加到Git类中，
/// 这样便实现了网络请求接口在代码层面的集中管理和维护
class Git {
  /// 在网络请求过程中可能会需要使用当前的context 信息，比如在请求失败时
  /// 打开一个新路由，而打开新路由需要context 信息
  Git([this.context]) {
    _options = Options(extra: {"context": context});
  }

  BuildContext? context;
  late Options _options;
  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com/',
    headers: {
      HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
          "application/vnd.github.symmetra-preview+json",
    },
  ));

  static void init() {
    // 添加缓存插件
    dio.interceptors.add(Global.netCache);
    // 设置用户token （可能为null，代表未登录)
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    // 在调试模式下需要抓包调试，故使用proxy，禁用Https 证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        // client.findProxy = (uri) {
        //   return 'PROXY 192.168.50.154:8888';
        // };
        //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  /// 登陆接口，登陆完成返回用户信息
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic' + base64.encode(utf8.encode('$login:$pwd'));
    var r = await dio.get(
      '/user',
      options: _options.copyWith(headers: {
        HttpHeaders.authorizationHeader: basic
      }, extra: {
        // 本登陆接口禁止换成。
        "noCache": true,
      }),
    );

    // 登陆成功后更新公共头（authorization)，之后所有请求都会带上用户身份信息.
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;

    // 清空所有缓存
    Global.netCache.cache.clear();
    // 更新profile 中的token 信息
    Global.profile.token = basic;

    return User.fromJson(r.data);
  }

  /// 获取用户项目列表
  Future<List<Repo>> getRepos({
    // query 参数， 用于接收分页信息
    Map<String, dynamic>? queryParam,
    refresh = false,
  }) async {
    if (refresh) {
      // 列表下拉刷新，需要删除缓存（拦截器中会读取这些信息）
      _options.extra!.addAll({"refresh": true, "list": true});
    }
    var r = await dio.get<List>(
      'user/repos',
      queryParameters: queryParam,
      options: _options,
    );

    return r.data!.map((e) => Repo.fromJson(e)).toList();
  }
}
