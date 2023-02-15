import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'pages/router.dart';
import 'state/root_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<RootState>(
      store: rootStore,
      child: StoreConnector<RootState, ThemeState>(
        converter: ThemeState.storeConverter,
        builder: (ctx, state) {
          final brightness = state.brightness;
          return MaterialApp.router(
            title: 'Markdown Demo',
            theme:
                ThemeData(primarySwatch: Colors.blue, brightness: brightness),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
