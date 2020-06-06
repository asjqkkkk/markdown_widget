import 'package:easy_model/easy_model.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModelWidget<GlobalModel>(
        modelBuilder: () => GlobalModel(),
        childBuilder: (ctx, model) {
          final brightness = model.brightness;
          model = null;
          return MaterialApp(
            title: 'Markdown Demo',
            theme:
                ThemeData(primarySwatch: Colors.blue, brightness: brightness),
            home: HomePage(),
          );
        });
  }
}

class GlobalModel extends Model {
  Brightness brightness = Brightness.light;
}
