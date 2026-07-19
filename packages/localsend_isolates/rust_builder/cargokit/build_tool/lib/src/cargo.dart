/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';

class ManifestException {
  ManifestException(this.message, {required this.fileName});

  final String? fileName;
  final String message;

  @override
  String toString() {
    if (fileName != null) {
      return 'Failed to parse package manifest at $fileName: $message';
    } else {
      return 'Failed to parse package manifest: $message';
    }
  }
}

class CrateInfo {
  CrateInfo({required this.packageName});

  final String packageName;

  static CrateInfo parseManifest(String manifest, {final String? fileName}) {
    final toml = TomlDocument.parse(manifest);
    final package = toml.toMap()['package'];
    if (package == null) {
      throw ManifestException('Missing package section', fileName: fileName);
    }
    final name = package['name'];
    if (name == null) {
      throw ManifestException('Missing package name', fileName: fileName);
    }
    return CrateInfo(packageName: name);
  }

  static CrateInfo load(String manifestDir) {
    // 1. 获取传入路径的绝对路径对象
    var directory = Directory(manifestDir);
    var absoluteManifestDir = directory.absolute.path;

    // 2. 如果绝对路径里包含软链接回退导致的错误（比如 Windows 的混用路径），我们尝试做一层标准化
    absoluteManifestDir = path.normalize(absoluteManifestDir);

    // 3. 打印一下此时解析出的绝对路径，方便在 GitHub Actions 日志里排查
    print('DEBUG: Cargokit is looking for Cargo.toml at: $absoluteManifestDir');
    final manifestFile = File(path.join(absoluteManifestDir, 'Cargo.toml'));
    final manifest = manifestFile.readAsStringSync();
    return parseManifest(manifest, fileName: manifestFile.path);
  }
}
