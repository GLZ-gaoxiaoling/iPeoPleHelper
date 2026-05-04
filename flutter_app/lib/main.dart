import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IPeopleHelperApp());
}

class IPeopleHelperApp extends StatelessWidget {
  const IPeopleHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我要验牌',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// ==================== 数据 ====================

class SoundItem {
  final int id;
  final String title;
  final String file;
  final Color color;

  const SoundItem({
    required this.id,
    required this.title,
    required this.file,
    required this.color,
  });
}

const soundItems = [
  SoundItem(id: 1, title: '我要验牌', file: 'woyaoyanpai.mp3', color: Color(0xFF4CAF50)),
  SoundItem(id: 2, title: '牌没有问题', file: 'paimeiyouwenti.mp3', color: Color(0xFF2196F3)),
  SoundItem(id: 3, title: '给我擦皮鞋', file: 'geiwocapixie.mp3', color: Color(0xFFFF9800)),
  SoundItem(id: 4, title: '小瘪三', file: 'xiaobiesan.mp3', color: Color(0xFF9C27B0)),
  SoundItem(id: 5, title: '小儿科', file: 'xiaoerke.mp3', color: Color(0xFFF44336)),
  SoundItem(id: 6, title: '误闯天家', file: 'wuchuangtianjia.mp3', color: Color(0xFF607D8B)),
  SoundItem(id: 7, title: 'bibirabu', file: 'bibirabu.mp3', color: Color(0xFF00BCD4)),
  SoundItem(id: 8, title: 'bababoi', file: 'bababoi.mp3', color: Color(0xFF4CAF50)),
  SoundItem(id: 9, title: '八嘎呀路', file: 'bagayaru.mp3', color: Color(0xFF2196F3)),
  SoundItem(id: 10, title: '我的刀盾', file: 'wodedaodun.mp3', color: Color(0xFFFF9800)),
  SoundItem(id: 11, title: '咕咕嘎嘎', file: 'gugugaga.mp3', color: Color(0xFF9C27B0)),
  SoundItem(id: 12, title: '爱音糖哭', file: 'annotangku.wav', color: Color(0xFFF44336)),
  SoundItem(id: 13, title: '爱音糖笑', file: 'annotangxiao.wav', color: Color(0xFF607D8B)),
  SoundItem(id: 14, title: '给白傻子买瓜子去', file: 'geibaishazimaiguaziqu.wav', color: Color(0xFF00BCD4)),
  SoundItem(id: 15, title: '我上早八', file: 'woshangzaoba.wav', color: Color(0xFF00BCD4)),
];

// ==================== 主页 ====================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final AudioPlayer _player;
  int _maxStreams = 3;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxStreams = prefs.getInt('max_streams') ?? 3;
    });
  }

  Future<void> _playSound(SoundItem item) async {
    await _player.play(AssetSource('sounds/${item.file}'));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我要验牌',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildSoundGrid(),
          SettingsPage(maxStreams: _maxStreams),
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
    );
  }

  Widget _buildSoundGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: soundItems.length,
      itemBuilder: (context, index) {
        final item = soundItems[index];
        return _SoundCard(item: item, onTap: () => _playSound(item));
      },
    );
  }
}

// ==================== 音效卡片 ====================

class _SoundCard extends StatelessWidget {
  final SoundItem item;
  final VoidCallback onTap;

  const _SoundCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${item.id}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 设置页 ====================

class SettingsPage extends StatefulWidget {
  final int maxStreams;

  const SettingsPage({super.key, required this.maxStreams});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _maxStreams;
  final _maxStreamsOptions = [1, 2, 3, 5, 10];

  @override
  void initState() {
    super.initState();
    _maxStreams = widget.maxStreams;
  }

  Future<void> _saveMaxStreams(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('max_streams', value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '设置',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<int>(
              initialValue: _maxStreams,
              decoration: const InputDecoration(
                labelText: '最大同时播放数',
                border: OutlineInputBorder(),
              ),
              items: _maxStreamsOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _maxStreams = value);
                  _saveMaxStreams(value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              '设置自动保存',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
