import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';

part 'favorite_device.mapper.dart';

const _uuid = Uuid();

@MappableClass()
class FavoriteDevice with FavoriteDeviceMappable {
  final String id;
  final String fingerprint;
  final String? ip;
  final int port;
  final String alias;
  final String? signalingId;

  /// If true, the alias was set by the user.
  /// If false, the alias is derived from the original device alias and
  /// should be updated when the original device alias changes.
  final bool customAlias;

  const FavoriteDevice({
    required this.id,
    required this.fingerprint,
    this.ip,
    required this.port,
    required this.alias,
    this.signalingId,
    this.customAlias = false,
  });

  factory FavoriteDevice.fromValues({
    required String fingerprint,
    String? ip,
    String? signalingId,
    required int port,
    required String alias,
  }) {
    return FavoriteDevice(
      id: _uuid.v1(),
      fingerprint: fingerprint,
      ip: ip,
      signalingId: signalingId,
      port: port,
      alias: alias,
      customAlias: false,
    );
  }

  static const fromJson = FavoriteDeviceMapper.fromJson;
}
