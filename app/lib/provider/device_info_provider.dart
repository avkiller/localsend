import 'package:collection/collection.dart';
import 'package:localsend_app/provider/local_ip_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/security_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_isolates/constants.dart';
import 'package:localsend_isolates/isolate.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/device_info_result.dart';
import 'package:refena_flutter/refena_flutter.dart';

final deviceRawInfoProvider = Provider<DeviceInfoResult>((ref) {
  throw Exception('deviceRawInfoProvider not initialized');
});

final deviceInfoProvider = ViewProvider<DeviceInfoResult>(
  (ref) {
    final (deviceType, deviceModel) = ref.watch(settingsProvider.select((state) => (state.deviceType, state.deviceModel)));
    final rawInfo = ref.watch(deviceRawInfoProvider);

    return DeviceInfoResult(
      deviceType: deviceType ?? rawInfo.deviceType,
      deviceModel: deviceModel ?? rawInfo.deviceModel,
      androidSdkInt: rawInfo.androidSdkInt,
    );
  },
  onChanged: (_, next, ref) {
    ref.redux(parentIsolateProvider).dispatch(IsolateSyncDeviceInfoAction(deviceInfo: next));
  },
);

final deviceFullInfoProvider = ViewProvider((ref) {
  final networkInfo = ref.watch(localIpProvider);
  final serverState = ref.watch(serverProvider);
  final rawInfo = ref.watch(deviceInfoProvider);
  final securityContext = ref.read(securityProvider);
  return Device(
    signalingId: null,
    ip: networkInfo.localIps.firstOrNull ?? '-',
    version: protocolVersion,
    port: serverState?.port ?? -1,
    alias: serverState?.alias ?? '-',
    https: serverState?.https ?? true,
    fingerprint: securityContext.certificateHash,
    deviceModel: rawInfo.deviceModel,
    deviceType: rawInfo.deviceType,
    download: serverState?.webSendState != null,
    discoveryMethods: const {},
  );
});

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
