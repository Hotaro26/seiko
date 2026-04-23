import 'package:flutter/material.dart';
import '../models/video_models.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';

class VideoInfoCard extends StatefulWidget {
  final VideoInfo videoInfo;
  final String url;

  const VideoInfoCard({super.key, required this.videoInfo, required this.url});

  @override
  State<VideoInfoCard> createState() => _VideoInfoCardState();
}

class _VideoInfoCardState extends State<VideoInfoCard> {
  String _selectedFormat = 'video';
  String _selectedQuality = '720p';

  @override
  void initState() {
    super.initState();
    _selectedFormat = 'video';
    _selectedQuality = '720p';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Image.network(
                    widget.videoInfo.thumbnail,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: colorScheme.surfaceContainerHighest, width: 100, height: 100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.videoInfo.title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DURATION: ${widget.videoInfo.duration}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("CONFIGURATION", style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, letterSpacing: 2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colorScheme.onSurface),
                    decoration: const InputDecoration(labelText: 'TYPE', labelStyle: TextStyle(fontSize: 10)),
                    items: const [
                      DropdownMenuItem(value: 'video', child: Text('VIDEO (MP4)')),
                      DropdownMenuItem(value: 'audio', child: Text('AUDIO (MP3)')),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedFormat = val!;
                      if (_selectedFormat == 'audio') _selectedQuality = 'best';
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedQuality,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colorScheme.onSurface),
                    decoration: const InputDecoration(labelText: 'QUALITY', labelStyle: TextStyle(fontSize: 10)),
                    items: _selectedFormat == 'video'
                        ? const [
                            DropdownMenuItem(value: '1080p', child: Text('1080P_HD')),
                            DropdownMenuItem(value: '720p', child: Text('720P_SD')),
                            DropdownMenuItem(value: '480p', child: Text('480P_LQ')),
                          ]
                        : const [
                            DropdownMenuItem(value: 'best', child: Text('BITRATE_MAX')),
                          ],
                    onChanged: (val) => setState(() => _selectedQuality = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<DownloadProvider>().startDownload(
                    widget.url,
                    _selectedFormat,
                    _selectedQuality,
                  );
                },
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('INITIATE_DOWNLOAD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
