import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'state/root_state.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<RootState>(
      store: rootStore,
      child: StoreConnector<RootState, ThemeState>(
        converter: ThemeState.storeConverter,
        builder: (ctx, state) {
          final brightness = state.brightness;
          return MaterialApp(
            title: 'Markdown Demo',
            theme:
                ThemeData(primarySwatch: Colors.blue, brightness: brightness),
            home: HomePage(),
          );
        },
      ),
    );
  }
}
