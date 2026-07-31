import 'dart:math';

import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/local_ip_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

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

/// 根据当前设备信息和 IP 自动拼接名称：设备名称 + IP 后两位
String generateDeviceAlias(Ref ref) {
  final rawInfo = ref.read(deviceInfoProvider);
  final networkInfo = ref.read(localIpProvider);

  // 获取设备型号，若不存在则回退到 Device
  final deviceName = rawInfo.deviceModel ?? 'Device';

  // 提取 IP 后两位
  String ipSuffix = '';
  final ip = networkInfo.localIps.firstOrNull;
  if (ip != null) {
    final parts = ip.split('.');
    if (parts.length >= 2) {
      // 获取最后两个 IP 段，例如 192.168.1.105 -> 1.105
      ipSuffix = ' ${parts[parts.length - 2]}.${parts.last}';
    }
  }

  return '$deviceName$ipSuffix';
}
