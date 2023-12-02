import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandling {
  Future<bool> checkStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await plugin.androidInfo;

      final PermissionStatus status;
      if (android.version.sdkInt < 33) {
        status = await Permission.storage.status;
      } else {
        status = await Permission.photos.status;
      }

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        final PermissionStatus permission;
        if (android.version.sdkInt < 33) {
          permission = await Permission.storage.request();
        } else {
          permission = await Permission.photos.request();
        }

        if (permission.isDenied) {
          final PermissionStatus permission;
          if (android.version.sdkInt < 33) {
            permission = await Permission.storage.request();
          } else {
            permission = await Permission.photos.request();
          }

          if (permission.isDenied) {
            return false;
          } else if (permission.isGranted) {
            return true;
          } else {
            return false;
          }
        } else if (permission.isGranted) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }
}
