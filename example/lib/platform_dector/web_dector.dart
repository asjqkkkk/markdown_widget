import 'dart:html' as html;
import 'platform_dector.dart';

PlatformType get currentType {
  if (isWebIOS()) return PlatformType.WebIos;
  if (isWebAndroid()) return PlatformType.WebAndroid;
  return PlatformType.Web;
}

final _iOS = [
  'iPad Simulator',
  'iPhone Simulator',
  'iPod Simulator',
  'iPad',
  'iPhone',
  'iPod'
];

bool isWebIOS() {
  var matches = false;
  _iOS.forEach((name) {
    if (html.window.navigator.platform.contains(name) ||
        html.window.navigator.userAgent.contains(name)) {
      matches = true;
    }
  });
  return matches;
}

bool isWebAndroid() =>
    html.window.navigator.platform == "Android" ||
    html.window.navigator.userAgent.contains("Android");
