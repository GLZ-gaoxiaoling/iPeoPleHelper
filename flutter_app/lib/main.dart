import 'package:flutter/material.dart';
import 'services/audio_manager.dart';
import 'services/data_manager.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IPeopleHelperApp());
}

class IPeopleHelperApp extends StatefulWidget {
  const IPeopleHelperApp({super.key});

  @override
  State<IPeopleHelperApp> createState() => _IPeopleHelperAppState();
}

class _IPeopleHelperAppState extends State<IPeopleHelperApp> {
  int _currentIndex = 0;
  late AudioManager _audioManager;
  int _maxStreams = 3;
  double _volume = 1.0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final maxStreams = await SoundDataManager.loadMaxStreams();
    final volume = await SoundDataManager.loadVolume();
    setState(() {
      _maxStreams = maxStreams;
      _volume = volume;
      _audioManager = AudioManager(maxStreams: maxStreams);
      _ready = true;
    });
  }

  void _onMaxStreamsChanged(int count) {
    // 这个设置在下一次 App 启动时生效（因为 AudioManager 在 init 时创建）
    // 实际上我们可以动态重建 AudioManager
    setState(() => _maxStreams = count);
    _audioManager = AudioManager(maxStreams: count);
    // 同步音量到新的管理器
    _audioManager.setVolume(_volume);
    _audioManager.onPlaybackUpdate = null; // 会被主页重新绑定
  }

  void _onVolumeChanged(double volume) {
    setState(() => _volume = volume);
    _audioManager.setVolume(volume);
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: '我要验牌',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            '我要验牌',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            if (_currentIndex == 0)
              IconButton(
                icon: const Icon(Icons.stop),
                tooltip: '停止所有播放',
                onPressed: () => _audioManager.stopAll(),
              ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(key: ValueKey('home_$_maxStreams'), audioManager: _audioManager),
            SettingsPage(
              maxStreams: _maxStreams,
              volume: _volume,
              onMaxStreamsChanged: _onMaxStreamsChanged,
              onVolumeChanged: _onVolumeChanged,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: '首页'),
            NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          ],
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          selectedIndex: _currentIndex,
        ),
      ),
    );
  }
}
