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

String generateDeviceAlias() {
  String deviceName = 'Device';

  // 1. 获取设备主机名/名称
  try {
    final host = Platform.localHostname;
    if (host.isNotEmpty && host.toLowerCase() != 'localhost') {
      deviceName = host;
    }
  } catch (_) {}

  // 2. 提取 IP 后两位
  String ipSuffix = _getSystemIpSuffix();

  return '$deviceName$ipSuffix';
}

/// 安全提取 IP 后两位（兼容所有 Flutter 编译平台）
String _getSystemIpSuffix() {
  try {
    // 尝试直接通过 Platform.localHostname 解析 IP
    final entries = InternetAddress.lookupSync(Platform.localHostname);
    for (var addr in entries) {
      if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
        final parts = addr.address.split('.');
        if (parts.length == 4) {
          return ' .${parts[2]}.${parts[3]}';
        }
      }
    }
  } catch (_) {}

  return '';
}
