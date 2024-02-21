import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:know_github_client_app/common/locale_model.dart';
import 'package:know_github_client_app/common/theme_model.dart';
import 'package:know_github_client_app/common/user_model.dart';
import 'package:know_github_client_app/l10n/gm_localizations.dart';
import 'package:know_github_client_app/l10n/gm_localizations_delegate.dart';
import 'package:know_github_client_app/routes/home_page.dart';
import 'package:know_github_client_app/routes/language_route.dart';
import 'package:know_github_client_app/routes/login_route.dart';
import 'package:know_github_client_app/routes/theme_change_route.dart';
import 'package:provider/provider.dart';

import 'common/global.dart';

/// App 入口函数，初始化完成后才会加载UI(也就是MyApp)，MyApp 是应用的入口Widget
void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 根widget是MultiProvider，
    // 它将主题、用户、语言三种状态绑定到了应用的根上，
    // 如此一来，任何路由中都可以通过Provider.of()来获取这些状态，
    // 也就是说这三种状态是全局共享的！
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeModel()),
          ChangeNotifierProvider(create: (_) => UserModel()),
          ChangeNotifierProvider(create: (_) => LocaleModel()),
        ],
        child: Consumer2<ThemeModel, LocaleModel>(
            builder: (BuildContext context, themeModel, localeModel, child) {
          // 在构建MaterialApp时，我们配置了APP支持的语言列表，以及监听了系统语言改变事件
          // MaterialApp 则依赖/消费 了ThemeModel，LocaleModel
          // 所以当APP主题或语言改变时MaterialApp会重新构建
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: themeModel.theme as MaterialColor,
            ),
            onGenerateTitle: (context) {
              return GmLocalizations.of(context).title;
            },

            // 应用主页
            home: HomeRoute(),
            locale: localeModel.getLocale(),

            // 配置了的App 支持的语言列表
            // 只支持美国英语和中文简体
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('zh', 'CN'),
            ],
            localizationsDelegates: [
              // 本地化的代理类
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,

              // 为了支持多语言，我们实现了一个GmLocalizationsDelegate
              // 子Widget中都可以通过GmLocalizations 来动态获取APP当前语言对应的文案
              GmLocalizationsDelegate()
            ],

            // 监听系统语言改变事件
            localeResolutionCallback: (_locale, supportedLocales) {
              if (localeModel.getLocale() != null) {
                // 如果已经选定语言，则不跟随系统的设置
                return localeModel.getLocale();
              } else {
                // 跟随系统设定
                Locale locale;
                if (supportedLocales.contains(_locale)) {
                  locale = _locale!;
                } else {
                  // 如果系统语言不是中文或英语，则默认语言使用英语
                  locale = Locale('en', 'US');
                }
                return locale;
              }
            },
            // 注册路由表
            routes: <String, WidgetBuilder>{
              "login": (context) => LoginRoute(),
              "themes": (context) => ThemeChangeRoute(),
              "language": (context) => LanguageRoute(),
            },
            // flutter_smart_dialog 初始化
            navigatorObservers: [FlutterSmartDialog.observer],
            builder: FlutterSmartDialog.init(),
          );
        }));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
