import 'dart:math';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
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

String _generateRandomSuffix([int length = 2]) {
  final random = Random();
  return List.generate(length, (_) => _chars[random.nextInt(_chars.length)]).join();
}

/// 异步获取精准设备型号的生成函数（支持 Android 真实设备名）
Future<String> generateDeviceAlias() async {
  String deviceName = 'Device';
  final deviceInfo = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // androidInfo.model 通常为 "Pixel 6"、"2201122C" 等型号
      // 如果想要更友好的厂商+型号，可以使用: "${androidInfo.manufacturer} ${androidInfo.model}"
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.name; // 例如 "Jack's iPhone"
    } else {
      final host = Platform.localHostname;
      if (host.isNotEmpty && host.toLowerCase() != 'localhost') {
        deviceName = host;
      }
    }
  } catch (_) {}

  if (deviceName.isEmpty || deviceName.toLowerCase() == 'localhost') {
    deviceName = 'Device';
  }

  return '$deviceName-${_generateRandomSuffix(2)}';
}
