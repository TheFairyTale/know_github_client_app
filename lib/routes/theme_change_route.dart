import 'package:flutter/material.dart';
import 'package:know_github_client_app/common/global.dart';
import 'package:know_github_client_app/common/theme_model.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';
import 'package:provider/provider.dart';

/// 一个完整的主题Theme包括很多选项，这些选项在ThemeData中定义。本实例为了简单起见，
/// 我们只配置主题颜色。我们提供几种默认预定义的主题色供用户选择，用户点击一种色块后则更新主题。
///
class ThemeChangeRoute extends StatelessWidget {
  const ThemeChangeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).theme),
      ),
      body: ListView(
        //显示主题色块
        children: Global.themes.map<Widget>((e) {
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Container(
                color: e,
                height: 40,
              ),
            ),
            onTap: () {
              //主题更新后，MaterialApp会重新build
              Provider.of<ThemeModel>(context, listen: false).theme = e;
            },
          );
        }).toList(),
      ),
    );
  }
}
