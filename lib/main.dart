import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'hooks/stores.dart';
import 'pages/communities_tab.dart';
import 'pages/create_post.dart';
import 'pages/home_tab.dart';
import 'pages/profile_tab.dart';
import 'stores/accounts_store.dart';
import 'stores/config_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configStore = ConfigStore();
  await configStore.load();

  final accountsStore = AccountsStore();
  await accountsStore.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: configStore,
        ),
        Provider<AccountsStore>(
          create: (_) => accountsStore,
          dispose: (_, store) => store.dispose(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final configStore = useConfigStore();
    final maybeAmoledColor = configStore.amoledDarkMode ? Colors.black : null;

    return MaterialApp(
      title: 'Lemmur',
      themeMode: configStore.theme,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: maybeAmoledColor,
        backgroundColor: maybeAmoledColor,
        canvasColor: maybeAmoledColor,
        cardColor: maybeAmoledColor,
        splashColor: maybeAmoledColor,
      ),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  final List<Widget> pages = [
    HomeTab(),
    CommunitiesTab(),
    Center(child: Text('search')), // TODO: search tab
    UserProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTab = useState(0);

    useEffect(() {
      Future.microtask(
        () => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
        )),
      );

      return null;
    }, [theme.scaffoldBackgroundColor]);

    var tabCounter = 0;

    tabButton(IconData icon) {
      final tabNum = tabCounter++;

      return IconButton(
        icon: Icon(icon),
        color: tabNum == currentTab.value ? theme.accentColor : null,
        onPressed: () => currentTab.value = tabNum,
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentTab.value,
        children: pages,
      ),
      floatingActionButton: CreatePostFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 7,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              tabButton(Icons.home),
              tabButton(Icons.list),
              SizedBox.shrink(),
              SizedBox.shrink(),
              tabButton(Icons.search),
              tabButton(Icons.person),
            ],
          ),
        ),
      ),
    );
  }
}
