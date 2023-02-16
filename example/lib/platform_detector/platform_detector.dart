import 'package:flutter/foundation.dart';
import 'web_detector.dart' if (dart.library.io) 'mobile_detector.dart';

class PlatformDetector {
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get isIOS => currentType == PlatformType.IOS;

  static bool get isAndroid => currentType == PlatformType.Android;

  static bool get isWebMobile =>
      currentType == PlatformType.WebAndroid ||
      currentType == PlatformType.WebIos;

  static bool get isAllMobile => isMobile || isWebMobile;

  @override
  String toString() {
    return "Platform:  isMobile-$isMobile   isIOS-$isIOS   isAndroid-$isAndroid   isWebMobile-$isWebMobile";
  }
}

enum PlatformType { Web, Mobile, Android, IOS, WebAndroid, WebIos }
