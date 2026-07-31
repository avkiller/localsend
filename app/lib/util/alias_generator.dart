import 'dart:math';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/native/device_info_helper.dart';

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

String _generateRandomSuffix([int length = 3]) {
  final random = Random();
  return List.generate(length, (_) => _chars[random.nextInt(_chars.length)]).join();
}

/// 异步获取精准设备型号的生成函数（支持 Android 真实设备名）
Future<String> generateDeviceAlias() async {
  try {
    final info = await getDeviceInfo();
    final model = info.deviceModel;

    if (model != null && model.isNotEmpty && model.toLowerCase() != 'localhost') {
      return '$model-${_generateRandomSuffix(3)}'; // 输出如: "Xiaomi 2201122C-a2" 或 "Google Pixel 6-x9"
    }
  } catch (_) {}
  return 'UnknownDevice-${_generateRandomSuffix(3)}';

}
