import 'package:dio/dio.dart';
import 'dart:io';

class DownloadHelper {
  static Future<String> downloadToPublicDownloads(String url, String fileName) async {
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    final savePath = '${downloadsDir.path}/$fileName';
    
    await Dio().download(url, savePath);
    return savePath;
  }
}