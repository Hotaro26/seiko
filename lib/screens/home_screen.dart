import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/download_provider.dart';
import '../widgets/video_info_card.dart';
import '../widgets/download_progress_overlay.dart';
import '../services/notification_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("NO_BROWSER_INSTALLED_ON_SYSTEM")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SYSTEM_EXECUTION_ERROR")),
        );
      }
    }
  }

  void _showDevInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: screenWidth > 800 ? 600 : screenWidth,
      ),
      builder: (context) => Center(
        child: Container(
          width: screenWidth > 800 ? 600 : double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text("DEVELOPER_PROTOCOL", style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset('assets/silly_cat.jpg', width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text("hotaro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 32),
              _buildDevLink(FontAwesomeIcons.github, "GITHUB", "https://github.com/Hotaro26"),
              _buildDevLink(FontAwesomeIcons.discord, "DISCORD", "oi.hotaro"),
              _buildDevLink(FontAwesomeIcons.pinterest, "PINTEREST", "https://pin.it/3SLXHYBbY"),
              _buildDevLink(FontAwesomeIcons.spotify, "SPOTIFY", "https://open.spotify.com/user/31lx3m76madtoolhoyrmy7d474ym?si=b2c8f8deebff4aad"),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text("SYSTEM_LICENSES", style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 10, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text("OPEN_SOURCE: MIT / APACHE 2.0 / YT_EXPLODE", style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevLink(dynamic icon, String label, String value) {
    final bool isUrl = value.startsWith('http');
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          if (isUrl) {
            _launchUrl(value);
          } else {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$label copied to clipboard")),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              FaIcon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isDark ? Colors.white : Colors.black)),
              const Spacer(),
              if (isUrl) 
                Icon(Icons.open_in_new_rounded, size: 14, color: colorScheme.primary)
              else
                Text(value, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }

  void _showTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("TROUBLESHOOTING", style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Use VPN if blocked"),
            Text("• Clear app cache"),
            Text("• Toggle Mobile Data / Wi-Fi"),
            Text("• Verify URL format"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('SEIKO // DOWNLOADER', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()))
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 48.0 : 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text("INPUT_URL", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'HTTPS://YOUTUBE.COM/...',
                        suffixIcon: IconButton(icon: const Icon(Icons.content_paste_rounded, size: 20), onPressed: _asyncPaste),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(height: 54, child: FilledButton(onPressed: _executeFetch, child: const Text('EXECUTE_FETCH'))),
                    const SizedBox(height: 48),
                    _buildStatusDisplay(),
                    const SizedBox(height: 120), // Extra space for footer
                  ],
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _showDevInfo,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(child: Image.asset('assets/silly_cat.jpg', fit: BoxFit.cover)),
                      ),
                    ),
                    
                    AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                      child: Row(
                        children: [
                          if (_isSettingsExpanded) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => context.read<DownloadProvider>().toggleTheme(!isDark),
                              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 22),
                            ),
                            IconButton(onPressed: _showTips, icon: const Icon(Icons.help_outline_rounded, size: 22)),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 4),
                    
                    GestureDetector(
                      onTap: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSettingsExpanded ? colorScheme.primary : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 400),
                          turns: _isSettingsExpanded ? 0.25 : 0,
                          child: Icon(
                            _isSettingsExpanded ? Icons.close_rounded : Icons.settings_rounded,
                            size: 22,
                            color: _isSettingsExpanded ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const DownloadProgressOverlay(),
        ],
      ),
    );
  }

  Future<void> _asyncPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) setState(() => _urlController.text = data!.text!);
  }

  void _executeFetch() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) context.read<DownloadProvider>().getVideoInfo(url);
  }

  Widget _buildStatusDisplay() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingInfo) return const Column(children: [LinearProgressIndicator(), SizedBox(height: 12), Text("INITIALIZING_HANDSHAKE...", style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey))]);
        if (provider.errorMessage != null) return Text("ERROR: ${provider.errorMessage!.toUpperCase()}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace', fontSize: 12));
        if (provider.currentVideo != null) return VideoInfoCard(videoInfo: provider.currentVideo!, url: _urlController.text.trim());
        return Center(child: Opacity(opacity: 0.2, child: Icon(Icons.terminal_rounded, size: 64, color: Theme.of(context).colorScheme.outline)));
      },
    );
  }
}
