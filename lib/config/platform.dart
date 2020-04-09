import 'package:flutter/foundation.dart' show kIsWeb;


class PlatformDetector {

  bool isMobile() => !kIsWeb;

}