import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/user_model.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';
import 'package:know_github_client_app/models/user.dart';
import 'package:know_github_client_app/util/gm_avatar.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
          context: context
          // 移除顶部padding
          ,
          removeTop: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 构建抽屉菜单顶部
              _buildHeader(),
              // 构建功能菜单
              Expanded(child: _buildMenus()),
            ],
          )),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserModel>(builder: (context, value, child) {
      return GestureDetector(
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // 如果已经登陆，则显示用户头像，没有登陆则显示默认图像
                child: ClipOval(
                  child: value.isLogin
                      ? GmAvatar.gmAvatar(value.user!.avatar_url, width: 80)
                      : Image.asset(
                          // todo cannot load image asset: imgs/avatar-default.png
                          // not found
                          "imgs/avatar-default.png",
                          width: 80,
                        ),
                ),
              ),
              Text(
                value.isLogin
                    ? value.user!.login
                    : GmLocalizations.of(context).login,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
        ),
        onTap: () {
          if (!value.isLogin) Navigator.of(context).pushNamed("login");
        },
      );
    });
  }

  /// 构建菜单项
  Widget _buildMenus() {
    return Consumer<UserModel>(
        builder: (BuildContext context, UserModel userModel, Widget? child) {
      var gm = GmLocalizations.of(context);
      return ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(gm.theme),
            onTap: () => Navigator.pushNamed(context, "themes"),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(gm.language),
            onTap: () => Navigator.pushNamed(context, "language"),
          ),
          if (userModel.isLogin)
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: Text(gm.logout),
              onTap: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      // 退出账号前先弹个二次确认窗
                      return AlertDialog(
                        content: Text(gm.logoutTip),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(gm.cancel)),
                          TextButton(
                              onPressed: () {
                                // 该赋值语句会触发MaterialApp rebuild
                                // userModel.user = null;
                                // 用户点击“注销”，userModel.user 会被置空，
                                // 此时所有依赖userModel的组件都会被rebuild，如主页会恢复成未登录的状态
                                userModel.user = User();
                                Navigator.pop(context);
                              },
                              child: Text(gm.yes)),
                        ],
                      );
                    }));
              },
            )
        ],
      );
    });
  }
}
