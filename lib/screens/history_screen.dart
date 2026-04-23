import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/download_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadProvider>().getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 800;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('DOWNLOAD_LOGS', style: TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, provider, child) {
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.outline.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('LOG_EMPTY', style: TextStyle(color: colorScheme.outline.withOpacity(0.4), letterSpacing: 4, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return isTablet 
            ? _buildGrid(provider, colorScheme) 
            : _buildList(provider, colorScheme);
        },
      ),
    );
  }

  Widget _buildList(DownloadProvider provider, ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: provider.history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HistoryCard(item: provider.history[index], colorScheme: colorScheme),
    );
  }

  Widget _buildGrid(DownloadProvider provider, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: provider.history.length,
      itemBuilder: (context, index) => _HistoryCard(item: provider.history[index], colorScheme: colorScheme),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic item;
  final ColorScheme colorScheme;

  const _HistoryCard({required this.item, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.description_outlined, color: colorScheme.onPrimaryContainer, size: 20),
        ),
        title: Text(
          item.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${item.format.toUpperCase()} // ${item.quality.toUpperCase()} // ${DateFormat('yyyy.MM.dd').format(item.date)}',
            style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 9, fontFamily: 'monospace'),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant, size: 18),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                'FILE_PATH: ${item.filePath}',
                style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: colorScheme.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}
