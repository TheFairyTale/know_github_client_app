import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:know_github_client_app/common/global.dart';

/// 保存缓存信息
///
class CacheObject {
  CacheObject(this.response)
      : timeStamp = DateTime.now().millisecondsSinceEpoch;
  Response response;
  // 缓存创建时间
  int timeStamp;

  @override
  bool operator ==(other) {
    return response.hashCode == other.hashCode;
  }

// 将请求uri作为缓存的key
  @override
  int get hashCode => response.realUri.hashCode;
}

/// 缓存策略具体实现
///
class NetCache extends Interceptor {
  // 为确保迭代器顺序和对象插入时间一致顺序一致，使用LinkedHashMap
  var cache = LinkedHashMap<String, CacheObject>();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!Global.profile.cache!.enable) {
      return handler.next(options);
    }

    // refresh 标记是否是'下拉刷新'
    // dio包的option.extra是专门用于扩展请求参数的
    // 我们通过定义了“refresh”和“noCache”两个参数实现了“针对特定接口或请求来
    // 决定是否启用缓存的机制”
    // 面积含义 refresh	如果为true，则本次请求不使用缓存，但新的请求结果依然会被缓存
    // noCache 本次请求禁用缓存，请求结果也不会被缓存。
    bool refresh = options.extra["refresh"] == true;
    // 如果是下拉刷新，则先删除相关的缓存
    if (refresh) {
      if (options.extra["list"] == true) {
        // 若为列表，则只要url 中包含当前path 的缓存都全部删除（简单实现，并不精准）
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        // 如果不是列表，则只删除uri 相同的缓存
        this.delete(options.uri.toString());
      }

      return handler.next(options);
    }

    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var ob = cache[key];
      if (ob != null) {
        // 若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache!.maxAge) {
          return handler.resolve(ob.response);
        } else {
          // 如果已经过期则删除缓存，继续向服务器请求
          cache.remove(key);
        }
      }
    }

    handler.next(options);
    // super.onRequest(options, handler);
  }

  @override
  onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 如果启用缓存，将返回结果保存到缓存
    if (Global.profile.cache!.enable) {
      _saveCache(response);
    }
    handler.next(response);
  }

  _saveCache(Response object) {
    RequestOptions options = object.requestOptions;

    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == "get") {
      // 如果缓存数量超过最大数量限制，则先移除最早的一条记录
      if (cache.length == Global.profile.cache!.maxCount) {
        cache.remove(cache[cache.keys.first]);
      }
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(object);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}
