import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/global.dart';
import 'package:know_github_client_app/models/index.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get profile => Global.profile;

  @override
  void notifyListeners() {
    // 保存Profile 的变更
    Global.saveProfile();
    // 通知依赖的Widget 更新
    super.notifyListeners();
  }
}
