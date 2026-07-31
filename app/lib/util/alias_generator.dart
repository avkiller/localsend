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

/// 生成“设备名称 + IP 后两位”
String generateDeviceAlias() {
  String deviceName = 'Device';

  // 1. 获取设备名称
  try {
    final host = Platform.localHostname;
    if (host.isNotEmpty && host.toLowerCase() != 'localhost') {
      deviceName = host;
    }
  } catch (_) {}

  // 2. 安全读取局域网 IP 后两位
  String ipSuffix = '';
  try {
    final interfaces = NetworkInterface.listSync(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (var interface in interfaces) {
      final name = interface.name.toLowerCase();
      // 过滤常见虚拟网卡与 VPN
      if (name.contains('tun') || name.contains('vbox') || name.contains('docker') || name.contains('ppp')) {
        continue;
      }

      for (var addr in interface.addresses) {
        final parts = addr.address.split('.');
        if (parts.length == 4) {
          ipSuffix = ' .${parts[2]}.${parts[3]}';
          break;
        }
      }
      if (ipSuffix.isNotEmpty) break;
    }
  } catch (_) {}

  return '$deviceName$ipSuffix';
}
