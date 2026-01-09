import 'dart:io';
import 'package:video_compress/video_compress.dart';

class VideoCompressService {
  static Future<File?> compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    return info?.file;
  }
}
