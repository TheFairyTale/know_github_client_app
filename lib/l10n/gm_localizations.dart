import 'package:flutter/material.dart';

/// Localizations类中主要实现提供了本地化值，如文本
/// 而GmLocalizations中会根据当前的语言来返回不同的文本，如title，
/// 我们可以将所有 *需要支持多语言的文本* 都在此类中定义。
/// GmLocalizations的实例将会在Delegate类的load方法中创建
class GmLocalizations {
  GmLocalizations(this.isZh);

  // 是否为中文
  bool isZh = false;

  // 为了使用方便，定义一个静态方法
  static GmLocalizations of(BuildContext context) {
    GmLocalizations? gmLocalizations =
        Localizations.of<GmLocalizations>(context, GmLocalizations);

// https://dreamdropsakura.asia/archives/1708390494767
    return gmLocalizations ?? GmLocalizations(true);
  }

  // Locale 相关值，title 为应用标题
  String get title {
    return isZh ? "Flutter应用" : "Flutter App";
  }

  String get home {
    return isZh ? "主页" : "HomePage";
  }

  String get login {
    return isZh ? "登录" : "login";
  }

  String get loginSuccessTip {
    return isZh ? "登录成功!" : "Login success!";
  }

  String get noDescription {
    return isZh ? "没有描述" : "No description";
  }

  String get theme {
    return isZh ? "主题外观" : "Theme";
  }

  String get language {
    return isZh ? "语言" : "Language";
  }

  String get logout {
    return isZh ? "退出当前账户" : "logout";
  }

  String get logoutTip {
    return isZh ? "确定退出当前账户吗?" : "confirm logout this account?";
  }

  String get cancel {
    return isZh ? "取消" : "cancel";
  }

  String get yes {
    return isZh ? "确定" : "confirm";
  }

  String get auto {
    return isZh ? "自动" : "auto";
  }

  String get userNameOrPasswordWrong {
    return isZh ? "用户名或密码错误" : "UserName or Password wrong.";
  }

  String get passwordRequired {
    return isZh ? "需要密码" : "need Password";
  }

  String get password {
    return isZh ? "需要密码" : "input password";
  }

  String get userNameRequired {
    return isZh ? "用户名不能为空" : "UserName cannot blank";
  }

  String get userName {
    return isZh ? "用户名" : "Username";
  }
  // 其他希望跟随语言变化而变化的值...
}
