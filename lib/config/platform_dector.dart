import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;


class PlatformDetector {

  static bool isMobile() => !kIsWeb;

  static final _iOS = ['iPad Simulator', 'iPhone Simulator', 'iPod Simulator', 'iPad', 'iPhone', 'iPod'];

  static bool isWebIOS() {
    var matches = false;
    _iOS.forEach((name) {
      if (html.window.navigator.platform.contains(name) || html.window.navigator.userAgent.contains(name)) {
        matches = true;
      }
    });
    return matches;
  }

  static bool isWebAndroid() =>
      html.window.navigator.platform == "Android" || html.window.navigator.userAgent.contains("Android");

  static bool isWebMobile() => isWebAndroid() || isWebIOS();


}