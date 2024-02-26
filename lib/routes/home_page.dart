import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:know_github_client_app/common/git.dart';
import 'package:know_github_client_app/common/user_model.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';
import 'package:know_github_client_app/models/index.dart';
import 'package:know_github_client_app/widgets/my_drawer.dart';
import 'package:know_github_client_app/widgets/repo_item.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  static const loadingTag = "##loading##"; // 表尾标记
  var _items = <Repo>[Repo()..name = loadingTag];
  // 定义是否还有数据
  bool hasMore = true;
  // 当前请求的是第几页
  int page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 主页的标题（title）我们是通过GmLocalizations.of(context).home来获得，
        // GmLocalizations是我们提供的一个Localizations类，用于支持多语言，
        // 因此当APP语言改变时，凡是使用GmLocalizations动态获取的文案都会是相应语言的文案
        title: Text(GmLocalizations.of(context).home),
      ),
      body: _buildBody(),
      drawer: MyDrawer(),
    );
  }

  /// 构建主页内容
  Widget _buildBody() {
    UserModel userModel = Provider.of<UserModel>(context);
    if (!userModel.isLogin) {
      // 用户未登陆时展示登陆按钮
      return Center(
        child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed("login"),
            child: Text(GmLocalizations.of(context).login)),
      );
    } else {
      // 用户已登陆则显示项目列表
      // itemBuilder为列表项的构建器（builder），我们需要在该回调中构建每一个列表项Widget
      return ListView.separated(
          itemBuilder: (context, index) {
            // 如果到表尾
            if (_items[index].name == loadingTag) {
              // 不足100 条，继续获取数据
              if (hasMore) {
                // 获取数据
                _retrieveData();
                // 加载时显示loading
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              } else {
                // 已经加载了100 条，不在继续获取数据
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "没有更多",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
            }
            return RepoItem(_items[index]);
          },
          separatorBuilder: (context, index) => Divider(
                height: .0,
              ),
          itemCount: _items.length);
    }
  }

  /// _retrieveData() 方法用于获取项目列表，具体逻辑是：每次请求获取20条，
  /// 当获取成功时，先判断是否还有数据（根据本次请求的项目条数是否等于期望的20条来判断还有没有更多的数据），
  /// 然后将新获取的数据添加到_items中，然后更新状态
  ///
  void _retrieveData() async {
    // Git(context).getRepos() 需要refresh 参数来判断是否使用缓存
    try {
      var data = await Git(context).getRepos(
        queryParam: {
          'page': page,
          'page_size': 20,
        },
      );

      // 如果返回的数据小于指定的条数，则代表没有更多的数据，反之则否
      //
      hasMore = data.length > 0 && data.length % 20 == 0;
      // 把请求到的新数据添加到items 中
      setState(() {
        _items.insertAll(_items.length - 1, data);
        page++;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await FlutterPlatformAlert.showAlert(
          windowTitle:
              GmLocalizations.of(context).userNameOrPasswordWrongNeedRelogin,
          text: GmLocalizations.of(context).userNameOrPasswordWrongNeedRelogin,
          alertStyle: AlertButtonStyle.yesNoCancel,
          iconStyle: IconStyle.information,
        );
        Navigator.of(context).pushNamed("login");
        // showToast();
      } else {
        await FlutterPlatformAlert.showAlert(
          windowTitle: '',
          text: e.toString(),
          alertStyle: AlertButtonStyle.yesNoCancel,
          iconStyle: IconStyle.information,
        );
      }
    }
  }
}
