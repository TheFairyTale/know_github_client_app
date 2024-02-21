import 'package:know_github_client_app/common/profile_change_notifier.dart';
import 'package:know_github_client_app/models/index.dart';

class UserModel extends ProfileChangeNotifier {
  // User? get user => profile.user;
  // 瞎改
  User get user => profile.user ?? User();

  // App 是否登陆（如果有信息则代表登陆过了)
  bool get isLogin => user != null;

  // 用户信息变化时，更新用户信息并通知依赖于它的其他Widget 更新
  set setUser(User user) {
    if (user?.login != profile.user?.login) {
      profile.lastLogin = profile.user?.login;
      profile.user = user;
      notifyListeners();
    }
  }

  /// 当登出时，调用该方法将user 对象置为空
  set user(User user) {
    profile.user = user;
    // 置空时是否需要调用该方法？
    notifyListeners();
  }
}
