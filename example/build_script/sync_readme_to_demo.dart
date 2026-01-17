import 'dart:io';
import 'package:path/path.dart' as p;

/// Sync README files to demo assets
///
/// This script copies the README files from the root directory to the demo assets,
/// ensuring that the demo documentation stays in sync with the main README.
///
/// Usage: dart run example/build_script/sync_readme_to_demo.dart
void main() {
  print('🔄 Syncing README files to demo assets...');

  final projectRoot = _findProjectRoot();
  final readmeFile = File(p.join(projectRoot, 'README.md'));
  final readmeZhFile = File(p.join(projectRoot, 'README_ZH.md'));
  final demoEnFile = File(p.join(projectRoot, 'example', 'assets', 'demo_en.md'));
  final demoZhFile = File(p.join(projectRoot, 'example', 'assets', 'demo_zh.md'));

  // Copy English README
  if (readmeFile.existsSync()) {
    readmeFile.copySync(demoEnFile.path);
    print('✅ Copied README.md -> ${demoEnFile.path}');
  } else {
    print('⚠️  README.md not found');
  }

  // Copy Chinese README
  if (readmeZhFile.existsSync()) {
    readmeZhFile.copySync(demoZhFile.path);
    print('✅ Copied README_ZH.md -> ${demoZhFile.path}');
  } else {
    print('⚠️  README_ZH.md not found');
  }

  print('✨ Sync completed!');
}

/// Find the project root directory by looking for pubspec.yaml
String _findProjectRoot() {
  Directory current = Directory.current;
  while (current.parent.path != current.path) {
    final pubspec = File(p.join(current.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      // Check if this is the root project (has lib folder with markdown_widget)
      final libDir = Directory(p.join(current.path, 'lib'));
      if (libDir.existsSync()) {
        final files = libDir.listSync();
        if (files.any((f) => f.path.contains('markdown_widget'))) {
          return current.path;
        }
      }
    }
    current = current.parent;
  }

  // Fallback to current directory
  return Directory.current.path;
}
