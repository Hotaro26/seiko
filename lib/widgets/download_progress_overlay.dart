import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';

class DownloadProgressOverlay extends StatelessWidget {
  const DownloadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        if (!provider.isDownloading && !provider.isDownloadFinished) {
          return const SizedBox.shrink();
        }

        final bool isDone = provider.isDownloadFinished;
        final colorScheme = Theme.of(context).colorScheme;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: colorScheme.surface.withOpacity(0.85),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 20)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic Header Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: isDone ? 1.0 : provider.downloadProgress,
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                            color: isDone ? colorScheme.primary : colorScheme.secondary,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        Icon(
                          isDone ? Icons.check_circle_rounded : Icons.file_download_rounded,
                          size: 32,
                          color: isDone ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isDone ? 'DATA_SECURED' : 'SYNC_IN_PROGRESS',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    
                    // Wavy / Curvy Progress Area
                    if (!isDone) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: WavyProgressPainter(
                            progress: provider.downloadProgress,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(provider.downloadProgress * 100).toInt()}% COMPLETE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => provider.cancelDownload(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("ABORT"),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Download complete. The file is available in your system's Downloads directory.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => provider.resetDownloadState(),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("DONE"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WavyProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  WavyProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double waveHeight = 4.0;
    final double waveLength = 20.0;
    final double totalWidth = size.width * progress;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= totalWidth; i++) {
      path.lineTo(
        i,
        size.height / 2 + math.sin(i / waveLength * 2 * math.pi) * waveHeight,
      );
    }

    // Draw background track (faint)
    final trackPath = Path();
    trackPath.moveTo(0, size.height / 2);
    for (double i = 0; i <= size.width; i++) {
      trackPath.lineTo(
        i,
        size.height / 2 + math.sin(i / waveLength * 2 * math.pi) * waveHeight,
      );
    }
    
    canvas.drawPath(trackPath, Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyProgressPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
