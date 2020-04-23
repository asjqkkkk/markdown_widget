import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_dector.dart' if (dart.library.io) 'mobile_dector.dart';

class PlatformDetector {
  static bool get isMobile => !kIsWeb;

  static bool get isIOS => currentType == PlatformType.IOS;

  static bool get isAndroid => currentType == PlatformType.Android;

  static bool get isWebMobile =>
      currentType == PlatformType.WebAndroid ||
      currentType == PlatformType.WebIos;

  @override
  String toString() {
    return "Platform:  isMobile-$isMobile   isIOS-$isIOS   isAndroid-$isAndroid   isWebMobile-$isWebMobile";
  }
}

enum PlatformType { Web, Mobile, Android, IOS, WebAndroid, WebIos }
