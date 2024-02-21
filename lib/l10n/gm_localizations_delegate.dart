// Locale 代理类
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';

class GmLocalizationsDelegate extends LocalizationsDelegate<GmLocalizations> {
  const GmLocalizationsDelegate();

  // 是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // flutter 会调用此类加载相应的Locale 资源类
  @override
  Future<GmLocalizations> load(Locale locale) {
    print("$locale");
    return SynchronousFuture<GmLocalizations>(
        GmLocalizations(locale.languageCode == "zh"));
  }

  /// shouldReload的返回值决定当Localizations组件重新build时，
  /// 是否调用load方法重新加载Locale资源。一般情况下，Locale资源只应该在Locale切换时加载一次，
  /// 不需要每次在Localizations重新build时都加载，所以返回false即可。
  /// 可能有些人会担心返回false的话在APP启动后用户再改变系统语言时load方法将不会被调用，
  /// 所以Locale资源将不会被加载。事实上，
  /// 每当Locale改变时Flutter都会再调用load方法加载新的Locale，无论shouldReload返回true还是false
  ///
// 关于协变covariant https://blog.csdn.net/B1151937289/article/details/119523464
  @override
  bool shouldReload(covariant LocalizationsDelegate<GmLocalizations> old) {
    // throw UnimplementedError();
    return false;
  }
}
