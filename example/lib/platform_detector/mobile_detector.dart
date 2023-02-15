import 'platform_detector.dart';
import 'dart:io';

PlatformType get currentType {
  if (Platform.isIOS) return PlatformType.IOS;
  if (Platform.isAndroid) return PlatformType.Android;
  return PlatformType.Mobile;
}
