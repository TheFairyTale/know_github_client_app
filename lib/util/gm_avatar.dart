import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

class GmAvatar {
  static Widget gmAvatar(
    String url, {
    double width = 30,
    double? height,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    var placeholder = Image.asset("imgs/avatar-default.png", //头像占位图
        width: width,
        height: height);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(2),
      // CachedNetworkImage 是cached_network_image包中提供的一个Widget，
      // 它不仅可以在图片加载过程中指定一个占位图，而且还可以对网络请求的图片进行缓存
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => placeholder,
      ),
    );
  }
}
