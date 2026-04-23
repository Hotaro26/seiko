import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/video_models.dart';
import 'notification_service.dart';

class ApiService {
  final YoutubeExplode _yt = YoutubeExplode();
  bool _isCancelled = false;

  // Static list to persist history during app session
  static final List<DownloadHistoryItem> _localHistory = [];

  void cancelDownload() {
    _isCancelled = true;
  }

  Future<VideoInfo> fetchVideoInfo(String url) async {
    try {
      final video = await _yt.videos.get(url);
      return VideoInfo(
        title: video.title,
        thumbnail: video.thumbnails.highResUrl,
        duration: video.duration?.toString().split('.').first ?? '00:00',
        formats: ['video', 'audio'],
      );
    } catch (e) {
      throw Exception('Failed to fetch video info: $e');
    }
  }

  Future<List<DownloadHistoryItem>> fetchHistory() async {
    return _localHistory;
  }

  Future<void> downloadMedia({
    required String url,
    required String format,
    required String quality,
    required Function(double) onProgress,
  }) async {
    _isCancelled = false;
    try {
      // 1. Request Permissions
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt <= 32) {
          await Permission.storage.request();
        } else {
          await Permission.videos.request();
          await Permission.audio.request();
          await Permission.notification.request();
        }
      }

      // 2. Get Video Metadata
      final video = await _yt.videos.get(url);
      final manifest = await _yt.videos.streamsClient.getManifest(url);
      
      StreamInfo? streamInfo;
      if (format == 'audio') {
        streamInfo = manifest.audioOnly.withHighestBitrate();
      } else {
        final muxed = manifest.muxed;
        if (muxed.isEmpty) throw Exception('No muxed streams available');

        if (quality == '1080p') {
          try {
            streamInfo = muxed.firstWhere((s) => s.videoQuality.toString().contains('1080'));
          } catch (_) {
            streamInfo = muxed.bestQuality;
          }
        } else if (quality == '720p') {
          try {
            streamInfo = muxed.firstWhere((s) => s.videoQuality.toString().contains('720'));
          } catch (_) {
            streamInfo = muxed.bestQuality;
          }
        } else {
          streamInfo = muxed.bestQuality;
        }
      }

      if (streamInfo == null) throw Exception('No suitable stream found');

      // 3. Prepare File Path
      String? downloadPath;
      if (Platform.isAndroid) {
        downloadPath = '/storage/emulated/0/Download';
        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          final externalDir = await getExternalStorageDirectory();
          downloadPath = externalDir?.path;
        }
      } else {
        final dir = await getDownloadsDirectory();
        downloadPath = dir?.path;
      }

      if (downloadPath == null) throw Exception('Could not find download directory');

      final safeTitle = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
      final extension = format == 'audio' ? 'mp3' : 'mp4';
      final file = File('$downloadPath/$safeTitle.$extension');

      // 4. Start Download with Notification
      final stream = _yt.videos.streamsClient.get(streamInfo);
      final fileStream = file.openWrite();
      
      int totalSize = streamInfo.size.totalBytes;
      int downloaded = 0;
      int lastNotificationPercent = 0;
      final int notificationId = video.id.value.hashCode;

      await for (final data in stream) {
        if (_isCancelled) {
          await fileStream.close();
          if (await file.exists()) await file.delete();
          throw Exception('Cancelled');
        }

        downloaded += data.length;
        double progress = downloaded / totalSize;
        onProgress(progress);
        
        int percent = (progress * 100).toInt();
        if (percent > lastNotificationPercent) {
          lastNotificationPercent = percent;
          NotificationService.showProgressNotification(
            notificationId, 
            percent, 
            video.title
          );
        }
        
        fileStream.add(data);
      }

      await fileStream.flush();
      await fileStream.close();

      // Final Notification
      NotificationService.showProgressNotification(notificationId, 100, video.title);

      // 5. Update Local History
      _localHistory.insert(0, DownloadHistoryItem(
        title: video.title,
        url: url,
        format: format,
        quality: quality,
        date: DateTime.now(),
        filePath: file.path,
      ));

    } catch (e) {
      if (e.toString() != "Exception: Cancelled") {
        throw Exception('Download failed: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _yt.close();
  }
}
