import 'dart:math';
import 'dart:io';

import 'package:localsend_app/gen/strings.g.dart';

String generateRandomAlias() {
  final random = Random();
  final adj = t.aliasGenerator.adjectives;
  final fruits = t.aliasGenerator.fruits;

  // The combination of both is locale dependent too.
  return t.aliasGenerator.combination(
    adjective: adj[random.nextInt(adj.length)],
    fruit: fruits[random.nextInt(fruits.length)],
  );
}

/// 随机字符集（可以根据需要调整，例如大写字母 + 数字）
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';

/// 生成随机包含 2 个字符的后缀（例如 "x9" 或 "aB"）
String _generateRandomSuffix([int length = 2]) {
  final random = Random();
  return List.generate(length, (_) => _chars[random.nextInt(_chars.length)]).join();
}

/// 生成默认设备名称：设备主机名 + 随机 2 位字符串
String generateDeviceAlias() {
  String deviceName = 'Device';

  try {
    final host = Platform.localHostname;
    if (host.isNotEmpty && host.toLowerCase() != 'localhost') {
      deviceName = host;
    }
  } catch (_) {}

  // 拼接随机 2 位字符串，例如: "Pixel-6-a8" 或 "Jack-PC-k2"
  final suffix = _generateRandomSuffix(2);

  return '$deviceName-$suffix';
}
