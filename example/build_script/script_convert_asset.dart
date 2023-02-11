import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

///convert online media to assets media
void main() async {
  final assetDir = Directory(assetPath);
  final assetFiles = assetDir.listSync();
  await _traversalFile(assetFiles);
  print('assetPath:$assetPath');
}

String get assetPath => p.join(Directory.current.path, 'example', 'assets');

Future _traversalFile(List<FileSystemEntity> list) async {
  for (final fileEntity in list) {
    if (fileEntity is File && fileEntity.path.endsWith('.md')) {
      await _convertMedia(fileEntity);
    } else if (fileEntity is Directory) {
      _traversalFile(fileEntity.listSync());
    }
  }
}

Future _convertMedia(File file) async {
  final content = file.readAsStringSync();
  String newContent = content.toString();
  if (_mediaReg.hasMatch(content)) {
    final matches = _mediaReg.allMatches(content);
    for (var regExpMatch in matches) {
      final fullMedia = regExpMatch[0] ?? '';
      final rematch = _mediaLinkReg.firstMatch(fullMedia);
      final mediaLink = rematch == null ? '' : (rematch[0] ?? '');
      if (mediaLink.isNotEmpty && mediaLink.startsWith('http')) {
        final result = await _downloadFile(mediaLink);
        final newFullMedia = fullMedia.replaceAll(mediaLink, result);
        newContent = newContent.replaceAll(fullMedia, newFullMedia);
      }
    }
  }
  if (newContent != content) file.writeAsStringSync(newContent);
}

Future<String> _downloadFile(String url) async {
  try {
    print('🔥🔥🔥  $url  is downloading');
    http.Client client = new http.Client();
    final req = await client.get(Uri.parse(url));
    final bytes = req.bodyBytes;
    final contentType = req.headers['content-type'] ?? '';
    final mediaType = MediaType.parse(contentType);
    final filetype = contentType2FileTypes[mediaType.mimeType];
    final time = DateTime.now().millisecondsSinceEpoch;
    final filename = filetype == null ? p.basename(url) : '$time.$filetype';
    final file = File(p.join(assetPath, 'script_medias', filename));
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    final result = 'assets/script_medias/$filename';
    print('✨✨✨  $url  download succeed: $result');
    return result;
  } catch (e) {
    print('🔴🔴🔴 $url  download failed: ${e}');
    return url;
  }
}

final _mediaReg = RegExp(r'(!\[.*?\]\(.*?\))|(<img.*?(?:>|\/>))');
final _mediaLinkReg = RegExp(r'((?<=\().*?(?=\)))|((?<=src\s*=\s*").*?(?="))');
const contentType2FileTypes = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/svg+xml': 'svg',
  'image/webp': 'webp',
  'video/mp4': 'mp4'
};
