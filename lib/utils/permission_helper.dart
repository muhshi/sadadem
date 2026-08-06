import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final images = await Permission.photos.request();
        return images.isGranted;
      } else {
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }
    } else {
      final result = await Permission.storage.request();
      return result == PermissionStatus.granted;
    }
  }
}
