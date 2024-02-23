import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:know_github_client_app/common/global.dart';
import 'package:know_github_client_app/models/index.dart';

/// 一个完整的APP，可能会涉及很多网络请求，为了便于管理、收敛请求入口，工程上最好的作法
/// 就是将所有网络请求放到同一个源码文件中。
/// 由于我们的接口都是请求的Github 开发平台提供的API，所以我们定义一个Git类，
/// 专门用于Github API接口调用。另外，在调试过程中，我们通常需要一些工具来查看网络请求
/// 、响应报文，使用网络代理工具来调试网络数据问题是主流方式。
/// 配置代理需要在应用中指定代理服务器的地址和端口，另外Github API是HTTPS协议，
/// 所以在配置完代理后还应该禁用证书校验，
/// 这些配置我们在Git类初始化时执行（init()方法）。

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
  static String _pwd = "";
  static String _basic = '';
  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com/',
    headers: {
      // HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
      //     "application/vnd.github.symmetra-preview+json",
      HttpHeaders.authorizationHeader: _basic,
      "X-GitHub-Api-Version": "2022-11-28"
    },
  ));

  set basic(String pwd) {
    print("basic() 输入值：" + pwd);
    _pwd = pwd;
    _basic = 'Bearer ' + _pwd;
    // _basic = 'Bearer ${base64.encode(utf8.encode(_pwd))}';
  }

  /// 该方法判断了是否是调试环境，然后做了一些针对调试环境的网络配置（设置代理和禁用证书校验）
  /// 该方法是应用启动时被调用的（Global.init()方法中会调用Git.init()）
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
    //String basic = 'Basic' + base64.encode(utf8.encode('$login:$pwd'));
    basic = pwd;
    Map<String, dynamic> jsonedResp = Map();

    // print("now pwd: " + _pwd);
    print(HttpHeaders.authorizationHeader + ": " + _basic);

    var r = await dio.get(
      // '/user',
      '/octocat',
      options: _options.copyWith(headers: {
        HttpHeaders.authorizationHeader: _basic,
        "X-GitHub-Api-Version": "2022-11-28"
      }, extra: {
        // 本登陆接口禁止缓存。
        "noCache": true,
      }),
    );

    var resp = r.data;
    if (resp is String) {
      // await FlutterPlatformAlert.showAlert(
      //   windowTitle: 'exception error: ',
      //   text: resp,
      //   alertStyle: AlertButtonStyle.yesNoCancel,
      //   iconStyle: IconStyle.information,
      // );
      // // todo 可能是错误的返回.
      // return User();
      print("返回请求：" + resp);

      RequestOptions ro = RequestOptions();
      ro.data = resp;
      // 登陆不成功时让其报出错误使外部调用方捕获错误进行处理
      throw DioException.badResponse(
          statusCode: 401,
          requestOptions: ro,
          response: Response(requestOptions: ro));
    }

    // 登陆成功后更新公共头（authorization)，之后所有请求都会带上用户身份信息.
    dio.options.headers[HttpHeaders.authorizationHeader] = _basic;

    // 清空所有缓存
    Global.netCache.cache.clear();
    // 更新profile 中的token 信息
    Global.profile.token = _basic;

// 如果login 按钮按下后请求成功:
    return User.fromJson(resp);
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
