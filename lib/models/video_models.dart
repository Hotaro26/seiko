class VideoInfo {
  final String title;
  final String thumbnail;
  final String duration;
  final List<String> formats;

  VideoInfo({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.formats,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? 'Unknown Title',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '00:00',
      formats: List<String>.from(json['formats'] ?? []),
    );
  }
}

class DownloadHistoryItem {
  final String title;
  final String url;
  final String format;
  final String quality;
  final DateTime date;
  final String? filePath;

  DownloadHistoryItem({
    required this.title,
    required this.url,
    required this.format,
    required this.quality,
    required this.date,
    this.filePath,
  });

  factory DownloadHistoryItem.fromJson(Map<String, dynamic> json) {
    return DownloadHistoryItem(
      title: json['title'] ?? 'Unknown Title',
      url: json['url'] ?? '',
      format: json['format'] ?? '',
      quality: json['quality'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      filePath: json['filePath'],
    );
  }
}
