import 'package:flutter/material.dart';
import '../models/video_models.dart';
import '../services/api_service.dart';

class DownloadProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  VideoInfo? _currentVideo;
  VideoInfo? get currentVideo => _currentVideo;

  bool _isLoadingInfo = false;
  bool get isLoadingInfo => _isLoadingInfo;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _downloadProgress = 0;
  double get downloadProgress => _downloadProgress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  bool _isDownloadFinished = false;
  bool get isDownloadFinished => _isDownloadFinished;

  List<DownloadHistoryItem> _history = [];
  List<DownloadHistoryItem> get history => _history;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> getVideoInfo(String url) async {
    _isLoadingInfo = true;
    _currentVideo = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentVideo = await _apiService.fetchVideoInfo(url);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingInfo = false;
      notifyListeners();
    }
  }

  Future<void> startDownload(String url, String format, String quality) async {
    _isDownloading = true;
    _isDownloadFinished = false;
    _downloadProgress = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.downloadMedia(
        url: url,
        format: format,
        quality: quality,
        onProgress: (progress) {
          _downloadProgress = progress;
          if (progress >= 1.0) {
             _isDownloadFinished = true;
          }
          notifyListeners();
        },
      );
      await getHistory();
    } catch (e) {
      if (e.toString().contains("Cancelled")) {
      } else {
        _errorMessage = 'Download failed: $e';
      }
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void cancelDownload() {
    _apiService.cancelDownload();
    _isDownloading = false;
    _downloadProgress = 0;
    notifyListeners();
  }

  void resetDownloadState() {
    _isDownloadFinished = false;
    _downloadProgress = 0;
    _isDownloading = false;
    notifyListeners();
  }

  Future<void> getHistory() async {
    try {
      _history = await _apiService.fetchHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  void clearCurrentVideo() {
    _currentVideo = null;
    _errorMessage = null;
    notifyListeners();
  }
}
