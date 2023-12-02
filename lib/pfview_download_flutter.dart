library pfview_download_flutter;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pfview_download_flutter/appToast.dart';
import 'package:pfview_download_flutter/validateComponent.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

/* void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PDF Download View",
      home: PDFViewDownload(),
      builder: (context, child) {
        return MediaQuery(
          child: child ?? Container(),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
    );
  }
} */

class PDFViewDownload extends StatefulWidget {
  final String? url;
  final void Function(PdfDocumentLoadedDetails)? onDocumentLoaded;
  final void Function(PdfDocumentLoadFailedDetails)? onDocumentLoadFailed;
  final void Function()? onPressed;
  PDFViewDownload(
      {super.key,
      this.url,
      this.onDocumentLoaded,
      this.onDocumentLoadFailed,
      this.onPressed});

  @override
  State<PDFViewDownload> createState() => _PDFViewDownloadState();
}

class _PDFViewDownloadState extends State<PDFViewDownload> {
  /* @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pdfViewdownloadViewModel =
          Provider.of<PDFViewDownloadViewModel>(context, listen: false);
      pdfViewdownloadViewModel.setIsLoadingStatus(true);
    });
  } */

  @override
  Widget build(BuildContext context) {
    /*  final pdfViewdownloadViewModel =
        Provider.of<PDFViewDownloadViewModel>(context); */
    return Scaffold(
      body: SfPdfViewer.network(
        widget.url?.trim() ?? '',
        onDocumentLoaded: widget.onDocumentLoaded,
        onDocumentLoadFailed: widget.onDocumentLoadFailed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String fileName = extractFileNameFromUrl(widget.url ?? '');
          await savePdf(
            widget.url ?? '',
            "${fileName}.pdf",
            context,
          );
        },
        tooltip: 'Download',
        child: const Icon(Icons.download),
      ),
    );
  }

  String extractFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String? fileName = uri.queryParameters['fileName'];
    if (fileName != null && fileName.isNotEmpty) {
      return fileName.replaceAll('.pdf', '');
    } else {
      fileName = url.split("/").last.replaceAll(".pdf", "");
      return fileName;
    }
  }

  Future<void> downloadFile(
    String url,
    String baseFileName,
    context,
  ) async {
    Directory? externalDir;
    if (Platform.isIOS) {
      externalDir = await getApplicationDocumentsDirectory();
    } else {
      externalDir = Directory('/storage/emulated/0/Download');
    }
    int counter = 0;
    String fileName = baseFileName;

    while (await File('${externalDir.path}/$fileName').exists()) {
      counter++;
      String extension = path.extension(baseFileName);
      String fileNameWithoutExtension =
          path.basenameWithoutExtension(baseFileName);
      fileName = '$fileNameWithoutExtension($counter)$extension';
    }
    final filePath = '${externalDir.path}/$fileName';
    final dio = Dio();
    try {
      await dio.download(url, filePath,
          onReceiveProgress: (actualBytes, totalBytes) {
        var percentage = actualBytes.abs() / totalBytes.abs() * 100;

        if (percentage < 100) {
        } else {}
      });
      AppToast().showToast("$fileName is downloaded in Download Folder");
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Error downloading file: File not found');
      } else {
        AppToast().showToast('Error downloading file: ${e.message}');
      }
      return null;
    } catch (error) {
      AppToast().showToast('Error downloading file: $error');
      return null;
    }
    print('File downloaded to $filePath');
  }

  savePdf(
    String url,
    String baseFileName,
    BuildContext context,
  ) async {
    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;

      PermissionStatus status = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
      if (status.isGranted) {
        downloadFile(url, baseFileName, context);
      } else {
        PermissionStatus status = await Permission.storage.request();
        if (status.isGranted) {
          downloadFile(url, baseFileName, context);
        } else {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return ValidateAlertComponent(
                message: "Storage permission denied." +
                    "\nPlease allow storage permission to download pdf",
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              );
            },
          );
        }
      }
    } else if (Platform.isIOS) {
      PermissionStatus status = await Permission.photos.request();
      if (status.isGranted) {
        downloadFile(url, baseFileName, context);
      } else {
        PermissionStatus status = await Permission.photos.request();
        if (status.isGranted) {
          downloadFile(url, baseFileName, context);
        } else {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return ValidateAlertComponent(
                message: "Storage permission denied." +
                    "\nPlease allow storage permission to download pdf",
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              );
            },
          );
        }
      }
    } else {
      downloadFile(url, baseFileName, context);
    }
  }
}
