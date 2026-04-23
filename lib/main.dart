import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'providers/download_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: const SeikoApp(),
    ),
  );
}

class SeikoApp extends StatelessWidget {
  const SeikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return Consumer<DownloadProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              title: 'seiko',
              debugShowCheckedModeBanner: false,
              themeMode: provider.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: const Color(0xFF00FF9D)),
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkDynamic ?? ColorScheme.fromSeed(
                  seedColor: const Color(0xFF00FF9D),
                  brightness: Brightness.dark,
                ),
                brightness: Brightness.dark,
              ),
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
