import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:know_github_client_app/common/git.dart';
import 'package:know_github_client_app/common/global.dart';
import 'package:know_github_client_app/common/user_model.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';
import 'package:know_github_client_app/models/user.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:provider/provider.dart';

// import '../index.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool pwdShow = false;
  GlobalKey _formKey = GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  @override
  void initState() {
    // 自动填充上次登录的用户名，填充后将焦点定位到密码输入框
    _unameController.text = Global.profile.lastLogin ?? "";
    if (_unameController.text.isNotEmpty) {
      _nameAutoFocus = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var gm = GmLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(gm.login)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              // TextFormField(
              //     autofocus: _nameAutoFocus,
              //     controller: _unameController,
              //     decoration: InputDecoration(
              //       labelText: gm.userName,
              //       hintText: gm.userName,
              //       prefixIcon: Icon(Icons.person),
              //     ),
              //     // 校验用户名（不能为空）
              //     validator: (v) {
              //       return v == null || v.trim().isNotEmpty
              //           ? null
              //           : gm.userNameRequired;
              //     }),
              TextFormField(
                controller: _pwdController,
                autofocus: !_nameAutoFocus,
                decoration: InputDecoration(
                    labelText: gm.token,
                    hintText: gm.tokenRequired,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          pwdShow ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          pwdShow = !pwdShow;
                        });
                      },
                    )),
                obscureText: !pwdShow,
                //校验密码（不能为空）
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : gm.passwordRequired;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    // color: Theme.of(context).primaryColor,
                    onPressed: _onLogin,
                    // textColor: Colors.white,
                    child: Text(gm.login),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    onPressed: () => {
                      // 清空所有缓存
                      Global.netCache.cache.clear()
                    },
                    child: Text(gm.cleanCache),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    // 先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      await FlutterPlatformAlert.playAlertSound();
      SmartDialog.showLoading(msg: 'Loading...');
      User? user;
      try {
        user = await Git(context)
            .login(_unameController.text, _pwdController.text);
        // 因为登录页返回后，首页会build，所以我们传入false，这样更新user后便不触发更新。
        Provider.of<UserModel>(context, listen: false).user = user;
      } on DioException catch (e) {
        //登录失败则提示
        if (e.response?.statusCode == 401) {
          await FlutterPlatformAlert.showAlert(
            windowTitle: GmLocalizations.of(context).userNameOrPasswordWrong,
            text: GmLocalizations.of(context).userNameOrPasswordWrong,
            alertStyle: AlertButtonStyle.yesNoCancel,
            iconStyle: IconStyle.information,
          );
          // showToast();
        } else {
          await FlutterPlatformAlert.showAlert(
            windowTitle: '',
            text: e.toString(),
            alertStyle: AlertButtonStyle.yesNoCancel,
            iconStyle: IconStyle.information,
          );
        }
      } finally {
        // 隐藏loading框
        SmartDialog.dismiss();
        // Navigator.of(context).pop();
      }
      //登录成功则返回
      if (user != null) {
        Navigator.of(context).pop();
        SmartDialog.showToast(GmLocalizations.of(context).loginSuccessTip);
      }
    }
  }
}
